# 실행 전 계획 — 2026-10-14

새 환경에서 새로 만든 실험이다. 과거 Go Load Lab의 코드·수치는 사용하지 않는다. 결과를 보기 전에 이 계획을 기록한다.

질문: Go HTTP 서버에서 동시 요청 수를 늘리면 처리량과 응답 지연시간은 어떻게 변하는가?

## 가설

1. /fast: 처음에는 동시성으로 처리량이 늘지만 언젠가 클라이언트·서버·스케줄링·연결 처리 비용 중 하나로 증가가 둔화될 것이다. 큰 동시성에서 tail latency가 늘 수 있다. 서버만 병목이라고 단정하지 않는다.
2. /slow: 100ms 대기 동안 CPU를 점유하지 않으므로, 포화 전에는 대략 workers / 0.1초 RPS이고 평균 지연은 100ms 근처일 것이다. 이는 닫힌 부하 모델의 근사이지 고정 도착률 실험이 아니다.
3. /cpu: 요청마다 동일 입력에서 의존적인 SHA-256 20,000회를 수행한다. 동시성 증가로 CPU 병렬성을 사용할 수 있지만 코어/클라이언트와 경쟁하며 한계에 가까워질수록 지연과 편차가 커질 수 있다.
4. 연결 재사용을 끄면 /fast에서 연결 설정·해제 비용이 드러날 수 있다. 보조 비교만 수행하고 본 실험과 섞지 않는다.

## 사전에 고정한 조건

- HTTP/1.1 GET, localhost 숫자 loopback IP만 허용, 리다이렉션·프록시 없음.
- 서버 /slow 100ms, /cpu SHA-256 20,000회. 이후 결과를 맞추기 위해 횟수/코드를 바꾸지 않는다.
- 서버·클라이언트 GOMAXPROCS=12, 같은 머신·별도 프로세스, release build, race/profiling 비활성으로 본 측정.
- /fast: 1,10,50,100,200; /slow: 1,10,50,100; /cpu: 1,2,4,8,16.
- 각 조건 warm-up 2초 후 휴식 2초, 본 측정 10초 × 3회. 측정 사이 휴식 2초. 라운드마다 조건 순서를 고정 seed로 shuffle해 단조로운 순서 효과를 줄인다. 온도/백그라운드 프로세스를 완전히 통제하지 못한다.
- 각 Worker는 하나의 요청을 마친 뒤 다음 요청을 보낸다(고정 동시성 closed-loop). 요청 timeout 2초. 공통 시작 gate 후 10초간 신규 요청을 시작하고 in-flight는 완료/timeout까지 drain한다. RPS는 전체 완료 요청 / drain을 포함한 실제 monotonic elapsed. 성공 RPS도 별도로 보존한다.
- 응답시간은 Client.Do + 전체 body 읽기/닫기까지이며 성공/실패 모두 분포에 포함한다. 2xx만 성공, 나머지는 HTTP 실패, Do/read 오류는 transport 실패, timeout은 transport의 부분집합.
- p50/p95/p99: nearest rank, 1µs에서 1.02배 간격의 bounded histogram bucket 상한. >1µs 구간 양자화 오차 <2%; 개별 지연 목록을 저장하지 않아 메모리는 요청 수와 무관하다.
- per-worker 집계 후 합산; body를 discard까지 읽고 닫으며 HTTP Transport를 공유한다. GotConn trace로 새/재사용 연결 수를 기록한다. 이 trace와 histogram 계산의 클라이언트 비용도 실험 조건이다.
- 매 1초 서버/클라이언트 RSS와 ps %CPU·누적 CPU time을 샘플링한다. 클라이언트 rusage CPU/peak RSS도 JSON으로 남긴다. 서버 CPU는 측정 직전·직후 누적 CPU time 차분이다. RSS 단위 KiB, ps %CPU는 순간 구간 평균으로 취급하지 않는다.
- 본 실험과 별도로 /fast c=50 연결 비재사용 10초 ×3, CPU 프로파일 /cpu c=16 10초, 가능한 경우 hey로 /fast c=50, /slow c=10, /cpu c=8 각10초 ×3 교차 확인. hey와 histogram quantile/RPS 종료 정의 차이는 별도 기록한다.

실패/이상 결과도 원본을 보존한다. 수정이 필요하면 변경 이유와 수정 전후를 구분하고, 이 계획을 사후 예상으로 덮어쓰지 않는다. 외부 부하는 발생시키지 않는다.
