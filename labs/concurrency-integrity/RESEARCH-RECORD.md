# Research Record — concurrency-integrity

- 계획: [PLAN.md](PLAN.md) v3. 2026-10-20 사용자가 계획 정리·로컬 커밋 후 P0 진행 승인.
- 단계: Stage B/C의 P0 완료. P1 이후 미승인·미실행. 글 작성 요청 없음.
- 코드·환경: [environment.json](results/2026-10-20-p0/environment.json)의 파일 hash·도구·명령·결과 상태 참조. 계획 커밋은 `013a356`, 실행 당시 P0 구현은 미커밋이었으며 해당 코드 상태는 파일 hash로 확인한다.
- 예산: 원래 3시간·2 CPU·1GiB·50MiB 상한 안에서 수행. 커밋 이후 기록까지의 경과 시간과 산출물 크기는 environment.json 참조. 순수 구현 시간은 별도 계측하지 않음.

## Research Brief — 핵심 이해

1. **질문:** 겹치는 구간의 동시 등록을 어떻게 재현하고 보호 효과를 검증할까?
2. **현재 확인:** 실제 로컬 DB 연결 3개를 분리했고, 판정기가 정상 경계와 의도적으로 넣은 충돌 상태를 구분했다. 잘못된 구간과 연결 대상도 거절했다.
3. **의미:** 다음 실험에서 응답이나 테스트 통과만 보는 대신, 독립 연결에서 실제 남은 행과 충돌 쌍을 검증할 준비가 됐다.
4. **증명하지 않은 것:** 아직 두 트랜잭션을 경쟁시키지 않았다. 잠금의 보호 효과와 실제 업무 환경의 원인은 모른다.
5. **다음:** P1 승인 시 조회 완료 barrier로 동시 등록 실패를 재현한다. 사용자 이해 여부는 기술적 검사와 구분한다.

## 진행·재개 / 실행 증거

| 단위 | 상태 | 원본 | 판정 |
|---|---|---|---|
| P0 통합 | 유효 완료 | [integration.jsonl](results/2026-10-20-p0/integration.jsonl) | 부모 포함 24 pass, 패키지 pass·종료 코드 0 |
| P0 Race | 유효 완료 | [race.jsonl](results/2026-10-20-p0/race.jsonl) | 동일 사례 24 pass, Race 보고 없음·종료 코드 0 |
| P0 vet | 유효 완료 | [환경·검사 상태](results/2026-10-20-p0/environment.json) | 종료 코드 0, stdout/stderr 비어 있음 |
| P0 종료 전 DB | 유효 완료 | [cleanup.json](results/2026-10-20-p0/cleanup.json) | 자원·구간·테스트 세션 0, 식별 표식 복원 |
| P1 / P2 | 미승인·미실행 | 없음 | 실패 재현·수정 전후 비교 없음 |

기본 URL 단위 검사는 최초 구현 시 통과했다. gofmt와 테스트 보강 뒤 위 통합·Race 검사가 해당 단위 검사도 다시 포함했다. 최초 의존성 준비는 샌드박스의 Go 캐시 쓰기 제한 및 누락된 모듈로 중단됐고, 캐시 위치를 분리하고 필요한 의존성을 준비한 뒤 완료했다. 이를 재현 대상의 실패로 집계하지 않는다.

원본은 각 검사별 배타적 임시 파일에 쓴 뒤 종료 코드와 JSONL의 package pass/실패 유무를 확인하여 최종 이름으로 교체했다. stderr와 vet의 빈 파일은 오류·출력이 없다는 로그이며, 비어 있는 측정 데이터로 해석하지 않는다.

## Observed — 관측

- 서로 다른 DB 세션 3개, pool 최대 연결 3개, 참여 연결 Read Committed·문장 제한 5초를 확인했다.
- 독립 관측 세션에서 누적 행 수는 1→2→3→4→4→4→5→6, 충돌 쌍 수는 0→0→0→0→0→0→2→4였다. 잘못된 구간 두 개는 SQLSTATE 23514로 거절돼 행을 늘리지 않았다.
- 마지막 두 입력은 **의도적으로 순차 삽입한 충돌 fixture**다. P1의 동시 실행 실패가 아니다.
- 식별 표식 불일치를 거절하고 표식을 복원했다. 검사 끝에 idle-in-transaction 0, fixture 정리와 pool 종료 후 테스트 세션 0을 확인했다.
- 자원 제한·loopback 바인딩을 확인하고 전용 컨테이너만 종료·제거했다. 기존 실험과 서비스는 실행 대상으로 사용하지 않았다.

## Calculated / Interpretation

충돌 쌍은 `id` 순서를 정한 self join에서 같은 자원·양쪽 활성·반열린 구간 겹침 조건을 만족하는 행 쌍을 센다. README의 수치는 원본의 최종 상태 로그와 같다. 인접 구간 허용·다른 자원 분리·비활성 제외·잘못된 구간 거절을 각각 확인했으므로, 이 fixture에서 판정기가 구별해야 할 상태를 구별했다. 모든 입력에 대한 정확성을 증명한 것은 아니다.

## Unverified / Follow-up

- 동시 조회→삽입의 실패: P1에서 별도 승인 후 확인.
- 자원 행 잠금의 효과·우회·rollback 후 경쟁: P2 미실행.
- 모든 실행 순서, 서비스 간 통신·중복 처리·보상·성능: 이번 범위 밖.
- 브라우저·배포 환경: 앱 수정이 없어 새 브라우저 검증은 하지 않았다. `content:check`는 통과했고 공개 글은 0개다.

## Sources

- [PostgreSQL 18: Read Committed](https://www.postgresql.org/docs/18/transaction-iso.html#XACT-READ-COMMITTED) — 문장별 snapshot 및 읽기 격리 수준. 확인 2026-10-20.
- [PostgreSQL 18: CHECK Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS) — 행 단위 조건과 여러 행의 제한 구분. 확인 2026-10-20.
- 구현·원본·재현 명령은 이 디렉터리의 README와 환경 기록 참조.

## Understanding — 선택 사항

이번 P0의 결과에 대한 이해 대화는 아직 진행하지 않았다. 기술적 검사 통과를 사용자 학습 완료로 기록하지 않는다.

### 이번 연구를 통해 이해한 내용

### 아직 이해하지 못했거나 납득하지 못한 내용
