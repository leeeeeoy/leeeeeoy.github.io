# Schedule API

독립 Go module이다. `cmd/server/main.go` → 같은 패키지의 `run.go`/`config.go`에서 환경·pool·client·service·HTTP handler를 명시적으로 조립한다. `internal/httpapi`는 요청/응답, `internal/schedule`의 업무별 파일은 실행 순서·트랜잭션, 같은 패키지의 책임별 postgres 파일은 SQL, `internal/client`는 외부 HTTP를 맡는다.

DB 소유: `resources, appointments, appointment_events`. 상대 서버 DB를 직접 읽지 않는다. [db/schema.sql](db/schema.sql)과 합성 개발 데이터 [db/fixtures.sql](db/fixtures.sql)은 분리했다. 스키마 내용은 v3와 같고 경로만 옮겼다. 별도 migration runner를 추가한 것은 아니다.

```sh
go test -count=1 ./...
go test -race -count=1 ./...
go vet ./...
# 의존성 기동과 환경변수 설정 후
go run ./cmd/server
```

환경은 [.env.example](.env.example), 전체 기동·API와 책임 표는 [Lab README](../README.md), 학습할 경계는 [Go/Spring 비교](../GO-AND-SPRING.md)를 따른다. 외부 의존성에만 같은 schedule 패키지의 비공개 작은 소비자 interface를 사용한다. Service가 비공개 구체 `store`를 구성하고 pool 종료는 main이 맡으며, tx 경계는 각 업무 흐름에 드러난다. 제품 코드의 실험 제어 경로·ORM·sqlx·DI container는 없다. 기존 보상/역콜백의 내구성 한계를 해결하는 작업은 이번 구조 변경에 포함하지 않는다.

## 코드 읽는 순서

| 목적 | 파일 | 읽을 내용 |
|---|---|---|
| HTTP 진입 | [handler.go](internal/httpapi/handler.go) | 라우트·JSON·Service 호출·응답 |
| 데이터와 입력 규칙 | [appointment.go](internal/schedule/appointment.go) | Appointment·Interval·입력 검증 |
| 조립/외부 계약 | [run.go](cmd/server/run.go), [service.go](internal/schedule/service.go), [dependencies.go](internal/schedule/dependencies.go) | Service 구성·조회·callback/notifier 계약 |
| 생성 | [create.go](internal/schedule/create.go) | 일자 잠금·겹침 검사·일정/이력 INSERT·commit |
| 취소·복원 | [cancel.go](internal/schedule/cancel.go) | 행 잠금·상태 재확인·완료 수 조정·이력·commit |
| 완료 | [complete.go](internal/schedule/complete.go) | PENDING 판정·완료 상태/수/이력·commit |
| 시간 변경 | [reschedule.go](internal/schedule/reschedule.go) | 행/일자 잠금·겹침 검사·기간/이력·commit |
| commit 후 전송 | [callbacks.go](internal/schedule/callbacks.go) | booking-api로 best-effort 비동기 역콜백·실패 알림 |
| 공통 DB 처리 | [postgres.go](internal/schedule/postgres.go) | store·tx 시작/정리·DB 오류 변환 |
| 일정과 이력 SQL | [postgres_appointment.go](internal/schedule/postgres_appointment.go) | 일정 저장/상태·기간 변경/조회·이력 기록 |
| 자원 SQL | [postgres_resource.go](internal/schedule/postgres_resource.go) | 자원/UTC 일자 advisory lock·완료 수 조정 |

같은 schedule 패키지와 Service/store 타입을 유지하고 파일만 나눴다. 이력은 일정 상태 변경과 함께 저장되는 책임으로 묶었다. 별도 Resource/Event Repository/interface나 공통 프레임워크는 추가하지 않았다. 실제 HTTP 전송 구현은 [callback client](internal/client/callback.go)와 [Slack client](internal/client/slack.go)에 있다.

## Service에서 읽는 트랜잭션

모든 일정/자원/이력 쓰기는 Service가 받은 **같은 pgx.Tx**를 사용한다. 책임별 SQL 메서드는 자체 Begin/Commit을 하지 않는다. 중간 실패는 Service의 defer rollback으로 앞선 로컬 쓰기까지 되돌린다.

- 생성: 입력 검증 → tx → 자원/UTC 일자 잠금 → 활성 구간 겹침 검사 → 일정 ID 생성·INSERT → CREATE 이력 → commit.
- 완료: tx → 일정 행 잠금 → 현재 상태 판정 → COMPLETED 변경 → 자원 완료 수 +1 → COMPLETE 이력 → commit → 역콜백 전송.
- 취소: tx → 일정 행 잠금 → 현재 상태 판정 → COMPLETED였으면 완료 수 -1 → CANCELLED 변경/이전 상태 보존 → CANCEL 이력 → commit → 공개 취소 경로면 역콜백. 내부 취소는 콜백을 보내지 않는다.
- 복원: tx → 일정 행 잠금 → CANCELLED 판정 → 자원/일자 잠금·겹침 검사 → 원래 COMPLETED였으면 완료 수 +1 → 이전 상태 복원 → RESTORE 이력 → commit. 내부 역보상 경로이며 콜백을 보내지 않는다.
- 변경: 기간 검증 → tx → 일정 행 잠금·PENDING 판정 → 새 기간의 자원/일자 잠금·겹침 검사 → 기간 UPDATE → RESCHEDULE 이력 → commit → 역콜백.

취소 요청이 이미 CANCELLED인 일정을 읽거나 완료 요청이 이미 COMPLETED인 일정을 읽으면, 기존처럼 추가 쓰기·이력 없이 반환하고 읽기 tx를 정리한다. 모든 상태 변경·이력·완료 수가 저장된 뒤 기존 위치에서 commit한다.

private 메서드는 lockResourceDays/checkAvailability/insertAppointment/lockAppointment/recordEvent/adjustCompletedCount처럼 실제 역할을 드러낸다. 함수 본문·SQL·잠금 순서는 이름과 포맷 정렬을 제외하고 기존과 같다.

## 로컬 저장과 외부 전달의 경계

[dispatchCallback](internal/schedule/callbacks.go)은 commit 후 BookingID가 있는 일정의 변경/완료/공개 취소를 별도 goroutine으로 보낸다. 전송 실패는 Slack을 시도하지만 지속 재시도·재조정은 없다. 콜백 실패가 이미 commit된 일정 DB를 rollback하지 않으며, booking-api DB까지 하나의 tx로 묶지도 않는다. 이번 구조 정리로 이 복구 한계가 해결됐다고 주장하지 않는다.

기존 단위·Race/vet와 두 실제 Go API의 21개 HTTP/독립 DB 회귀를 함께 확인한다. 보존한 원본·실행 소스·검사 범위는 [연구 기록](../RESEARCH-RECORD.md)을 따른다. booking의 포인트 검사를 일정 서버에 복제하거나 단순 파일 이동을 위해 같은 테스트를 새로 만들지는 않는다.
