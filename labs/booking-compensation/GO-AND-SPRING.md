# 두 예약 서버를 Go로 옮겨 읽기

> `results/`는 Git 추적에서 제외한 로컬 실행 증거다. 아래 경로는 기존 로컬 자료를 가리키며 새 clone에는 포함되지 않는다. 재실행 수치는 달라질 수 있어 원본은 보존한다. 과거 기록의 커밋 ID는 이력 정리 전 식별자다.
작은 Go 테스트 도구 자체보다 **외부 결제가 선행된 예약의 실행·실패·보상 경계**를 이해하는 것이 목적이다. 아래는 현재 v8의 두 독립 Go 프로젝트와 Spring 6.2/JPA의 의미를 비교한다. Java를 이 랩에서 실행하거나 같은 조건의 성능을 측정한 결과는 아니다.

## Spring과 구조를 대응해 보기

| 익숙한 Spring 역할 | 현재 Go의 위치 | 차이 |
|---|---|---|
| Controller | `internal/httpapi` | net/http의 명시적 라우팅과 JSON/HTTP 오류 변환 |
| Service / @Transactional | `internal/booking`·`internal/schedule`의 Service | Go 코드에서 Begin/Commit/Rollback을 직접 배치 |
| JPA Repository | 같은 업무 패키지의 비공개 store와 책임별 postgres 파일 | pgx SQL·잠금 쿼리, ORM/영속성 컨텍스트 없음 |
| Boot / DI 설정 | `cmd/server` | 생성자를 직접 호출해 의존성을 연결, component scan 없음 |

역할을 이해하기 위한 대응이지 Go가 Spring과 같은 계층을 강제한다는 뜻은 아니다. `cmd`/`internal` 배치는 [공식 가이드](https://go.dev/doc/modules/layout)를 따르고, 업무·HTTP·외부 호출의 구체 분리는 이 프로젝트의 규모와 테스트 경계에 맞춘 선택이다. sqlx는 database/sql 확장이므로 native pgxpool을 쓰는 현재 구조에는 추가하지 않았다.

v5에서는 한 실행 파일만 쓰는 app 패키지를 cmd로 합치고, Store/NewStore를 비공개 구현으로 줄였다. Service·저장소 역할 자체를 없앤 것이 아니다. Service는 여전히 pgx tx와 잠금 범위를 명시한다. 외부 연동 interface는 사용하는 업무 패키지에 비공개로 선언한다. Go는 interface 구현을 명시하는 등록 코드 없이 메서드 집합으로 연결하므로 별도 Impl/Factory 계층이 필요하지 않다. [Go interface 지침](https://go.dev/wiki/CodeReviewComments#interfaces)

## 코드와 검증을 함께 읽기

| 단계 | Go에서 읽을 곳 | Java/Spring과 비교할 점·연결할 사례 |
|---|---|---|
| 시작·요청 | `cmd/server/main.go` → 같은 패키지의 `run`, `internal/httpapi.NewHandler`, `booking.Service.Create` | Go는 net/http와 pool을 직접 구성하고 `BeginTx`를 호출한다. Spring의 일반적인 `@Transactional` 프록시는 메서드 호출을 감싼다. 프록시를 거치지 않는 자기 호출에 주석만 붙여 새 경계가 생기는 것은 아니다. |
| 사용자 직렬화 | `booking.Service.Create`/`Cancel`, `booking/postgres_user.go`의 `lockUser`와 `postgres_booking.go`의 `lockBooking` | 생성은 사용자 행, 취소는 사용자→예약 행 순서로 잠근 뒤 상태를 읽는다. goroutine/Java 스레드의 메모리 잠금과 **DB 행 잠금**은 다르다. JPA에서도 최종 SQL과 첫 엔티티 조회 시점을 확인해야 한다. `A2`, `A5`를 본다. |
| 선행 가드와 늦은 거절 | `booking/create.go`의 사용자 일정 검사·`saveAndVerifyPayment` 잔액 검사 | 같은 사용자·같은 시간은 원격 호출 전에 거절한다. 서로 다른 시간이어도 잔액은 공유한다. 현재는 잔액 부족을 원격 생성 뒤에 검사하므로 보상 HTTP가 추가된다. `A3`는 정확성뿐 아니라 늦은 검사의 비용을 보여 준다. |
| 일정 점유 | `schedule-api/internal/schedule/postgres_resource.go`의 `lockResourceDays`와 `postgres_appointment.go`의 `checkAvailability` | 자원/UTC 일자 advisory lock 안에서 겹침 검사와 생성이 진행된다. 언어와 무관하게 같은 DB·같은 키로 보호하는 경로끼리만 적용된다. `A1`, `A4`, `A7`, `B-cross-entry`를 본다. |
| HTTP 대기 | 두 프로젝트 `internal/client/http.go`의 `call` | Go의 `Client.Do`는 여기서 동기 호출이다. 기다리는 goroutine의 실행 방식이 Java 스레드와 달라도 열린 tx의 DB 연결·잠금이 저절로 반환되지는 않는다. Java의 플랫폼/가상 스레드·reactive 설정에 따른 차이는 별도다. `D-pool`이 실제 HTTP 대기 중 연결 점유를 보여 준다. |
| 저장·차감 | `booking/create.go`의 `saveAndVerifyPayment` → 책임별 `postgres_*.go`의 SQL | pgx SQL은 호출 지점에서 드러나며 JPA persistence context·dirty checking이 없다. JPA의 save/flush/commit 실패 시점은 전략·SQL·제약에 따라 다르다. 포인트 변경·원장은 로컬 tx에 포함되지만 PG 조회/환불은 외부 HTTP다. |
| 생성 실패 보상 | `booking/create.go`의 `Service.Create`와 `saveAndVerifyPayment` 오류 분기 | Go는 `error` 분기로 원격 삭제를 호출한다. Spring에서는 예외/rollback 규칙과 프록시 경계가 영향을 준다. 어느 쪽도 로컬 rollback이 이미 commit한 다른 DB를 되돌리지 않는다. `C-payment-validation`, `C-compensation-blocked-in-DB`를 본다. |
| commit | 각 업무 흐름의 명시적 `tx.Commit` | Go에서는 Commit을 보상 분기 안/밖 어디에 놓는지가 직접 보인다. 선언적 Spring tx는 보통 대상 메서드 반환 뒤 프록시에서 commit하므로 메서드 내부 catch가 그 오류까지 잡는다고 가정하지 않는다. v3부터 합성 deferred guard를 제거했으므로 commit 오류 재현을 현재 결과로 주장하지 않는다. |
| 취소·PG 환불 | `booking/cancel.go`의 `cancel`/`cancelAndRefund` | 잠금 뒤 이미 취소인지 다시 확인한다. 로컬 포인트 환급은 rollback할 수 있어도 원격 PG 환불 성공은 되돌릴 수 없다. 실패 시 일정 복원을 시도하지만 그 호출도 실패할 수 있다. `A5`, `C-refund-failure`, `C-inverse-compensation-blocked-in-DB`를 본다. |
| 상태 경합 | `schedule.Service`의 상태 전이, `booking.Service.applyChange` | 일정 서버는 행 잠금 후 상태를 판정하고, 늦은 변경·완료 콜백은 취소된 예약을 되살리지 않는다. Go에는 JPA의 관리 엔티티 캐시가 없지만 두 DB의 상태 전이·콜백 순서 문제는 남는다. `A8`, `A12`를 본다. |
| commit 뒤 전달 | `booking.Service.notify`, `schedule.Service.dispatchCallback`와 `internal/client` | 현재 Go 모델의 Slack은 동기, 역콜백은 별도 goroutine이다. Spring `afterCommit`/`@Async`와 비교할 때 commit 완료·자원 반환·응답 대기·전달 내구성을 구분한다. goroutine이나 executor만으로 지속 재시도·순서를 보장하지 않는다. `C-postcommit-callback-loss`, 두 100개 burst를 본다. |

**commit 뒤라고 연결 반환 시점까지 같지는 않다.** pgxpool의 `Tx.Commit`은 연결을 pool에 반환한다. Spring의 `afterCommit` 문서는 트랜잭션이 commit됐더라도 관련 자원이 아직 활성 상태일 수 있다고 설명한다. 따라서 이 Go의 Commit 다음 줄과 Spring callback의 위치만 보고 DB 연결 점유가 같다고 단정하지 않는다. [pgxpool](https://pkg.go.dev/github.com/jackc/pgx/v5@v5.11.0/pgxpool#Tx.Commit), [Spring afterCommit](https://docs.spring.io/spring-framework/docs/6.2.x/javadoc-api/org/springframework/transaction/support/TransactionSynchronization.html#afterCommit())

v6에서는 booking의 생성·취소·역콜백을 같은 패키지의 별도 파일로 나눴다. 외부 계약은 dependencies.go, 실제 HTTP 구현은 client이며 [요청부터 SQL까지의 읽기 안내](booking-api/README.md#예약-생성-하나를-따라가기)에 연결한다. DB 저장과 PG 조회를 함께 하는 private 메서드 이름도 saveAndVerifyPayment/cancelAndRefund로 명확히 했다.

v7에서는 booking의 SQL을 예약·사용자/포인트·결제 참조 파일로 나누고, Service에 예약 저장/상태 변경 → 포인트 쓰기 → 결제 처리 및 사용자→예약 잠금 순서를 드러냈다. 모든 쓰기는 Service가 전달한 같은 tx를 사용하며 SQL 저장 메서드는 자체 commit하지 않는다. JPA Repository처럼 자동 영속성 관리나 별도 저장소 interface를 도입한 것은 아니다. 원장 INSERT 중간 실패·commit 전 가시성·포인트 0원은 실제 DB 임시 스키마의 추가 Go 검사로 확인한다.

v8에서는 일정 API도 생성·취소/복원·완료·변경·콜백 전송별 파일로 나눴다. 일정과 이력 SQL은 함께, 자원 일자 잠금/완료 수 SQL은 별도로 두었다. 기존 SQL·함수 본문·commit/콜백 순서는 private 이름과 포맷 정렬 외 그대로다. [Schedule API 읽기 안내](schedule-api/README.md#코드-읽는-순서)에 실행 순서를 연결한다.

Go의 Context 취소만으로 열린 pgx tx가 자동 rollback된다고 가정하지 않는다. 두 module은 `defer rollback(tx)`에서 별도 1초 정리 Context를 사용한다. 반대로 HTTP 오류가 상대의 rollback을 의미하지도 않는다. 원격 결과 미확정과 확인된 거절은 구분해야 한다.

## 이번 결과를 어떻게 해석할까?

1. **동시성 안전과 외부 보상은 별개다.** 중복 차감·환급을 막아도 생성 실패의 PG 승인이나 보상 실패의 원격 일정은 남을 수 있다.
2. **오류 알림과 복구는 다르다.** 100개 예약 실패에서 Slack은 100번 시도됐지만 6건만 수락됐다. 이 더블의 제한 아래 관측한 결과이며 실제 Slack 전달률 예측은 아니다. 재시도 큐나 상태 재조정은 아직 없다.
3. **실행 자원은 여전히 한정된다.** 실제 일정 API가 DB 잠금을 기다리는 동안 예약 API pool 20개가 점유됐고 별도 health 조회가 503이었다. Go의 goroutine이 DB 연결 수를 무한대로 만들지는 않는다.
4. **테스트 통과의 의미를 나눈다.** 21/21은 예상한 성공/실패의 확인이다. 두 서버가 항상 수렴한다는 증명이나 사용자의 학습 완료가 아니다.

근거는 v3 기준 원본 (로컬: `results/2026-10-24-01/run.jsonl`)과 v4 구조 변경 회귀 (로컬: `results/2026-10-24-02-structure/run.jsonl`), v4 계산 요약 (로컬: `results/2026-10-24-02-structure/summary.json`)에 더해 v5 단순화 회귀 (로컬: `results/2026-10-24-03-idiomatic/run.jsonl`)·계산 요약 (로컬: `results/2026-10-24-03-idiomatic/summary.json`)을 보존했다. v6 흐름별 파일 분리 회귀 (로컬: `results/2026-10-24-04-workflows/run.jsonl`)와 계산 요약 (로컬: `results/2026-10-24-04-workflows/summary.json`)도 같은 예상 실패를 확인했다. v7 저장 책임 분리 회귀 (로컬: `results/2026-10-24-05-storage/run.jsonl`)·계산 요약 (로컬: `results/2026-10-24-05-storage/summary.json`)도 보존했다. v8 일정 API 구조 회귀 (로컬: `results/2026-10-24-06-schedule/run.jsonl`)·계산 요약 (로컬: `results/2026-10-24-06-schedule/summary.json`)도 보존했다. v3~v8에서 해당 알림은 수락 6·거절 94였다. 구조 변경을 성능 향상으로 해석하지 않는다. v1/v2 원본은 당시 구현의 증거로만 유지한다. 환경·스키마·제어 방식이 달라졌으므로 성능 개선 비교로 묶지 않는다.

다음에는 사용자 행을 HTTP 왕복 동안 잠그는 이유와 비용부터 한 사례씩 설명할 수 있다. 후속 후보는 생성 실패의 안전한 환불 판단, 지속 보상/역콜백 재처리, 알림 유실 처리다. 선택되지 않은 개선은 실행하지 않는다. 사용자 설명이 아직 없으므로 이해·숙달을 대신 기록하지 않는다.

## 공식 자료

Spring 6.2 계열·pgx 5.11·Go 1.27 기준 의미를 참고하며 특정 앱의 실제 설정·운영 결과를 보장하지 않는다. 2026-10-23 자료를 유지하고 pgxpool·Spring afterCommit·Slack은 2026-10-24 다시 확인했다.

- [Spring 6.2 — @Transactional](https://docs.spring.io/spring-framework/reference/6.2/data-access/transaction/declarative/annotations.html): 프록시·자기 호출·기본 rollback 규칙.
- [Spring 6.2 — TransactionSynchronization.afterCommit](https://docs.spring.io/spring-framework/docs/6.2.x/javadoc-api/org/springframework/transaction/support/TransactionSynchronization.html#afterCommit()): commit 뒤 실행과 자원 경계.
- [Spring 6.2 — Async execution](https://docs.spring.io/spring-framework/reference/6.2/integration/scheduling.html#scheduling-annotation-support-async): executor를 통한 비동기 실행.
- [pgx v5.11 — BeginTx](https://pkg.go.dev/github.com/jackc/pgx/v5@v5.11.0#Conn.BeginTx): Context와 자동 rollback의 구분.
- [pgxpool v5.11 — Tx.Commit](https://pkg.go.dev/github.com/jackc/pgx/v5@v5.11.0/pgxpool#Tx.Commit): tx 완료와 pool 반환.
- [Go 1.27.3 — net/http](https://pkg.go.dev/net/http@go1.27.3#Request.Context): 요청 Context·HTTP 생명주기.
- [PostgreSQL 18 — Explicit Locking](https://www.postgresql.org/docs/18/explicit-locking.html): 행·트랜잭션 advisory lock.
- [Slack — Rate limits](https://docs.slack.dev/apis/web-api/rate-limits/): 초당 1건과 짧은 버스트 허용, 429/Retry-After. 이 랩은 보수적인 엄격 간격과 별도의 1초 응답 지연을 선택했다.


2026-10-24 구조 검토에서는 [Go 서버 배치](https://go.dev/doc/modules/layout#server-project), [pgx의 인터페이스 선택](https://github.com/jackc/pgx#choosing-between-the-pgx-and-databasesql-interfaces), [sqlx 원본 문서](https://jmoiron.github.io/sqlx/)를 확인했다. cmd/internal은 공식 배치 지침이고 feature/service/store/HTTP/client 구분은 이 랩의 구체 선택이다.
