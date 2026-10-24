# Concurrency Integrity Lab

> `results/`는 Git 추적에서 제외한 로컬 실행 증거다. 아래 경로는 기존 로컬 자료를 가리키며 새 clone에는 포함되지 않는다. 재실행 수치는 달라질 수 있어 원본은 보존한다. 과거 기록의 커밋 ID는 이력 정리 전 식별자다.
회사에서 발생한 동시성 문제와 비슷한 상황을 합성 모델로 재현하고 이해하는 독립 실험이다. 현재는 [PLAN v3](PLAN.md)의 **P0만 완료**했다. 시간 구간의 겹침을 판정하는 환경을 준비했으며, 동시 요청의 실패 재현(P1)과 잠금 비교(P2)는 아직 수행하지 않았다.

## 구조와 환경

| 파일 | 역할 |
|---|---|
| `compose.yaml`, `schema.sql` | 전용 임시 PostgreSQL·식별 표식·합성 자원/구간 |
| `state.go` | 연결 대상 제한·DB 식별 확인·최종 상태 판정 |
| `state_test.go` | 연결 대상 경계 테스트 13개 |
| `integration_test.go` | 실제 DB에서 세션 분리와 순차 경계 테스트 9개 |
| [RESEARCH-RECORD.md](RESEARCH-RECORD.md) | 완료 범위·관측·미검증 |
| results/2026-10-20-p0/ (로컬: `results/2026-10-20-p0/`) | 실행 환경·원본 JSONL·검사 상태·종료 전 DB 상태 |

실행 환경은 Go 1.27.3 / darwin arm64, pgx v5.11.0, PostgreSQL 18.6 / linux arm64다. Go 모듈과 이미지 digest를 고정했다. 전체 환경과 파일 hash는 environment.json (로컬: `results/2026-10-20-p0/environment.json`)에 있다.

P0는 참여용 DB 연결 2개와 관측용 연결 1개를 동시에 확보하고 서로 다른 세션인지 확인한다. 참여 연결은 Read Committed다. 판정기만 읽기 전용 Repeatable Read 트랜잭션으로 행 목록과 충돌 수를 같은 snapshot에서 읽는다. 이는 후속 실험의 쓰기 격리 수준을 변경하는 해결책이 아니다. Read Committed에서는 문장마다 관측 snapshot이 달라질 수 있다는 [PostgreSQL 18 공식 설명](https://www.postgresql.org/docs/18/transaction-iso.html#XACT-READ-COMMITTED)을 참고했다(확인: 2026-10-20).

## 재현

저장소 루트에서 아래 명령을 실행한다. Docker와 Go가 필요하다. 기존 프로젝트의 DB·애플리케이션은 사용하지 않는다.

```sh
cd labs/concurrency-integrity
docker compose config --quiet
docker compose up -d --wait --wait-timeout 45
LAB_DB_PORT=$(docker compose port db 5432 | awk -F: '{print $NF}')
export LAB_DATABASE_URL="postgres://lab_p0@127.0.0.1:${LAB_DB_PORT}/concurrency_integrity_p0?sslmode=disable"
export GOCACHE="${TMPDIR:-/tmp}/concurrency-integrity-go-cache"
export GOFLAGS=-trimpath

go test -count=1 -timeout=90s ./...
go test -tags=integration -json -count=1 -timeout=90s ./...
go test -race -tags=integration -json -count=1 -timeout=90s ./...
go vet -tags=integration ./...

docker compose down
```

`-tags=integration`가 없으면 URL 검증만 실행한다. 통합 테스트는 DB URL이 없거나 대상 검증에 실패하면 **실패**하며 조용히 건너뛰지 않는다. `example.com` 모듈 경로는 독립 로컬 모듈의 이름이며 GitHub 소스 링크가 아니다.

이 Compose 프로젝트 이름이 이미 사용 중이라면 먼저 소유 여부를 확인한다. 테스트는 명시한 loopback 주소·사용자·DB 이름과 DB 내부 식별 표식을 모두 확인한 뒤 합성 fixture를 쓴다. 테스트마다 생성한 자원 ID에 속한 행만 정리한다. 별도 DB의 초기화·drop·기존 볼륨 삭제 명령은 없다.

컨테이너는 2 CPU·1GiB 제한, 256MiB tmpfs와 loopback 임시 포트를 사용한다. 합성 데이터만 다루는 임시 DB라 비밀번호 없는 trust 인증이다. 다른 용도로 재사용하지 않는다. **`down`/컨테이너 재생성 시 DB 데이터는 사라진다.** 호스트의 결과 파일은 남는다. 재실행 결과는 기존 디렉터리에 덮어쓰지 말고 새 세션에 보존한다.

## P0 결과

통합 검사와 Race 검사 모두 URL 경계 13개·DB 하위 사례 9개를 통과했다. Go JSON 출력에서는 부모 테스트 2개를 포함하여 각각 24개가 pass다. vet도 종료 코드 0이다.

DB 사례는 아래 순서로 데이터를 누적한다. 구간은 같은 합성 날짜·UTC 기준이다. 판정은 활성 행 사이의 **충돌 쌍 수**이며, 한 행이 여러 행과 겹치면 각각 센다.

| 추가 입력 | 최종 전체 행 수 | 충돌 쌍 수 |
|---|---:|---:|
| R1 `[13:00,13:30)` | 1 | 0 |
| R1 `[13:30,14:00)` — 인접 | 2 | 0 |
| R2 `[13:00,13:30)` — 다른 자원 | 3 | 0 |
| R1 동일 구간 — 비활성 | 4 | 0 |
| 길이 0·역전 구간 — 각각 SQLSTATE 23514 거절 | 4 | 0 |
| R1 `[13:15,13:45)` — 의도적 겹침 | 5 | 2 |
| R1 `[13:00,13:30)` — 의도적 중복 | 6 | 4 |

추가로 식별 표식이 틀린 DB 연결을 거절했다. 검사 후 자원·구간·테스트 연결은 각각 0개이고 표식은 복원됐음을 별도 조회했다. 이후 이 실험 컨테이너만 정리했다.

길이 검사는 `CHECK`, 자원 연결은 FK로 검증한다. 겹침을 막는 DB 제약과 애플리케이션 잠금은 아직 없다. [PostgreSQL CHECK 문서](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS)의 행 단위 제약과 여러 행 사이의 불변 조건을 구분한다(확인: 2026-10-20).

P0의 겹침은 판정기 검증을 위해 순차 삽입한 것이다. **동시성 실패 재현·해결 성공·업무 환경의 안전성 증거가 아니다.** Go Race Detector 통과도 DB 무결성을 증명하지 않는다. 다음 단계는 P1의 통제한 두 트랜잭션 경쟁이며 별도 승인이 필요하다.
