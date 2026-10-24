# Research Record — booking-compensation

> `results/`는 Git 추적에서 제외한 로컬 실행 증거다. 아래 경로는 기존 로컬 자료를 가리키며 새 clone에는 포함되지 않는다. 재실행 수치는 달라질 수 있어 원본은 보존한다. 과거 기록의 커밋 ID는 이력 정리 전 식별자다.
현재 단계는 아래 **v8 Schedule API 구조 정리 기록**이다. v1~v7 기록과 원본은 당시 구현·검증의 근거로 보존하며 현재 패키지 경로와 구분한다.

## v1 — 최초 일반 합성 기준선

- 계획: [PLAN v1](PLAN.md), 2026-10-23 Docker 구성·동작 확인 요청으로 승인.
- 범위: 독립 합성 기준 구현·최소 A/B/C/D 확인. 기존 P0 원본·다른 실험·회사 프로젝트는 변경하지 않았다.
- 단계: B/C의 초기 환경·문제 재현 완료. 자동 복구 개선·공개 글·이해 대화는 아직 수행하지 않음.
- 환경·코드·명령: environment.json (로컬: `results/2026-10-23-01/environment.json`). 코드와 원본 hash를 포함한다. 초기 실행 당시 미커밋 상태.
- 예산: 3시간·전체 6 CPU/4GiB·결과 20MiB 이내. 실제 Compose 제한은 상시 3.25 CPU/2,176MiB, 검사기 실행 중 추가 0.5 CPU/256MiB. stats.jsonl은 한 번의 관측이며 피크 사용량이 아니다.

## Research Brief — 핵심 이해

질문은 “예약 오류를 잡았는가?”보다 “돈과 두 서버의 상태가 결국 어떻게 됐는가?”다. 정상 예약과 슬롯 경쟁을 처리해도, 이후 실패에 대한 PG 승인·예약 상태는 따로 남을 수 있었다.

일정 삭제 보상을 성공시켜도 PG 승인은 남았다. 원격 응답 유실 때는 실패 응답을 받았어도 일정은 이미 저장됐다. DB commit 예외는 insert 주변 catch만으로 보상되지 않았다. 따라서 예외마다 무조건 환불하는 접근보다 **결과 상태를 식별·저장하고 반복 처리할 수 있는 경계**가 먼저 필요하다는 해석이 나온다. 어떤 방식이 충분한지는 후속 비교 전에는 확정하지 않는다.

트래픽 측면에서는 연결 4개를 쥔 요청만으로 독립 DB 조회를 밀 수 있었고, Slack은 예약 저장 뒤에도 응답을 늦추거나 429로 거절됐다. 운영에서 몇 명까지 가능한지 측정한 결과는 아니다.

## 진행·재개 / 실행 증거

| 단위 | 상태 | 증거 |
|---|---|---|
| Go 단위·Race·vet·Linux 바이너리 빌드 | 완료 | 호스트 실행 종료 코드 0. 단위 테스트 5개; Go 테스트 본문은 internal/lab/server_test.go |
| Docker 7개 서비스 기동 | 완료 | 전용 internal 네트워크, host published port 없음. 모든 health 정상 확인 |
| 정상·경합·취소 후 재사용·교차 진입 | 예상 조건 확인 | 원본 A/B 항목. 직접 일정 경로도 겹침 금지인 합성 계약 |
| 저장 실패·보상 실패·commit 예외·응답 유실 | 문제 재현 | 원본 C 항목. PG·독립 DB 상태로 판정 |
| PG의 명시적 환불·재시도 | 스텁 계약 확인 | 요청 3·효과 1. 자동 보상 정책을 입증한 것이 아님 |
| Slack 지연·429 / DB pool 점유 | 개입 효과 확인 | 원본 C/D 항목·metrics. 대규모 부하 아님 |
| 기존 Web/API 회귀 | 완료 | 웹 lint/format/15 tests/typecheck/build, API 1 test/typecheck. API는 로컬 Node 26이며 CI Node 22 별도 미검증 |
| 개선 전후 비교·재시작 복구·글 | 미실행 | 다음 범위 선택 필요 |

원본: run.jsonl (로컬: `results/2026-10-23-01/run.jsonl`), status.json (로컬: `results/2026-10-23-01/status.json`). 14개 항목은 S0·A 3개·B 1개·C 7개·D 1개·S-final이다. 14/14라는 표기는 **문제 재현을 포함한 실험 판정의 통과**다.

실행은 한 번이며 실패 원본을 고쳐 성공으로 만든 과정은 없다. Go 테스트와 Compose 정적 확인 후 실제 기동·검사를 수행했다. 검사기는 기존 DB 행과 기존 결과 디렉터리를 거절한다. 정상 원본은 임시 파일을 검증한 뒤 이름을 교체했고 stderr·서비스별 최근 300줄 로그·stats도 보존했다. 기존 스냅샷을 덮어쓰지 않는다.

## Observed — 관측

- `C-local-save`: 일정 삭제 성공, 로컬 예약 0, PG CAPTURED.
- `C-compensation-failure`: 삭제 503, 로컬 예약 0, 일정 활성 1, PG CAPTURED.
- `C-commit-boundary`: deferred FK 때문에 commit 실패, 로컬 예약 0, 일정 활성 1, PG CAPTURED.
- `C-response-lost`: 일정 commit 뒤 HTTP 연결 단절, 호출자는 unknown. 같은 결제 재요청은 409이며 일정은 잔존.
- `C-pg-refund`: 로컬 실패·일정 비활성화가 확인된 결제에 테스트가 명시적으로 환불을 요청했다. 첫 거절 뒤 두 재요청에서 효과는 총 1회였다. 가상 PG의 계약 확인이다.
- `C-slack-delay`: 200ms 주입 때 단일 응답 206ms. `C-slack-burst`: 예약 4건 저장·전송 4회·거절 3회, 재시도 없음.
- `D-pool-saturation`: held=4, pool_acquired=4 확인 후 독립 조회가 100ms 제한으로 503. 해제 뒤 모두 201, probe 200, pool_acquired=0·pool_canceled=1.
- 원본의 최종 DB는 로컬 12행·활성 11, 일정 17행·활성 15이며 활성 겹침 쌍은 0이다. 직접 일정 요청, 취소된 행, 보상 실패가 있어 두 전체 행 수가 같아야 한다고 판정하지 않는다.

## Calculated — 계산

analysis.json (로컬: `results/2026-10-23-01/analysis.json`)은 run.jsonl의 S-final을 입력으로 사용하고 입력 SHA-256을 기록했다. PG CAPTURED의 payment_id를 각 DB의 활성 행 payment_id 집합과 비교했다.

- 두 DB 모두 활성 예약이 없는 승인: 3개. 경쟁 패자와 정상 취소 뒤 미환불이 포함된다.
- 일정 DB에만 활성 예약이 있는 승인: 3개. 보상 실패·commit 예외·응답 유실이다.
- 전체 PG 상태: CAPTURED 17·REFUNDED 1.

합성 금액을 실제 매출 손실로 환산하지 않는다. unknown 결과와 확정적으로 예약이 없는 결과를 섞어 환불 대상으로 세지 않는다.

## Interpretation / Unverified

1. **결제 보상:** 원격 일정 삭제와 PG 환불은 다른 효과다. 환불에 실패할 때 작업이 지속 기록돼야 한다는 후보가 생겼다. 재시작·중복 요청·중복 환불·이미 성공한 예약의 오환불까지 통과하는 구현은 아직 없다.
2. **불확실한 결과:** HTTP 오류는 원격 rollback의 증거가 아니었다. request ID 기반 결과 재조회·멱등 재시도 후보를 검토할 가치가 있다. 이번 연결 단절과 지연 timeout은 같은 실험이 아니다. timeout 자체의 재현은 남아 있다.
3. **성능:** pool 점유의 인과는 제어 지점으로 확인했지만 운영 트래픽 임계치는 모른다. Slack 대기의 응답 영향·429 유실은 확인했으나 큐 도입 후 처리량·순서·재시도 안전성은 미검증이다.
4. **범위:** 모든 A/B/C/D 조합·회원 잔액·상태 경합·수동 겹침 예외·역콜백·실 PG/Slack·프로세스 재시작·장시간 부하는 제외했다. 실제 시스템을 복제하거나 기존 성능을 재현했다고 주장하지 않는다.

## Sources

공식 문서와 확인일은 [README 참고 자료](README.md#참고-자료)에 있다. 실행 근거는 원본·소스 hash다. Go 서버는 HTTP Client/Context, pgx 트랜잭션, Valkey의 최소 SET/EVAL 명령을 사용한다.

## Follow-ups — 다음 비교 후보

| 질문 | 방법 | 비용·복잡도 |
|---|---|---|
| 어떤 상태에서 PG 환불이 안전한가? | 정상·재시도·결과 unknown을 구분하는 결제-예약 상태 원장과 반례부터 설계 | 중간. 제일 먼저 정할 계약 |
| 보상 호출이 실패하거나 프로세스가 죽어도 다시 처리할 수 있는가? | 하나의 지속 보상 작업·멱등 환불을 추가하고 동일 failpoint 전후 비교 | 중간~높음. 저장 시점·중복 worker 고려 |
| 외부 대기에서 DB 풀을 놓으면 독립 조회가 회복되는가? | 현재 D의 같은 hold·RPC 지연에서 트랜잭션 범위 하나만 변경 | 중간. 정합성 약화 여부도 재검증 |
| Slack 경로를 분리하면 응답과 전달 보장을 함께 개선할 수 있는가? | 단일 큐 방식 비교, 429·지연·종료 중 유실 관측 | 중간. 단순 goroutine은 내구성 보장이 아님 |

## Understanding — 선택 사항

실행 결과에 대한 사용자의 설명·학습 확인 대화는 아직 없다. 기술적 검증을 사용자 학습 완료로 기록하지 않는다.

### 이번 연구를 통해 이해한 내용

### 아직 이해하지 못했거나 납득하지 못한 내용

## 종료

웹 게시글은 아직 작성하지 않았다. 기존 첫 글의 draft:true를 유지한다. 커밋·Push·배포는 하지 않는다. 컨테이너는 다음 관찰을 위해 기동 상태이며 종료·재생성하면 합성 상태가 사라진다.

## v2 실행 기록 — 두 Go 서버의 핵심 순서 / 2026-10-23

사용자는 기존 구조를 Go 기준으로 다시 작성하고 사례별 Go·Java/Spring의 실행 차이를 비교하며 학습하려는 목적을 설명했다. 이것은 사용자가 이미 그 차이를 이해했다는 증거가 아니다. 이번 수정은 [PLAN v2](PLAN.md#v2--핵심-실행-순서와-언어-차이-비교--2026-10-23) 범위의 모델 정렬이며, 특정 해결책 하나의 효과 비교가 아니다.

### 진행·증거

- v1 raw/analysis/status의 hash와 당시 소스 15개의 SHA를 확인한 뒤 이 랩의 컨테이너만 재생성했다. 다른 Java 랩·기존 P0·Go Load Lab은 변경하지 않았다.
- Go 서비스는 오케스트레이터·일정 서버만 남겼다. PG·Slack 테스트는 Python 이미지의 stdlib 더블로 옮겨 거절·멱등 환불·입력·429 검증을 유지했다. DB/Valkey/Python은 digest 고정, 호스트 포트 없음·내부 네트워크다.
- run.jsonl (로컬: `results/2026-10-23-02/run.jsonl`): 20/20 예상 조건 확인. environment (로컬: `results/2026-10-23-02/environment.json`), status (로컬: `results/2026-10-23-02/status.json`), 실행 당시 소스 (로컬: `results/2026-10-23-02/source/`), 서비스 로그·단일 stats snapshot을 보존했다.
- 명령: `python3 scripts/check.py --session 2026-10-23-02`. 새 DB, 전체 180초·각 판정 15초 상한. 실제 Docker CLI·바이너리 SHA·이미지·소스 hash·시각·명령은 environment/status가 원본이다.
- 현재 상시 Compose 제한 2.75 CPU / 1,920MiB, 일회성 검사기 추가 0.5 CPU / 256MiB. 두 Go 서버 DB pool 각각 4, HTTP 500ms, 검사기 HTTP 3초. 운영 설정이 아니다.

### Observed — v2에서 확인한 사실

| 사례 | 실제 관측과 최종 상태 |
|---|---|
| A-doubletap | 같은 사용자·예약 중복 요청 409/201. 양쪽 행 각각 1, 포인트 차감 원장 1, 잔액 100→60, 외부 승인 60 유지. |
| A-funds | 같은 사용자·다른 자원 두 요청 201/500. 잔액 100→20, 차감 80 한 번. 패자의 일정은 생성 뒤 보상 취소됐고 로컬 행 없음. 패자의 외부 승인 20은 남았다. |
| A-cancel-doubletap | 동시 두 번 + 후속 한 번 모두 200. 포인트 credit 1·잔액 100 복원, 외부 환불 요청 1·효과 1, 양쪽 비활성. |
| A-cancel-restore | 일정 취소 후 로컬 취소 전 실패 주입. 역보상 true, 양쪽 활성·차감 25 유지·잔액 75·환급 원장 없음·외부 승인 유지. |
| A-cancel-restore-failed | 동일 로컬 실패 + 역보상 거절. 로컬은 활성, 일정은 비활성, credit 없음·PG 승인 유지. 불일치 재현이다. |
| A-payment-validation | PG 승인 금액 불일치. 로컬 예약·포인트 차감 모두 rollback, 일정은 보상 취소, 기존 승인 70은 유지. |
| 기존 C 회귀 | 로컬 저장 실패 보상 성공/실패, commit 오류의 보상 공백, commit 뒤 응답 유실 unknown과 재시도 충돌을 다시 관측. |
| Slack·pool 회귀 | Slack 200ms 주입 시 응답 204ms; burst 4건 예약 성공·Slack 거절 3회. DB 연결 4개 hold 뒤 독립 probe 503, 해제 뒤 200. |

최종 snapshot: 오케스트레이터 15행/활성 13, 일정 22행/활성 16, PG CAPTURED 20·REFUNDED 3. 변경 잔액은 사용자 11=20, 12=75이고, 원장은 debit 3·credit 1이다. 취소·보상·직접 일정 진입·의도한 실패가 있어 총 행 수 동일을 불변 조건으로 삼지 않는다. 비교는 각 사례의 payment_id/actor와 활성 상태로 한다.

### Interpretation — 비교하며 읽을 지점

[Go/Spring 비교](GO-AND-SPRING.md)는 입력→tx→사용자 잠금→원격 HTTP→SQL/차감→PG 조회→commit→알림과 취소 역보상 순서에 연결했다. 자동 트랜잭션 프록시·명시적 error/Commit·JPA flush·Context/rollback·DB 잠금의 책임을 분리한다. 공식 문서의 의미와 Go 실험 관측은 구분하며, 이 결과로 Java에서 같은 장애가 재현됐다고 주장하지 않는다.

같은 사용자 요청은 DB 잠금으로 직렬화되더라도, 늦은 잔액 거절은 원격 생성·보상 호출을 발생시킬 수 있었다. 생성 실패 보상과 정상 취소 환불은 다른 경로다. 사용자 잠금·멱등 취소를 구현했다고 생성 실패의 승인 잔존까지 해결되지 않는다. 다음 개선은 상태 판정과 실패 하나에 한정해 비교해야 한다.

### 검사·안전

- Go: `go test -count=1 ./...`, `go test -race -count=1 ./...`, `go vet ./...`, Linux arm64 static build 통과. Go 단위 4개, PG/Slack은 Python 단위 2개로 책임을 옮겼다. Docker의 20개 판정은 일반 빌드로 실행했고 Race 빌드의 분산 부하 검증은 아니다.
- Web: content:check(공개 글 0), lint, format:check, 15개 test, typecheck, build 통과. 기존 첫 Lab 초안 draft:true 유지. 웹 소스/UI는 수정하지 않았다.
- Legacy API: 최초 sandbox에서 로컬 listen EPERM으로 실패. 허용된 실행 환경에서 재시도하여 1개 test·typecheck 통과. Node 26.9.0이며 CI Node 22는 이번에 검증하지 않았다. 원격 리소스 접근 없음.
- Commit/Push/PR/배포 없음. 컨테이너는 다음 코드·상태 관찰을 위해 healthy 상태로 유지한다. 재생성하면 합성 상태는 사라지고 호스트 원본은 유지된다.

### Unverified / 남은 경계

- 모든 A/B/C/D의 이식 완료가 아니다. 역콜백/순서 역전·변경/완료/취소 경합·수동 겹침 허용·정책별 예외는 구현하지 않았다. 별도 클라이언트 앱도 복제하지 않았다.
- 사용자/자원 키·초기 잔액·잠금 범위·timeout은 합성 계약이다. 선행 로컬 슬롯 검사 등 생략한 가드가 있으며 동일 구현이라고 주장하지 않는다.
- 정상 취소 PG 환불 성공 뒤 로컬 commit 실패, PG timeout 뒤 실제 환불 여부, 슬롯 재사용 후 restore 거절, 프로세스 재시작·지속 재처리·운영 용량·Java 동일 조건 실행은 미검증이다. 현재 구현은 생산용 복구 시스템이 아니다.
- 임의 sleep 없는 pool hold·commit 후 연결 단절 개입과, HTTP 동시 발사만 사용한 경합 사례의 통제 수준은 다르다. 모든 interleaving의 안전성을 증명하지 않는다.
- 사용자의 실제 이해 대화·학습 완료 기록은 아직 없다. 첫 질문 후보: **같은 사용자 두 요청에서 왜 원격 서버 호출 전에 사용자 DB 행을 잠그며, 그 잠금을 HTTP 대기 동안 유지하는 비용은 무엇일까?**

## v3 실행 기록 — 독립 API 두 개 / 2026-10-24 완료

사용자는 역할 분기·테스트 제어 코드가 중심인 구조를 바꾸고, 각자 API와 DB를 소유하는 실제 Go 서버 두 개로 핵심 흐름을 다시 작성해 비교·학습하길 요청했다. 이번 작업은 그 구조 정렬과 남은 검증이다. 자동 복구 개선·글 작성·커밋/Push/배포는 수행하지 않았다.

### 구조·범위

- `booking-api/`, `schedule-api/` 각각 별도 Go module·main·net/http 라우트·자체 스키마·Dockerfile·검사를 갖는다. 서로 코드를 import하거나 상대 DB를 읽지 않는다.
- 예약 DB는 사용자·예약·포인트 원장·결제 참조, 일정 DB는 자원·점유·상태 전이·이력을 소유한다. 실제 데이터와 업무 정책은 사용하지 않았다. 초기 사용자·자원은 별도 `fixtures.sql`이다.
- 역할 플래그·`/lab/*`·Fault 헤더·동일 공용 스키마·합성 commit guard를 실행 코드에서 제거했다. 기존 소스 16개는 v2 당시 SHA와 사본 일치를 확인한 뒤 실행 경로에서 제거했으며 `results/2026-10-23-02/source/`에 보존한다.
- 생성·취소·보상/역보상·직접 일정 진입·변경/완료·best-effort 역콜백을 구현했다. `net/http`·pgx와 기존 Python 이미지의 작은 외부 더블을 사용한다. Valkey는 현재 경로에서 쓰지 않아 선택 `cache` profile로 남겼다.
- 현재 전용 bridge의 모든 게시 포트는 127.0.0.1이다. 네트워크 자체의 외부 egress 차단은 아니다. Go HTTP/DB 주소 allowlist, 실제 자격증명 부재, 더블의 outbound 호출 부재로 로컬 범위를 지킨다.

### 중단·실패를 보존한 과정

| 세션 | 실제 상태·조치 |
|---|---|
| `2026-10-23-03` | 첫 health 요청 연결 거절. internal 네트워크의 실제 호스트 포트 바인딩이 비어 있음을 확인했다. 업무 데이터 생성 없이 중단. 전용 일반 bridge/loopback 게시로 수정했으며 원본 유지. |
| `2026-10-23-04` | 4개 판정 통과 뒤 A3에서 중단. 테스트가 서로 다른 시간 대신 같은 시간을 보내 사용자 중복 가드의 409가 먼저 발생했다. 서버를 수정하지 않고 두 번째 요청 시간을 변경했다. raw·소스·로그와 `recovery-snapshot/`의 두 DB data-only SQL·PG/Slack 상태·SHA를 보존한 뒤 이 랩의 합성 볼륨만 초기화했다. |
| 10/23→10/24 | 컨테이너 재기동 명령은 완료된 상태였다. 사용자 재개 요청 후 Git·health·새 DB 상태를 확인했다. 대기 중 기동 시간을 장시간 부하·내구성 검증으로 계산하지 않는다. |
| `2026-10-24-01` | 수정한 입력으로 새 실행. **21/21 예상 조건 확인**, `status.json.state=valid`. 일시적인 연결 오류·잘못된 fixture 시도의 결과와 섞어 하나의 성능 표본으로 합산하지 않는다. |

### 실행 증거

- 원본 21개 판정 (로컬: `results/2026-10-24-01/run.jsonl`), HTTP 요청·응답 (로컬: `results/2026-10-24-01/http.jsonl`), 환경·명령·소스/바이너리 SHA (로컬: `results/2026-10-24-01/environment.json`), 최종 완료·원본 hash (로컬: `results/2026-10-24-01/status.json`), 실행 당시 소스 사본 (로컬: `results/2026-10-24-01/source/`).
- 실행 명령: `python3 scripts/verify.py --session 2026-10-24-01`. 21개 사례의 실제 HTTP·별도 psql 조회를 보존했다. `progress.json`은 당시 각 사례 checkpoint이고, 전체 완료 판정은 `status.json`이다.
- Go 1.27.3 / pgx 5.11.0, PostgreSQL 18.6, Docker·이미지 식별자는 environment에 있다. 두 pool 각각 20, outbound HTTP 3초, PG 응답 1초, Slack 수락 간격/수락 응답 각각 1초다. 실제 운영 설정과 같은 성능이라고 주장하지 않는다.
- 상시 Compose 한도 4 CPU/1,792MiB. host 검증기는 별도 프로세스이며 worker 최대 100·HTTP 35초/전체 신규 요청 300초 상한이다. CPU 피크·운영 p95를 측정한 결과는 아니다.
- 계산 요약 (로컬: `results/2026-10-24-01/summary.json`)은 `python3 scripts/summarize.py 2026-10-24-01`로 생성했다. 입력 run.jsonl SHA와 계산 스크립트 SHA를 포함한다. raw를 고치지 않으며 같은 summary를 덮어쓰지 않는다.

### Observed — 실제 상태로 확인한 것

| 사례 | 관측·판정 |
|---|---|
| PG 승인/거절 | 성공 경로 201·거절 경로 402, 각각 응답까지 950ms 이상. 이는 실험용 1초 지연 계약의 확인이다. |
| A1/A2/A4/B | 같은 슬롯·부분 겹침·같은 사용자 중복·다른 진입 경합에서 한쪽만 예약. A2 양쪽 예약 각각 1·포인트 차감 1회. |
| A3 다른 시간·한 건 잔액 | 201/400, 잔액 20·차감 1회. 패자는 일정 생성 후 보상 취소됐고 PG 승인은 남았다. |
| A5 중복 취소 | 동시 2회 + 순차 재시도 모두 200. 잔액 복원, 포인트 credit·원격 취소 이력·PG 환불 효과 각각 1회. |
| A6/A7 | 취소 후 점유 재사용 가능. 두 일정의 동일 목표 변경은 200/409로 목표 점유 1건. |
| A8/A12 | 일정 변경/완료와 앱 취소 경합 뒤 양쪽 CANCELLED. 늦은 변경/완료 callback도 취소를 되살리지 않았고 완료 수는 0, 환급 1회. 모든 실행 순서를 통제한 반복은 아니다. |
| PG 금액 불일치 | 로컬 예약·차감 모두 rollback, 원격 일정은 보상 취소, 기존 승인 유지. |
| PG 환불 거절 | 로컬 취소·credit rollback, 원격 취소 역보상 성공으로 양쪽 PENDING·기존 차감 유지. |
| 원격 보상 DB 차단 | PG 검증 대기 중 생성된 일정 행을 별도 tx에서 잠갔다. 보상 HTTP가 실패하고 로컬 행은 없으나 원격 PENDING이 남았다. 제품 핸들러의 failpoint를 쓰지 않았다. |
| 역보상 DB 차단 | 원격 취소 후 행 잠금으로 복원 HTTP를 막았다. 로컬 PENDING·원격 CANCELLED가 남았다. |
| 역콜백 유실 | booking-api를 실제 중단한 동안 일정 취소 commit·callback 실패를 확인하고 서버를 재기동했다. 로컬 PENDING·원격 CANCELLED가 남았다. 지속 재시도 없음. |
| 실제 HTTP 중 pool 점유 | 자원/일자 advisory lock을 별도 tx에서 잡고 요청 20개를 시작했다. 일정 DB의 advisory 대기 20·예약 DB의 idle-in-transaction 20을 확인한 뒤 독립 health 503, 해제 후 200 회복. |
| 동시 webhook 100 | 200 **1건**, 429 **99건**. 거절에는 Retry-After, 수락은 1초 지연. |
| 동시 예약 실패 100 | 100건 모두 PG 금액 불일치 422, 원격 보상 취소 100건·로컬 예약 0·차감 0. Slack 시도 100건 중 **6 수락·94 거절**, 자동 재시도 없음. PG 승인 100건은 유지. |

직접 webhook 100건과 예약 실패 100건은 **다른 도착 조건**이다. 후자는 pool 20에서 PG 조회·보상 등을 거쳐 여러 배치로 도착했다. 6/94를 매번 고정되는 수치나 실제 Slack 수신율로 일반화하지 않는다. 더블은 실제 Slack의 짧은 버스트 허용 대신 엄격한 간격을 사용한다.

### Calculated — 최종 상태 요약

summary.json은 S-final의 원본 조회를 사용한다. 최종 로컬 예약 10행, 원격 일정 116행, 포인트 원장 14행, 일정 이력 229행이었다. PG는 CAPTURED 106·REFUNDED 1·DECLINED 1이다. 업무 거절·직접 일정·취소 이력을 포함하므로 전체 행 수가 같아야 한다고 판정하지 않는다.

- 연결된 예약의 상태 불일치 2개: `callback-loss`, `refund-failure`가 로컬 PENDING·원격 CANCELLED.
- 원격에만 활성 일정이 남은 생성 실패 1개: `compensation-blocked`.
- 활성 일정 구간 겹침 0, 음수 잔액 0, 일정 COMPLETED 수와 자원 완료 수의 차이 0.

이 불일치는 의도한 실패의 증거라 자동 정리하지 않았다. 전체 21 PASS는 복구 시스템 완성을 뜻하지 않는다. 합성 정수 금액을 실제 손실로 환산하지 않는다.

### 별도 실행·품질·보존

- 두 module 각각 `go test -count=1 ./...`, `go test -race -count=1 ./...`, `go vet ./...` 통과. Go 단위 각 4개, 합계 8개다. Linux arm64 바이너리와 각 Docker 이미지를 빌드했고 실제 실행 바이너리 SHA를 기록했다. Docker 21개 판정은 일반 빌드이며 분산 부하 중 Race 빌드를 실행한 것은 아니다.
- Python 외부 더블 단위 4개 통과. PG 승인·거절·환불 멱등·실패·입력 경계, Slack 경로별 간격·Retry-After·입력을 확인한다.
- 각각 별도 `go run .`을 loopback 18094/18095에 실행해 health와 실제 자기 DB 조회 5개를 확인했다. host smoke 원본 (로컬: `results/2026-10-24-host-smoke/responses.json`), 환경·소스 SHA (로컬: `results/2026-10-24-host-smoke/environment.json`). 임시 프로세스는 Ctrl-C로 종료했고 Docker의 18090/18091 서비스는 유지했다. 전체 21개를 host 모드로 반복한 것은 아니다.
- Web: content:check(공개 글 0), lint·format:check·15개 test·typecheck·build 통과. 기존 UI·콘텐츠 소스는 수정하지 않았다. 첫 Go 글 draft:true 유지.
- Legacy API: 1개 test·typecheck 통과. Node 26에서 실행했으며 CI Node 22는 이번에 검증하지 않았다. 원격 D1·Cloudflare 작업 없음.
- 실행 후 수정은 문서·요약 계산기와 source snapshot에서 로컬 `.env`/`.env.*`를 제외하는 안전 보완이다. `.env.example`은 유지한다. 해당 경계의 assert 검사도 실행했다. 실행 당시 raw/소스 사본은 변경하지 않는다.

### Interpretation / 남은 질문

언어를 Go로 바꿔도 두 DB와 PG·Slack의 외부 효과는 원자적으로 묶이지 않는다. 행 잠금·멱등 취소가 맞아도 보상 실패, 역콜백 유실, Slack 429는 별개로 남았다. [Go/Spring 비교](GO-AND-SPRING.md)는 트랜잭션·SQL 실행 시점·HTTP 대기·commit 자원 반환·goroutine과 executor·지속 전달의 경계를 현재 파일에 연결한다.

이번에는 해결책을 한꺼번에 추가하지 않았다. 다음 후보는 확정 실패/미확정 결과를 구분하는 PG 보상, 지속 보상·역콜백 재처리, 알림 제한 대응이다. 후속 연구는 사용자가 선택한다. 사용자가 실제로 설명한 이해·숙달은 아직 기록하지 않는다.

### Unverified / 종료 상태

- 현재 계약은 엄격한 슬롯 보호·UTC 일자·합성 가격/잔액이다. 구체 업무의 관리자 예외·이용권·가격/환불 정책·인증/권한·전체 Java 랩과의 동치성은 검증하지 않았다.
- Spring/JPA의 같은 장애를 Java로 재실행하거나 Go와 같은 자원 조건의 처리량·p95를 비교하지 않았다. 브라우저 검증도 이번에는 수행하지 않았다. 웹은 자동 회귀만 확인했다.
- v1/v2의 commit guard·commit 직후 연결 단절 사례를 v3 제품 코드에 다시 넣지 않았다. 실제 commit 실패·응답 유실·환불 결과 미확정·PG 중복 웹훅·프로세스 재시작 이후 복구·장시간 부하는 미검증이다.
- DB named volume은 유지되지만 PG/Slack은 메모리다. 더블 재생성 후의 상태 일관성·내구성은 구현하지 않았다. 현재 실패 상태와 raw는 사용자 검토를 위해 보존한다.
- 커밋·Push·PR·배포·새 글·운영 리소스 변경 없음. 로컬 전용 컨테이너 6개를 유지하고 추가 구현을 멈춘다.

## v4 구조 정리 기록 — 2026-10-24 완료

사용자는 Go 서버의 권장 배치와 net/http·pgx 등 최소 의존성으로 두 프로젝트 전체를 정리하길 요청했다. 이는 새 실패 모드 연구나 복구 해법 추가가 아니라 구조 개선과 회귀 검증이다. 계획·경계는 [PLAN v4](PLAN.md#v4--go-서버의-책임패키지-구조-정리--2026-10-24)를 따른다.

### 변경과 판단 근거

- 두 module 각각 `cmd/server/main.go`와 `internal/app`, `internal/httpapi`, `internal/client`, 업무별 `internal/booking` 또는 `internal/schedule`로 분리했다.
- app은 환경·pool·구체 객체 조립·HTTP 시작/종료, httpapi는 라우팅·JSON·HTTP 오류 변환, 업무 Service는 트랜잭션·외부 효과·상태 전이·보상, 같은 업무 패키지의 구체 Store는 SQL·DB 잠금을 담당한다.
- 외부 HTTP 경계에만 소비자 interface를 둔다. 범용 repository·UnitOfWork·DI container·ORM을 추가하지 않았다. 업무 패키지는 net/http를 import하지 않고 HTTP 패키지는 SQL을 실행하지 않는다.
- service의 Begin/Commit/defer rollback을 명시해 잠금·원격 왕복 범위가 보인다. 오류 반환 시 tx 정리는 Service 반환 전에 끝나고, HTTP 응답 작성은 그 뒤다. 기존에는 HTTP handler의 defer였다. commit 전/후 호출 순서와 timeout은 유지했고 이를 성능 개선으로 주장하지 않는다.
- 업무 오류 종류와 보상 결과를 HTTP 패키지에서 상태코드·JSON으로 변환한다. 내부 SQL 오류는 안정적인 오류 코드로 감추며, false인 보상 결과도 누락하지 않도록 검증했다.
- schema/fixture는 각 `db/`로 옮겼다. v3와 schema·fixture·go.mod/go.sum의 SHA가 동일함을 확인했다. Compose mount와 `scripts/build.sh`를 갱신했으며 실행은 `go run ./cmd/server`다. 별도 migration 도구는 도입하지 않았다.
- native pgx/pgxpool로 현재 PostgreSQL·명시적 SQL·tx 요구를 처리하므로 sqlx를 설치하지 않았다. sqlx는 database/sql 확장이고 필수 추가 계층이 아니다. Go 공식 cmd/internal 배치와 이 프로젝트가 선택한 책임 분리를 구분한다. [Go 지침](https://go.dev/doc/modules/layout#server-project), [pgx 선택](https://github.com/jackc/pgx#choosing-between-the-pgx-and-databasesql-interfaces), [sqlx](https://jmoiron.github.io/sqlx/)

### 보존·실행 근거

- 구조 변경 전 v3 raw/실행 소스 SHA를 확인했다. v3 최종 상태 스냅샷 (로컬: `results/2026-10-24-v3-preserved/manifest.json`)에 두 합성 DB 전체 SQL과 PG/Slack 상태·명령·SHA를 보존한 뒤 이 랩만 새 fixture로 초기화했다. 기존 원본·보류 초안·다른 랩은 변경하지 않았다.
- 새 회귀 명령: `python3 scripts/verify.py --session 2026-10-24-02-structure`.
- 원본 21개 판정 (로컬: `results/2026-10-24-02-structure/run.jsonl`), HTTP 기록 (로컬: `results/2026-10-24-02-structure/http.jsonl`), 환경·실행 소스/바이너리 SHA (로컬: `results/2026-10-24-02-structure/environment.json`), 완료 상태·원본 SHA (로컬: `results/2026-10-24-02-structure/status.json`), 당시 소스 (로컬: `results/2026-10-24-02-structure/source/`)를 보존했다. `status.json.state=valid`, 21/21이다.
- `python3 scripts/summarize.py 2026-10-24-02-structure`로 요약 (로컬: `results/2026-10-24-02-structure/summary.json`)을 생성했다. 입력 raw·계산 스크립트 hash를 기록하고 기존 자료를 덮어쓰지 않았다.
- HTTP 경로·핵심 JSON/상태코드·중복 차감/환급·잠금 순서·상태 전이·외부 실패/보상 시나리오를 같은 21개 판정으로 확인했다. 새 성능 조건이나 복구 구현을 추가한 비교가 아니다.

### 관측·한계

동시 webhook 100건은 1 수락/99 거절, 예약 실패 100건은 모두 422·원격 보상 취소·로컬 rollback이었다. 실패 알림은 6 수락/94 거절이다. 이전과 같은 숫자가 나왔다는 사실을 실행 시간이 동등하거나 통계적으로 동일하다는 증거로 삼지 않는다.

최종 로컬 10행·일정 116행, 상태 불일치 2개(`callback-loss`, `refund-failure`), 원격에만 활성 1개(`compensation-blocked`)가 유지됐다. 겹침·음수 잔액·완료 수 불일치 0이다. 구조를 나눴다고 best-effort 보상·역콜백의 내구성이 생기지 않았다. 21 PASS는 예상 실패 재현을 포함한다.

### 품질 검사

- 각 module `go test -count=1 ./...`, `go test -race -count=1 ./...`, `go vet ./...` 통과. 기존 Go 단위 8개를 새 책임 패키지로 옮겼고, 설정·오류 JSON·HTTP 응답/Body 정리·Context·PG 금액/상태·원격 성공/거절/미확정·callback 계약 검사를 추가했다. Go top-level 테스트 함수는 합계 19개(booking 10, schedule 9; 설정 subtest 별도)다. DB/돈/상태 경합은 mock DB 대신 실제 21개 통합 판정으로 확인했다.
- 초기 테스트 이동 중 private `validate`를 export한 이름으로 맞추지 못해 컴파일 오류가 있었고 수정했다. 검증을 삭제하거나 비활성화하지 않았다. 최종 plain/race/vet는 두 module 모두 통과했다.
- 새 `./cmd/server`를 Linux arm64로 각각 빌드하고 각 Docker 이미지로 기동했다. Docker의 21개 판정은 일반 빌드이며 Race 빌드로 분산 부하를 실행한 것은 아니다.
- 각각 `go run ./cmd/server`를 임시 loopback 18094/18095에서 실행해 health·자체 DB 조회 5개를 확인했다. host smoke (로컬: `results/2026-10-24-structure-host-smoke/responses.json`), 소스·실행 모드 (로컬: `results/2026-10-24-structure-host-smoke/environment.json`). 확인 후 두 임시 프로세스만 종료했고 Docker 서비스는 유지했다.
- Python 더블 단위 4개, Web content:check/lint/format:check/15개 test/typecheck/build, Legacy API 1개 test/typecheck 통과. Node 26이며 API CI Node 22와 이번 브라우저 검증은 미실행이다. 공개 글 0·첫 글 draft:true 유지.
- 최종 보존 검사에서 기존 파일 348개가 동일했고, 원본·소스 사본·스냅샷·요약 입력 등을 포함한 SHA 검사 749개가 일치했다. 현행 문서의 상대 파일 링크와 gofmt, 환경 예시/비밀 설정 ignore, 개인정보·로컬 절대 경로, 추가 dependency 여부를 확인했다. Git HEAD는 66657d1 그대로다. Docker 6개는 healthy이며 임시 18094/18095 listener는 종료됐다. 기존 v3 자료는 과거 근거이므로 당시 소스 사본의 경로나 실행 명령을 현재 기준으로 덮어쓰지 않았다.

### 종료 경계

실 PG/Slack·Java 같은 조건 비교·장시간 부하·commit/응답 유실의 모든 순서·지속 보상·재시작 복구는 여전히 미검증/미구현이다. Spring 역할과 Go 코드의 대응은 [비교 문서](GO-AND-SPRING.md)에 연결했다. 사용자 이해·학습 완료는 대신 선언하지 않는다.

커밋·Push·PR·배포·운영 리소스 변경 없이 로컬 구조 개선을 마친다. 다음 연구·기능·배포는 진행하지 않는다.

## v5 Go 코드 단순화 기록 — 2026-10-24 완료

조사한 Go의 패키지·interface 원칙을 바탕으로 단순하고 명확한 코드로 정리해 달라는 사용자 지시로 진행했다. [PLAN v5](PLAN.md#v5--go다운-이름공개-범위단일-소비자-패키지-정리--2026-10-24)의 구조 개선·회귀 범위만 수행했고 기능·보상 해법·새 연구를 추가하지 않았다.

### 변경과 의도

- 각 서버의 단일 소비자 `internal/app`을 `cmd/server/run.go`·`config.go`로 합쳤다. 설정 테스트도 같은 패키지로 이동해 유지했다. Go 패키지 수는 module당 5개에서 4개(cmd 포함)로 줄었다. main이 signal/health를 처리하고 run이 환경 검증·pool 수명·직접 조립·HTTP 시작/종료를 맡는다. 기존 `go run ./cmd/server`와 Docker health 명령은 그대로다.
- 업무 Service는 의미 있는 실행 순서가 있어 유지했다. Store/NewStore를 패키지 밖에 노출하지 않고 `NewService(db, ...)`가 비공개 구체 `store`를 구성하도록 줄였다. DB pool의 생성·종료는 cmd가 맡는다. Repository interface·UnitOfWork·DI container·공유 프레임워크를 도입하지 않았다.
- 외부 호출 interface는 사용하는 `service.go` 옆의 비공개 선언으로 옮겼다. 구현을 명시적으로 등록하는 코드 없이 실제 client가 메서드 집합으로 연결된다. 역할마다 별도 interface/Impl 패키지를 추가하지 않았다.
- `model.go`는 `booking.go`/`appointment.go`, `store.go`는 `postgres.go`로 바꿨다. 모델·입력 규칙, 업무 흐름, PostgreSQL SQL/잠금/오류 변환, 업무 오류를 구분했다. Store가 Repository 역할을 담당한다는 사실과 interface 추상화 유무를 구분한다.
- 실제 `*http.Client`를 transport라고 부르던 지역 이름을 httpClient로 바로잡고 생성자 연결을 여러 줄로 읽을 수 있게 했다. 일정 서버의 사용하지 않는 pg 설정 필드를 제거했다.
- 두 독립 module·net/http·native pgx/pgxpool을 유지했다. Service는 여전히 PostgreSQL 트랜잭션에 의존하며 엄격한 Clean Architecture나 DB 교체 가능성을 주장하지 않는다. 다른 랩·웹·API·root의 기존 미커밋 변경·보류 draft는 수정하지 않았다.

### 실행·보존 근거

구조 변경 전 v4 소스를 로컬 복구 사본으로 보존했다. v4 raw/실행 소스는 결과 폴더의 원본을 유지했다. v4 최종 합성 상태 (로컬: `results/2026-10-24-v4-preserved/manifest.json`)에 두 DB 전체 SQL과 PG/Slack 상태·명령·SHA를 보존한 뒤 이 Compose 프로젝트만 새 fixture로 기동했다. 다른 프로젝트 컨테이너나 실제 회사·운영 자원은 변경하지 않았다.

코드 비교에서 Service의 기존 업무 메서드 본문은 Ready의 private 이름 변경을 제외하고 동일했다. SQL 문자열·schema/fixture·go.mod/go.sum·외부 client 소스와 모델 테스트 내용이 동일했다. 이 정적 비교와 별도로 실제 회귀를 수행했다.

실행 명령(labs/booking-compensation 기준):

```sh
# 각 booking-api / schedule-api에서
GOCACHE=/private/tmp/booking-compensation-go-cache go test -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go test -race -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go vet ./...

# 랩 루트에서; 기존 합성 상태 보존 후 해당 프로젝트만 초기화
GOCACHE=/private/tmp/booking-compensation-go-cache sh scripts/build.sh
docker compose down -v
docker compose up -d --no-build --wait --wait-timeout 60
python3 scripts/verify.py --session 2026-10-24-03-idiomatic
python3 scripts/summarize.py 2026-10-24-03-idiomatic
python3 -m unittest discover -s stubs -p 'test_*.py'
```

- Go top-level 단위 테스트 19개(booking 10·schedule 9; 설정 subtest 별도)를 삭제/비활성화하지 않고 유지했다. 두 module 모두 test/race/vet 통과. Linux arm64 바이너리와 Docker 이미지 빌드·기동 통과. 분산 통합 부하는 일반 바이너리이며 race 바이너리로 부하를 실행한 것은 아니다.
- 21개 HTTP·독립 DB 판정 (로컬: `results/2026-10-24-03-idiomatic/run.jsonl`) 전부 통과, status (로컬: `results/2026-10-24-03-idiomatic/status.json`)의 state=valid, cases=passed=21이다. HTTP 기록 (로컬: `results/2026-10-24-03-idiomatic/http.jsonl`), 명령·실행 소스/바이너리/image 식별자 (로컬: `results/2026-10-24-03-idiomatic/environment.json`), 실행 당시 소스 (로컬: `results/2026-10-24-03-idiomatic/source/`)와 원본 SHA를 보존한다. case checkpoint인 progress와 전체 완료 판정인 status의 역할은 구분한다.
- Python 외부 더블 단위 4개 통과. Web content:check(공개 글 0)·lint·format:check·15개 test·typecheck·build 통과. Legacy API 1개 test·typecheck 통과. API 첫 시도는 sandbox loopback listen EPERM으로 시작하지 못했고, 허용된 로컬 런타임 재실행에서 통과했다. Node 26.9.0이며 API CI Node 22는 미검증이다.
- 두 서버를 각각 `go run ./cmd/server`로 임시 loopback 18094/18095에 실행해 health·자기 DB 조회 5개를 확인했다. 읽기 전용 응답 (로컬: `results/2026-10-24-idiomatic-host-smoke/responses.json`)과 명령·환경·소스 SHA (로컬: `results/2026-10-24-idiomatic-host-smoke/environment.json`)를 보존했다. 임시 프로세스와 listener는 종료했고 Docker 6개는 healthy 상태로 유지했다.
- 최종 검사에서 기존 보존 목록 348개와 이번 작업 전 결과/소스 사본·root 변경·초안 목록 321개가 그대로였다(두 목록은 일부 겹친다). 원본·당시 소스·스냅샷·요약/현재 실행 코드 SHA 검사 484개가 일치했다. 현행 문서의 상대 파일 링크·ignore·개인 경로/비밀 정보 패턴·Git 대상의 바이너리/로컬 env 부재를 확인했다. 결과 합계는 약 2.87MiB다. 실행 뒤 변경은 비교 문서와 이 기록뿐이며 raw/당시 소스는 수정하지 않았다. HEAD 66657d1·브랜치·기존 root 미커밋 변경을 유지하고 첫 Go 글 draft:true를 보존했다.

### 관측과 종료 경계

요약 (로컬: `results/2026-10-24-03-idiomatic/summary.json`)은 입력 raw와 기존 계산 스크립트 SHA를 기록한다. 동시 webhook 100건은 수락 1·429 99, 예약 실패 100건은 모두 422·원격 보상 취소·로컬 rollback, 해당 실패 알림은 수락 6·거절 94였다. 최종 로컬 예약 10행·일정 116행, 연결된 상태 불일치 2개·원격에만 활성 일정 1개가 남았다. 겹침·음수 잔액·완료 수 불일치는 0이다.

이는 기존 정상/예상 실패가 유지됐다는 관측이다. 같은 합계가 성능 동등성이나 병목 해결의 증거는 아니다. 보상 실패·역콜백 유실·Slack 429는 해결하지 않았으며 21 PASS를 자동 복구 완성으로 읽지 않는다.

실 PG/Slack·Java 동등 실행·운영 부하·지속 재처리·재시작 복구·모든 commit/응답 유실 순서는 이번에도 미검증/미구현이다. 브라우저 검증은 수행하지 않았고 웹은 기존 자동 검사만 확인했다. 사용자 이해·학습 완료를 대신 선언하지 않는다.

커밋·Push·PR·배포·새 글·운영 자원 변경 없이 로컬 리팩터링과 검증 범위에서 멈춘다.

## v6 Booking API 흐름별 파일 분리 기록 — 2026-10-24 완료

사용자는 booking-api의 scheduler/payments/notifier 선언과 모델·검증·여러 테이블의 트랜잭션 저장 관계를 질문하고, 본인과 다른 독자가 코드를 설명하기 쉽도록 목적별 파일 분리를 요청했다. [PLAN v6](PLAN.md#v6--booking-api를-요청-흐름별로-읽기--2026-10-24)에 따라 booking-api의 파일 배치와 읽기 안내를 정리했다. 사용자 이해·숙달을 확인했다고 기록하지 않는다.

### 변경과 설명의 경계

- 기존 booking.Service 하나를 유지하며 dependencies.go(3개 외부 소비자 interface), create.go(생성·로컬 저장/PG 확인·생성 보상), cancel.go(취소·로컬/PG 환불), callbacks.go(일정 서버 역콜백), service.go(조립·공통 조회·알림)로 나눴다. 다른 package나 Service/Repository 타입을 추가하지 않았다. 일정 API 소스는 변경하지 않았다.
- 실제 HTTP 구현은 기존 internal/client의 schedule.go/payment.go/slack.go에 그대로 있다. interface 선언을 결제·사용자 등의 데이터 모델이나 실제 외부 서버 구현과 구분했다. Go의 소비자 패키지 권고는 Service와 반드시 한 파일에 두라는 규칙이 아니다.
- save를 saveAndVerifyPayment로, refund를 cancelAndRefund로 이름을 바꿨다. 함수 14개의 서명/본문을 변경 전과 비교해 두 private 이름을 제외하고 동일함을 확인했다. 초기 이동 도구의 사전 선언수 검사에서 잘못 기대한 16개 대신 실제 14개를 확인해 바로잡았으며, 그 검사 중단 전에는 소스 이동을 수행하지 않았다. 최종 Go 검사에는 실패나 비활성화가 없다.
- [Booking API 안내](booking-api/README.md)에 읽을 파일·정상 생성 흐름도·입력 검증/tx 안의 최신 상태 검증·SQL/외부 효과 경계·테이블별 현재 읽기/쓰기 형태를 연결했다. 기존 지침을 새로 만들지 않았다.
- 생성 API는 PG 승인을 새로 실행하지 않고 앱이 이미 승인한 상태/금액을 확인한다. 예약·사용자 잔액·원장·결제 참조 SQL은 같은 로컬 tx를 받지만 외부 일정/PG가 그 tx에 참여하지는 않는다. 이 구분은 AI가 코드와 근거를 읽고 제공한 설명이며 사용자가 자기 말로 확인한 이해와 구분한다.
- Booking의 입력/조회 재사용과 서버 필드 검증이라는 현재 절충을 명시했다. 사용하지 않는 테이블별 엔티티·DTO·변환 계층을 추가하지 않았다. 늦은 잔액 검사·commit 실패 공백·생성 실패 PG 자동 환불 부재·best-effort 전달 등 기존 기준선도 유지했다.

### 보존과 검증

v5 최종 합성 상태 스냅샷 (로컬: `results/2026-10-24-v5-preserved/manifest.json`)에 두 DB 전체 SQL·PG/Slack 상태·명령·SHA를 보존한 뒤 이 Compose 프로젝트만 새 fixture로 기동했다. 기존 실패/유효 원본·실행 당시 소스·다른 랩·보류 초안·root 미커밋 변경을 보존했다.

실행 명령(labs/booking-compensation 기준):

```sh
# 두 module 각각
GOCACHE=/private/tmp/booking-compensation-go-cache go test -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go test -race -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go vet ./...

# 랩 루트에서; 현재 합성 상태 보존 후 해당 프로젝트만 초기화
GOCACHE=/private/tmp/booking-compensation-go-cache sh scripts/build.sh
docker compose down -v
docker compose up -d --no-build --wait --wait-timeout 60
python3 scripts/verify.py --session 2026-10-24-04-workflows
python3 scripts/summarize.py 2026-10-24-04-workflows
python3 -m unittest discover -s stubs -p 'test_*.py'
```

- Go 단위 19개(booking 10·schedule 9) 유지, 두 module test/race/vet 통과. Python 더블 4개 통과. Linux arm64 빌드와 Docker 기동 통과. 일정 API 이미지는 기존과 같으며 booking 이미지는 새 파일 배치를 반영한다.
- 통합 원본 (로컬: `results/2026-10-24-04-workflows/run.jsonl`), HTTP 기록 (로컬: `results/2026-10-24-04-workflows/http.jsonl`), 환경·소스/바이너리/image SHA (로컬: `results/2026-10-24-04-workflows/environment.json`), 실행 당시 소스 (로컬: `results/2026-10-24-04-workflows/source/`), 완료 상태·원본 SHA (로컬: `results/2026-10-24-04-workflows/status.json`)를 보존했다. state=valid, 21/21 PASS다. checkpoint의 progress와 최종 status의 역할은 구분한다.
- Web content:check(공개 글 0)·lint·format:check·15개 test·typecheck·build, Legacy API 1개 test·typecheck 통과. Node 26.9.0이고 API CI Node 22는 미검증이다. 첫 Go 글 draft:true 유지. 배포·운영 접근 없음.
- 이번에는 별도 host go run을 재실행하지 않았다. 실행 진입점·설정은 그대로이고 새 일반 바이너리를 Docker에서 실행했다. 기존 v5 host 실행 기록은 보존하지만 이번 실행의 증거로 대체하지 않는다. 분산 통합 부하에 race 바이너리를 사용한 것도 아니다.

계산 요약 (로컬: `results/2026-10-24-04-workflows/summary.json`)은 입력 raw·기존 계산기 SHA를 기록한다. webhook 100건은 수락 1/429 99, 예약 실패 100건은 모두 422·원격 보상 취소·로컬 rollback, 실패 알림은 수락 6/거절 94였다. 최종 로컬 10행·일정 116행, 연결 상태 불일치 2개·원격에만 활성 일정 1개가 남고, 활성 겹침·음수 잔액·완료 수 불일치는 0이다.

최종 보존 목록 348개와 이번 작업 전 목록 432개(일부 중복)가 동일했다. 원본·당시 소스·현재 실행 코드·요약·스냅샷 SHA 검사 539개가 일치했다. 문서 상대 파일 링크·ignore·Git 대상의 바이너리/로컬 env 부재·개인 경로/비밀 정보 패턴을 확인했다. 결과 폴더 합계는 약 3.65MiB이고 Docker 6개는 healthy다. HEAD 66657d1·브랜치·기존 root 변경을 유지했으며 실행 뒤에는 비교 문서와 이 기록만 갱신했다.

21 PASS는 기존 정상과 예상 실패가 유지됐다는 뜻이다. 성능 향상·보상 자동 복구·사용자의 학습 완료를 뜻하지 않는다. 실 PG/Slack·Java 동등 실행·운영 부하·지속 재처리·재시작 복구·브라우저는 미검증이다. 커밋·Push·PR·배포·새 글·추가 연구 없이 이 파일 분리와 설명 범위에서 멈춘다.

## v7 PostgreSQL 책임 분리 기록 — 2026-10-24 완료

사용자는 책임별 SQL 분리와 Service에서 저장 순서를 읽을 수 있는 구성을 승인하고, 연관된 로컬 로직이 모두 실행된 뒤 commit하도록 개선을 요청했다. [PLAN v7](PLAN.md#v7--postgresql-책임-분리와-service의-저장-순서--2026-10-24)의 booking-api 로컬 리팩터링과 검사 범위만 수행했다.

### 구조와 의미

- 같은 booking 패키지·비공개 store 타입 하나를 유지하고 postgres.go(공통 tx/DB 오류), postgres_booking.go(예약), postgres_user.go(사용자 잔액/포인트 원장), postgres_payment.go(로컬 결제 참조)로 SQL을 나눴다. Repository/interface/UnitOfWork/ORM·새 의존성은 추가하지 않았다. 예약 조회의 결제 JOIN은 예약 조회 응답에 필요한 SQL로 유지한다.
- insertAndDebit를 insertBooking + 조건부 debitPoints로, cancelAndCredit를 markCancelled + 조건부 creditPoints로 나눴다. create.go/cancel.go의 Service가 같은 tx를 넘기며 실행 순서를 총괄한다. 포인트 잔액과 원장 두 쓰기는 사용자 책임 안에서 함께 처리한다.
- 취소와 콜백 Service에서 bookingUserID → lockUser → lockBooking을 명시했다. 첫 키 조회 후 사용자→예약 행 순서로 잠그고 최신 예약 상태를 읽는다. 이전 사용자 id FOR UPDATE 대신 기존 lockUser의 points FOR UPDATE를 재사용한다. SQL 비교상 이 중복 id 잠금 쿼리만 제거됐고 나머지 SQL 문자열·schema/fixture·go.mod/go.sum은 동일했다.
- 로컬 쓰기는 모두 전달된 pgx.Tx를 사용하고, 책임별 SQL 메서드는 Begin/Commit하지 않는다. Service가 기존 위치에서 한 번 commit하며 실패 시 기존 별도 정리 Context의 defer rollback을 수행한다. 이미 취소된 예약의 읽기 전용 중복 취소는 이전처럼 쓰기 없이 tx를 정리한다.
- 입력/잔액 검증·PG 확인/환불·원격 일정 호출·보상/역보상·commit 뒤 Slack 순서를 유지했다. 로컬 rollback이 PG/원격 DB를 되돌리거나 알림 전달을 보장한다고 주장하지 않는다. API 경로·JSON·오류 코드·금액·DB 제약·pool/timeout은 유지했다.
- 일정 API·웹·Legacy API·다른 실험·원본/보류 초안·root의 기존 미커밋 변경을 수정하지 않았다. [Booking README](booking-api/README.md)에 저장 파일과 Service 순서를 연결했다. 사용자 이해·학습 완료를 대신 선언하지 않는다.

### 실제 DB 저장 경계 검사

postgres_integration_test.go를 추가했다. BOOKING_TEST_DATABASE_URL이 없으면 이 새 테스트만 skip되며 기존 단위 검사는 유지한다. 이번에는 전용 loopback 15490/bookings/lab URL을 명시해 **plain과 race 양쪽에서 실제로 실행**했다. 임시 무작위 스키마에서 실제 schema.sql을 사용하고, PG/일정/알림만 Go 더블로 대체했다. 기존 public 합성 테이블에는 쓰지 않았다.

1. 차감 원장 INSERT에 CHECK 오류를 발생시켜 앞선 예약 INSERT·잔액 UPDATE가 함께 rollback되고 보상 호출이 수행되는지 확인했다.
2. PG 확인 메서드가 호출되는 시점에 별도 pool 연결로 조회해 예약·결제·잔액·원장 변경이 아직 공개되지 않음을 확인했다. 성공 반환 뒤 모두 공개된 것도 확인했다. 그 예약의 환급 원장 INSERT에 CHECK 오류를 발생시키자 예약 취소·잔액 환급이 함께 rollback됐고, PG 환불 전에 중단·역보상 호출이 수행됐다.
3. 포인트 0원 생성·취소가 원장을 만들지 않고 반복 취소가 PG 환불을 한 번만 호출하는지 확인했다.

기존 Go top-level 단위 19개를 유지했고 새 통합 parent 1개/하위 상황 3개를 추가했다. booking 11개·schedule 9개 parent 테스트다(기존 설정 subtest 별도). 두 module test/race/vet, 실제 DB 3상황 통과. 해당 3상황은 실제 PG/일정 서버 통합 검증을 대신하지 않는다.

첫 plain/race/vet 원본 (로컬: `results/2026-10-24-storage-tests/status.json`), 당시 소스 SHA·명령 (로컬: `results/2026-10-24-storage-tests/environment.json`)을 보존했다. API 21개 실행 이후 fixture helper가 setup 오류를 현재 subtest에 보고하도록 testing.T를 명시적으로 전달하는 보완만 했다. 이 변경은 테스트 파일뿐이며 서비스 코드는 동일하다. 그 뒤 현재 소스의 plain/race/vet 재확인 (로컬: `results/2026-10-24-storage-tests-02/status.json`)·명령/소스 SHA (로컬: `results/2026-10-24-storage-tests-02/environment.json`)도 모두 통과했다. 첫 통과 자료를 덮어쓰거나 API 회귀를 불필요하게 반복하지 않았다.

재현 명령(booking-api):

```sh
export BOOKING_TEST_DATABASE_URL='postgres://lab@127.0.0.1:15490/bookings?sslmode=disable'
export GOCACHE="${TMPDIR:-/tmp}/booking-compensation-go-cache"
go test -count=1 -v ./...
go test -race -count=1 ./...
go vet ./...
```

### 기존 두 서버 회귀와 보존

실제 DB 테스트의 임시 스키마가 남지 않았음을 확인하고 v6 최종 상태 (로컬: `results/2026-10-24-v6-preserved/manifest.json`)에 두 DB 전체 SQL·PG/Slack 상태·정리 조회/명령/SHA를 보존했다. 그 뒤 이 Compose 프로젝트만 새 fixture로 재구성했다.

```sh
# labs/booking-compensation에서, 기존 합성 상태 보존 후
GOCACHE=/private/tmp/booking-compensation-go-cache sh scripts/build.sh
docker compose down -v
docker compose up -d --no-build --wait --wait-timeout 60
python3 scripts/verify.py --session 2026-10-24-05-storage
python3 scripts/summarize.py 2026-10-24-05-storage
python3 -m unittest discover -s stubs -p 'test_*.py'
```

- Linux arm64 빌드·Docker 기동, HTTP/독립 DB 21개 판정 (로컬: `results/2026-10-24-05-storage/run.jsonl`) 전부 통과. 완료 상태/원본 SHA (로컬: `results/2026-10-24-05-storage/status.json`)는 valid·21/21이고 환경/실행 소스/바이너리/image SHA (로컬: `results/2026-10-24-05-storage/environment.json`), 당시 소스 (로컬: `results/2026-10-24-05-storage/source/`), HTTP 기록 (로컬: `results/2026-10-24-05-storage/http.jsonl`)을 보존한다. 당시 소스의 테스트 helper는 첫 버전이며 현재 최종 테스트 파일은 위 두 번째 Go 검사에 연결된다. 실행 서비스 소스는 변하지 않았다.
- Python 외부 더블 4개 통과. Web content:check(공개 글 0)·lint·format:check·15개 test·typecheck·build, Legacy API 1개 test·typecheck 통과. Node 26.9.0이고 API CI Node 22·이번 브라우저·별도 host go run은 미검증이다. 첫 Go 글 draft:true 유지.
- 계산 요약 (로컬: `results/2026-10-24-05-storage/summary.json`)은 raw/기존 계산기 SHA를 포함한다. webhook 100건은 수락 1/429 99, 예약 실패 100건은 모두 422·원격 보상 취소·로컬 rollback, 실패 알림 수락 6/거절 94였다. 최종 로컬 예약 10행·일정 116행, 연결 상태 불일치 2개·원격에만 활성 일정 1개가 남았다. 활성 겹침·음수 잔액·완료 수 불일치는 0이다. 이는 기존 정상/예상 실패가 유지됐다는 관측이며 성능 향상·자동 복구 완성의 증거가 아니다.

최종 검사에서 기존 보존 목록 348개와 이번 작업 전 목록 519개(일부 중복)가 동일했다. 원본·소스 사본·현재 서비스 코드·첫/재확인 Go 검사·요약·스냅샷 SHA 검사 695개가 일치했다. 최종 Go 검사 원본은 현재 테스트 소스와 연결되고 API 판정 원본은 당시 테스트 소스와 연결된다. 문서 상대 파일 링크·gofmt·ignore·개인 경로/비밀 정보 패턴과 Git 대상의 바이너리/로컬 env 부재를 확인했다. 결과 합계는 약 4.53MiB다. 추가 DB 검사 뒤 다시 조회한 임시 스키마 목록은 비었고 Docker 6개는 healthy다. HEAD 66657d1·브랜치·기존 root 변경과 보류 초안을 유지했다.

실 PG/Slack·Java 동일 조건 실행·운영 부하·지속 재처리·재시작 복구·모든 commit/응답 유실 순서는 계속 미검증/미구현이다. 새 후속 실험·글·커밋·Push·PR·배포·운영 리소스 변경 없이 이 저장 책임 개선을 마친다.

## v8 Schedule API 구조 정리 기록 — 2026-10-24 완료

사용자는 booking-api를 참고해 다른 서버도 구조를 개선하도록 요청했다. [PLAN v8](PLAN.md#v8--schedule-api의-업무저장-파일-정리--2026-10-24)의 대상은 schedule-api다. 같은 원칙으로 역할별 파일과 private 이름을 정리했고 새 기능·정책·복구 해법은 추가하지 않았다.

- 같은 schedule 패키지·Service/store 타입을 유지했다. service.go는 조립·조회, dependencies.go는 callback/notifier 계약, create.go·cancel.go(복원 포함)·complete.go·reschedule.go는 업무별 tx/순서, callbacks.go는 commit 후 전송을 맡는다. httpapi/client 경계와 앱 조립은 그대로다.
- SQL은 postgres.go(공통 tx/오류), postgres_appointment.go(일정/이력), postgres_resource.go(자원/UTC 일자 advisory lock·완료 수)로 묶었다. 함께 저장하는 일정 상태와 이력을 같은 책임으로 두고 테이블마다 Repository를 만들지 않았다.
- insert/lock/event/countCompleted/available 등 private 이름을 insertAppointment/lockAppointment/recordEvent/adjustCompletedCount/checkAvailability로 명확히 했다. publish는 dispatchCallback으로 바꿨다. 실제 HTTP 계약·SQL·모델·스키마·pool/timeout·의존성은 변경하지 않았다.
- Service 9개·store 16개 함수의 서명/본문을 private 이름·gofmt 정렬을 정규화해 변경 전과 대조했다. 모두 동일했다. 최초 단순 문자열 비교에서는 gofmt의 한 줄 함수 공백 정렬 차이가 있었으므로 개별 함수 포맷을 정규화한 뒤 확인했다. SQL 문자열 전체도 중복 개수를 포함해 동일했다. 함수 호출·잠금·commit·전송 순서를 바꾸지 않았다.
- Service가 같은 tx로 일정 상태·이력·완료 수를 처리하고 기존 위치에서 commit한다. callback은 그 뒤 비동기 best-effort이며 전송 실패가 일정 DB를 rollback하지 않는다. 지속 재시도·재조정이 추가된 것은 아니다.
- [Schedule API 안내](schedule-api/README.md)에 파일별 목적·생성/취소/복원/완료/변경 순서와 콜백 방향을 연결했다. booking-api와 다른 서버의 코드·기존 미커밋 변경·초안·원본은 보존했다. 사용자의 이해/숙달은 대신 선언하지 않는다.

### 검사와 증거

기존 두 module의 Go top-level 검사 20개(booking 11·schedule 9, 설정/DB subtest 별도)를 유지했다. 순수 파일 이동/이름 변경을 위해 같은 테스트를 새로 복제하지 않았다.

```sh
# schedule-api에서
GOCACHE=/private/tmp/booking-compensation-go-cache go test -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go test -race -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go vet ./...

# booking-api에서도 위 검사; plain/race는 실제 DB 검사까지 실행
BOOKING_TEST_DATABASE_URL='postgres://lab@127.0.0.1:15490/bookings?sslmode=disable' GOCACHE=/private/tmp/booking-compensation-go-cache go test -count=1 -v ./...
BOOKING_TEST_DATABASE_URL='postgres://lab@127.0.0.1:15490/bookings?sslmode=disable' GOCACHE=/private/tmp/booking-compensation-go-cache go test -race -count=1 ./...
GOCACHE=/private/tmp/booking-compensation-go-cache go vet ./...
```

두 module test/race/vet 모두 통과했다. booking의 실제 DB 3상황도 skip하지 않고 양쪽 모드에서 실행했다. 임시 스키마가 남지 않았음을 조회하고 v7 최종 합성 상태 (로컬: `results/2026-10-24-v7-preserved/manifest.json`)에 두 DB 전체 SQL·PG/Slack 상태·명령·SHA를 보존한 뒤 이 Compose 프로젝트만 새 fixture로 준비했다.

```sh
# labs/booking-compensation에서; 기존 합성 상태 보존 후
GOCACHE=/private/tmp/booking-compensation-go-cache sh scripts/build.sh
docker compose down -v
docker compose up -d --no-build --wait --wait-timeout 60
python3 scripts/verify.py --session 2026-10-24-06-schedule
python3 scripts/summarize.py 2026-10-24-06-schedule
python3 -m unittest discover -s stubs -p 'test_*.py'
```

Linux arm64 바이너리·Docker 빌드/기동과 기존 21개 HTTP/독립 DB 판정 (로컬: `results/2026-10-24-06-schedule/run.jsonl`) 모두 통과했다. 완료 상태·원본 SHA (로컬: `results/2026-10-24-06-schedule/status.json`)는 valid·21/21이고, 환경/명령/실행 소스/바이너리/image SHA (로컬: `results/2026-10-24-06-schedule/environment.json`), 당시 소스 (로컬: `results/2026-10-24-06-schedule/source/`), HTTP 기록 (로컬: `results/2026-10-24-06-schedule/http.jsonl`)을 보존했다. booking 이미지는 이전과 같고 schedule 이미지만 새 배치를 반영했다. 통합 부하는 일반 바이너리이며 race 바이너리 부하는 아니다.

Python 더블 4개, Web content:check(공개 글 0)·lint·format:check·15개 test·typecheck·build, Legacy API 1개 test·typecheck도 통과했다. Node 26.9.0이며 API CI Node 22·이번 브라우저·별도 host go run은 미검증이다. 첫 Go 글 draft:true와 기존 공개/배포 경계를 유지한다.

요약 (로컬: `results/2026-10-24-06-schedule/summary.json`)은 원본과 기존 계산기 SHA를 기록한다. webhook 100건은 수락 1/429 99, 예약 실패 100건은 모두 422·원격 보상 취소·로컬 rollback, 실패 알림 수락 6/거절 94였다. 최종 로컬 예약 10행·일정 116행, 연결 상태 불일치 2개·원격에만 활성 일정 1개가 남고 활성 겹침·음수 잔액·완료 수 불일치는 0이다. 기존 정상/예상 실패가 유지된 관측이며 성능 향상·자동 복구 완성을 뜻하지 않는다.

최종 보존 목록 348개와 이번 작업 전 목록 636개(일부 중복)가 동일했다. 후자는 booking-api 전체 소스도 포함한다. 원본·당시 소스·현재 실행 코드·요약·스냅샷 SHA 검사 755개가 일치했고 실행 후 변경은 비교 문서와 이 기록뿐이다. 문서 상대 파일 링크·gofmt·ignore·Git 대상의 바이너리/로컬 env 부재·개인 경로/비밀 정보 패턴을 확인했다. 결과 합계는 약 5.33MiB다. Docker 6개는 healthy이고 booking 검사 임시 스키마 목록은 비었다. HEAD 66657d1·브랜치·기존 root 변경과 보류 초안을 유지했다.

실 PG/Slack·Java 동일 조건 실행·운영 부하·지속 전달·재시작 복구·모든 commit/응답 유실 순서는 여전히 미검증/미구현이다. 새 후속 실험·글·커밋·Push·PR·배포·운영 리소스 변경 없이 이 구조 정리를 마친다.
