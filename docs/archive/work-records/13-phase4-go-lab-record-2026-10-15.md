# Phase 4 — Go HTTP 실험·결과 분석·첫 Lab 초안

- 상태: 완료(로컬·초안). 공개·원격 반영·배포 없음. 이 단계에서 멈춘다.
- 날짜: 2026-10-15. 최초 측정은 2026-10-14 KST에 시작했고 이번에는 부족한 측정만 재개했다.
- 브랜치: migration/phase1-monorepo, HEAD 5fb158d. 기존 Phase 3 미커밋 파일과 Phase 4 소스/유효 35회를 보존했다. main/develop/origin·Git 이력을 변경하지 않는다.
- 승인: 과거 원본이 없어 새 실험을 설계한다는 사용자 지시가 종전 원본 확보 계획을 대체했다. 이번 재개에서는 기존 Go 코드를 재구현/리팩터링하지 않고 누락 7회·보조 검증·분석·초안·웹 검사만 수행했다.

## 측정과 보존

[실험 README](../../../labs/go-load-test/README.md), [실행 전 가설](../../../labs/go-load-test/PLAN.md), 분석 (로컬 보류: `labs/go-load-test/results/2026-10-14/ANALYSIS.md`)을 따른다.

- 본 측정 42/42 유효: 기존 35회 + 재개 7회. 조건별 3회, 10초 admission, 실제 drain 포함10.00000275–10.090921625초. 총 14,706,404요청, 집계 HTTP/transport 오류 0건.
- 재개 조건: fast c1/10/50/200, slow c1/50, cpu c4의 r3. 기존35회를 재실행하지 않았다.
- 0바이트 slow-c1-r3.json은 resume-2026-10-15/slow-c1-r3.json.empty로 옮겨 보존했다. 새 결과는 partial→파일 fsync→조건/집계 검증→os.replace로 확정한다. 진행 상태는 progress.json에 매회 기록한다. .partial이 남으면 자동 덮어쓰지 않는다.
- 기존 모든 결과 파일과 Go 소스는 SHA-256 대조 통과. 기존 commands.json/resource CSV/환경/가설 원문도 보존했다. 변경한 실행 스크립트는 새 resume.py이고 기존 run.py도 그대로다.
- 환경: Apple M2 Pro(8P+4E),32GiB,macOS27.0.1,Go1.27.2 darwin/arm64,각프로세스 GOMAXPROCS12,같은머신/HTTP1.1 loopback. warm-up2초·휴식2초를 유지했다. 재개 세션 차이는 runs.csv에 표시한다.

## 분석의 핵심

| 조건 | 평균 RPS | RPS CV | 평균 p95 ms | 평균 p99 ms |
|---|---:|---:|---:|---:|
| fast c1 | 22,636.69 | 7.77% | 0.067 | 0.090 |
| fast c100 | 127,621.12 | 3.19% | 2.102 | 2.964 |
| fast c200 | 136,508.12 | 5.14% | 3.989 | 5.852 |
| slow c1 | 9.78 | 0.52% | 103.941 | 105.331 |
| slow c100 | 958.82 | 0.39% | 108.856 | 110.303 |
| cpu c8 | 6,712.90 | 0.35% | 1.396 | 1.658 |
| cpu c16 | 8,054.40 | 12.72% | 3.843 | 6.655 |

요약 분위수는 각 실행의 bucket 상한 분위수를 3회 산술평균한 값이다. nearest rank, bucket 간격1.02, 1µs 초과 구간 양자화 오차<2%이며 pooled quantile이나 신뢰구간으로 해석하지 않는다. 전체14조건의 평균/최소/최대/표본 SD/CV는 summary.csv/JSON, 개별 값·세션·CPU/RSS는 runs.csv, 그래프3개는 plots/의 PNG·SVG다.

cpu c16의3회는8,588.88/8,701.10/6,873.23RPS, p99는4.990/4.796/10.178ms였다. 느린 결과를 제거/보정하지 않았다. 당시 CPU집계도 낮았지만 온도/주파수/GC/runtime trace가 없어 스로틀링·scheduler·GC·서버 병목 중 어느 원인도 확정하지 않았다. 재개 fast 값 일부의 하락도 환경 통제 한계로 기록했다.

## 보조 검증

- 연결on/off 각1회(fast c50):92,134.24/21,839.50RPS, 새연결41/218,414, 재사용921,328/0. 본 42회와 합산하지 않는다.
- hey v0.1.4 각1회:fast c50 121,208.83RPS,slow c10 97.94,cpu c8 6,341.70. fast가100만 latency/status 표본 상한에 닿았다. upstream report.go에서 RPS는전체count,지연배열은최대100만,평균분모도저장길이를쓰는것을 확인해 fast 평균/지연을 전체표본교차검증으로 쓰지 않았다. raw txt는 보존했다.
- cpu c16 server/client profile1회:7,520.22RPS,p99 7.127ms. 두 pprof파일을 go tool pprof로 읽어 top텍스트를 보존했다. 서버SHA256 cumulative51.46%,rawsyscall flat44.95% 등이 관측됐지만 이전 느린 반복의 원인을 소급 입증하지 못한다.
- 최소 보조6회이며 본 42회·warm-up과 구분한다. 모든 부하는 숫자loopback만 대상으로 했다. 보조1회씩은 효과의 안정성을 입증하는 반복통계가 아니다.

완료 후 저장 보호 검사를 준비하면서 잘못된 작업 경로로 기존 runner가 서버 시작을 시도한 오류가 있었다. 샌드박스가 bind를 거부해 새 부하는 실행되지 않았다. 보조 서버 stderr 한 개가 오류 로그로 덮어써졌으며 storage-check-bind-error.stderr.txt와 storage-followup.json에 명시했다. 본 42개·보조 결과·CSV·pprof는 유지된다. 실행 당시 runner 원문을 별도로 보존하고 완료 시 hash 확인 후 즉시 종료하는 guard를 추가했다. 이 오류를 성공한 추가 실험으로 세지 않는다.

## 작성·변경 파일

- 신규: scripts/resume.py·analyze.py·test_resume.py·test_analysis.py, 누락7개JSON과자원기록, resume폴더·요약CSV/JSON/Markdown·ANALYSIS.md·plots·실험README.
- 첫 글: content/lab/go-http-concurrency.md (로컬 보류: `content/lab/go-http-concurrency.md`), **draft:true**. 질문/사전가설/구현/42회표/그래프/보조검증/공식문서/한계/다음질문을 담았다.
- 문서: root AGENTS/ARCHITECTURE/README, docs01/02/03/04/05/06/README/active plan에 현재 상태와 판단을 반영. Phase1/2/3 역사기록은 그대로다.
- 앱 source/package/lock/CI/Worker/API/Portfolio데이터는이번재개에서변경하지않았다. Go기존소스/모듈도동일하다. Python cache만 lab ignore에 추가했다. 실제 public에그래프를넣지않았다.

## 검증

| 검사 | 결과와 범위 |
|---|---|
| Go test / race / vet | 통과. test/race는 동일 소스의 `(cached)` 결과이며, 소스 hash도 일치함 |
| Python unittest | 3/3 통과. 원자적저장실패시기존파일보존·불완전집계거부·표본 SD/CV/nearest-rank |
| 42개 JSON 검산 | total분해·histogram합·실제RPS분모·raw bins로p50/p95/p99·기존hash 모두통과 |
| Web content:check/lint/format/test/typecheck/build | 통과,기존15/15 유지. 공개글0개. 테스트삭제/비활성화없음 |
| Draft 제외 | 실제 collectPosts배열에없고 production JS에title/summary/body고유문구/slug/그래프경로없음. dist에lab-assets도없음 |
| 격리초안미리보기 | /private/tmp의웹복사본에서만parsed draft를posts에주입.원문/복사본 frontmatter 모두 true,실제 수집기/빌드 설정 불변.그래프도 임시 public에만 복사 |
| 실제Chrome | 320/390px×ko/en×light/dark8조합,표4개·Go code1·graph3로딩,페이지가로넘침없음,코드/표방향키scrollLeft증가,직접URL/reload·목록→상세네이티브클릭·뒤로/앞으로 |
| 기존경로 | 실제production의Lab빈목록·초안없는글안내·Writing·Notes목록/없는글·Portfolio3경력/3프로젝트/R2이미지3개로딩확인 |
| desktop·로그 | 1440px폭확인,관측한 console warn/error 없음.원래 theme/viewport 복원·탭/서버 정리 |

브라우저의 DOM locator 클릭이 내비게이션을 일으키지 않아 네이티브 AX 클릭으로 목록→상세 이동을 확인했다. 앱 코드를 고쳐 검사를 통과시키지 않았다. 관측 기록은 실험 결과의 web-browser-checks.json, 화면은 `/private/tmp/leeeeeoy-phase4-draft-mobile.png`와 desktop/graphs 이미지에 남겼다. 미리보기 상단에 로컬 초안임을 명시했다.

## 검토 전 남는 경계

동일 호스트·이종 코어·짧은 3회·분리된 두 세션, 온도/주파수/백그라운드 부하 미통제, closed-loop의 도착률 제약, 클라이언트 집계 비용, 자원 CPU 분모 차이와 1초 RSS 표본 한계가 있다. c16의 느린 반복 원인은 미확정이다. 실제 기기·Safari·screen reader·운영/Access·실제 GitHub runner·API Node 22 등 이전 미검증을 완료로 바꾸지 않는다.

공개 전에 사용자가 문구와 수치 해석, 공개 Git에 포함할 결과 범위, 그래프의 최종 정적 경로, 실제 소스 커밋 링크를 검토해야 한다. 그래프는 results에만 있어 일반 production에 노출되지 않는다. 이후 초안을 공개하려면 본문 이미지 준비도 별도로 필요하다. 초안 공개와 배포는 별도 승인 범위다. 누적 구조 이전 전체를 main에 반영할 때 웹/API 동반 배포 위험도 유지한다.

이번 작업은 로컬 미커밋으로 남긴다. Push·PR·Cloudflare 변경·추가 실험은 진행하지 않는다.
