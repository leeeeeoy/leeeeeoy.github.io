# Engineering Lab Harness — 적용 검토 및 검증

- 범위: 기존 Phase 4 이후 문서·템플릿 Harness 구축. 새 연구 실행·측정·초안 작성·발행 없음.
- 기준: 2026-10-15, `migration/phase1-monorepo`, HEAD `5fb158d85b136da67165429c8fbb735cd622a767`. 기존 미커밋 변경을 보존한다.
- 절차 원본: [14 Workflow](../../guides/14-engineering-lab-workflow.md). 이 파일은 적용 사례·검증 기록이며 또 하나의 규칙집이 아니다.

## 기존 구조와 최소 변경 판단

기존 [05](../../guides/05-lab-practices.md)는 실험 철학·신뢰성, [03](../../guides/03-content-and-writing.md)은 Markdown/draft 계약, [06](../../guides/06-quality-and-safety.md)은 검사·안전을 이미 다뤘다. Go 프로젝트에는 실행 전 계획·조건·실행기·재개기·집계·원본/계산 결과가 있다. 기존 글 템플릿은 **게시글용 frontmatter**가 있어 승인 전 계획·진행 상태·사용자 회고 기록을 맡기기에는 역할이 다르다.

따라서 구체적인 A–E 절차 문서와 계획/연구 기록 템플릿만 추가했다. 글은 기존 experiment/lab-note를 보완해 재사용한다. AGENTS와 docs 인덱스에서 진입하며 CLAUDE의 기존 단일 진입 방식과 아키텍처·앱은 바꾸지 않는다. 새로운 서비스·Runner·고정 상태 스키마·의존성·CI는 추가하지 않았다.

정리한 기존 문구:

- 03의 첫 글 확인 순서: 미리보기 위해 draft:false로 바꾸는 대신 true 유지·격리 미리보기·공개 승인 경계를 명시했다.
- 05의 데이터 “보정·익명화”: 민감한 원본은 안전한 별도 위치, 공개용 비식별 사본은 변경 방법 명시, 측정 수치 보정 금지로 구분했다.
- 06의 labs CI 설명: 실제 `.github/workflows/`에는 웹/API만 있다. “대상 프로젝트 검증”을 자동 수행한다는 인상을 제거하고 로컬 검사와 구분했다.

## 기존 Go Load Lab에 대한 읽기 전용 대응

아래는 당시 산출물을 현재 절차에 대응한 검토다. 새 승인·사전 가설·사용자 회고를 소급 작성한 것이 아니다.

| 단계/계약 | 기존 근거 | 판단·경계 |
|---|---|---|
| A 질문·사전 가설 | [PLAN](../../../labs/go-load-test/PLAN.md), [Phase 4 승인 기록](13-phase4-go-lab-record-2026-10-15.md) | 가설·변수·방법·조건 추적 가능. 새 템플릿의 예산/승인 표가 과거에 모두 존재했다고 주장하지 않음 |
| B 독립 구현·검사 | [README](../../../labs/go-load-test/README.md), `cmd/`, `internal/lab/`, Phase 4 기록 | 기존 검사 기록 존재. 이번에는 Go 테스트/부하 실행 없이 코드·로그만 읽음 |
| B 완료/재개 | progress (로컬 보류: `labs/go-load-test/results/2026-10-14/resume-2026-10-15/progress.json`), completion (로컬 보류: `labs/go-load-test/results/2026-10-14/resume-2026-10-15/completion.json`) | 본 측정 42/42, 재개 checkpoint는 warm-up 7·본 측정 7·보조 6 완료. 기존 35회는 파일 검증으로 연결하며 checkpoint에 42개가 있다고 세지 않음 |
| B 손상/실패 | 손상 기록 (로컬 보류: `labs/go-load-test/results/2026-10-14/resume-2026-10-15/corrupt-record.json`), 후속 오류 (로컬 보류: `labs/go-load-test/results/2026-10-14/resume-2026-10-15/storage-followup.json`) | 0바이트 원본 `.empty` 별도 보존. 후속 bind 실패는 측정 성공이 아님. 덮어써진 보조 stderr 사건도 역사 기록으로 유지 |
| C Observed | `results/2026-10-14/*-c*-r*.json`, environment/commands/resource 파일 | 조건·total·elapsed·bins·시각과 세션으로 추적 |
| C Calculated | [analyze.py](../../../labs/go-load-test/scripts/analyze.py), summary (로컬 보류: `labs/go-load-test/results/2026-10-14/summary.json`), runs.csv·plots/ | RPS 분모·분위수·3회 평균/표본 SD/CV를 원본으로 검산. 평균 분위수와 pooled quantile 구분 |
| C Interpretation/Unverified | ANALYSIS (로컬 보류: `labs/go-load-test/results/2026-10-14/ANALYSIS.md`), pprof top, 첫 글 | c16 편차·같은 호스트 제약과 원인 미확정 구분. 공식 출처는 있으나 모든 문서의 당시 확인일/버전이 기록됐다고 간주하지 않음 |
| D 후속 후보 | 첫 글의 마지막 질문들 | 별도 머신·도착률 모델·편차 시점 지표는 미실행 후보. 사용자 회고는 새 템플릿의 빈 필드로만 제공 |
| E 초안 연결 | 첫 Lab 글 (로컬 보류: `content/lab/go-http-concurrency.md`) → README·원본 경로·summary·그래프 | draft:true 유지. 그래프는 결과 폴더에만 있고 실제 public 경로 배치는 공개 전 과제. 미존재 원격 커밋 링크를 만들지 않음 |

`run.py`는 전체 실행, `resume.py`는 완료 marker가 없으면 실행, `analyze.py`는 표/그래프를 쓰는 도구다. **이번 읽기 전용 검증에서는 세 스크립트 모두 호출/import하지 않았다.** completion guard를 일반적인 read-only 명령으로 취급하지 않는다.

## Stage A 동작 검토 — 가상 입력, 미승인·미실행

아래 질문은 Workflow 검토용 가상 입력이다. 사용자의 실제 새 궁금증·선택을 대신하지 않는다. 계획을 작성할 수 있는지 확인하는 예시이며 자료 조사/코드 작성/실행으로 넘어가지 않는다.

| 계획 필드 | 예시 |
|---|---|
| Original Question | (가상 입력) “서버와 부하 발생기를 같은 머신에 둔 결과로 무엇까지 말할 수 있을까?” |
| Research Question | 기존 Go 결과에서 서버 병목을 확정할 수 있는 주장과 추가 근거가 필요한 주장을 문서 검토로 분리할 수 있는가? |
| Background | 기존 글은 같은 호스트 제약과 c16 원인 미확정을 기록함. 새 성능값 확보가 목적이 아님 |
| Hypotheses | 예시 계획 작성 시점(2026-10-15)의 예상: 기존 자료만으로 경쟁 주체를 확정하기 어려울 것. 독립적인 원인 분리 근거가 있으면 재검토. 과거 측정 전 가설로 쓰지 않음 |
| Method | 승인 후 기존 분석과 공식 자료 최대 3개를 대조하는 문헌/코드 검토. 신규 요청·프로파일·환경 변경 없음 |
| Variables | 독립·종속·통제변수 해당 없음: 새 비교 측정이 없는 문헌 검토. 기존 코드/측정 세션을 검토 범위로 고정 |
| Metrics | 확인할 주장별 근거 유무·직접 근거/추론 구분. 새 RPS·지연값을 생성하지 않음 |
| Environment | 저장소 읽기 전용, 기존 Go 1.27.2 실행 자료 참조. 새 런타임/CPU 측정 해당 없음 |
| Budget | 예상 10분, 최대 15분, 참고 자료 최대 3개·기록 1개. 시간/자료 한도 도달 전 중단 후 부분 보고 |
| Risks | 과거 자료를 수정하거나 추론을 원인으로 확정하는 위험. 원본 보존·네 근거 분류로 방지. 민감한 원문은 수입하지 않음 |
| Acceptance Criteria | 검토한 주장마다 출처·버전/실제 확인일·근거 분류·한계를 남김. 답이 미확정이어도 근거 부족을 설명하면 완료 |
| Limitations | 신규 측정 없는 검토로 c16 당시의 온도·GC·스케줄링 원인을 입증할 수 없음 |
| 보존·재개 | 자료별 대기/완료/접근 실패 표와 검토 위치 기록. 완료 검토는 재사용하고 바뀐 출처 버전은 별도 기록 |
| 승인 상태 | **승인 대기. A에서 종료. B·새 글 작성·공개 없음** |

후속 질문의 방법·비용·우선순위 및 사용자 전용 회고는 [연구 기록 템플릿](../../../templates/research-record.md)에 있다. 이 예시를 실행할 때에도 사용자 선택과 범위 승인이 먼저다.

## 이번 검증

검증 결과는 아래에 실제 실행한 것만 기록한다. Phase 4 브라우저 결과는 [당시 기록](13-phase4-go-lab-record-2026-10-15.md)이며 이번 브라우저 실행을 뜻하지 않는다.

| 검사 | 결과 |
|---|---|
| Go 원본 읽기 전용 검산 | 14조건×3회=42개, 총14,706,404요청. 조건·중단 여부·집계·RPS·raw histogram 분위수·평균/최소/최대/표본 SD/CV 일치 |
| 기존 보존 manifest | 220개 hash 일치. 손상 원본은 `.empty` 경로로 대조 |
| 완료 manifest | 본 JSON42개 + pprof2개 hash 일치 |
| 작업 전후 파일 보존 | snapshot 대비 기존 Go 파일323개·앱/CI/콘텐츠 모두 SHA-256 일치. HEAD/main/develop/origin 동일. 이번 변경은 기존 지침/템플릿7개와 신규 문서/템플릿4개 |
| 문서 링크·템플릿·승인 경계 | 변경 문서의 로컬 파일 링크, 계획 필수12필드, 근거4분류, 사용자 회고 빈칸, 글 템플릿3개의 draft:true 검사 통과. 승인 대기/무실행은 위 가상 A 사례로 검토 |
| Web content:check/lint/format:check/test/typecheck/build | 모두 통과,15/15 테스트, 공개 글0개 |
| 실제 production dist 초안 제외 | 실제 수집 결과0개, 기존 글 draft:true. title/summary/고유 본문/slug/그래프 경로가 생성 자산에 없고 dist에 lab-assets 없음 |
| Legacy API test/typecheck | 1/1 및 typecheck 통과(Node26.9.0). 최초 sandbox loopback bind EPERM 후 허용된 로컬 테스트로 재실행. CI Node22는 이번 미검증 |

일회성 읽기 전용 검산과 보존 snapshot은 `/private/tmp/leeeeeoy-harness-evidence-check.json`, `/private/tmp/leeeeeoy-harness-before.json`, `/private/tmp/leeeeeoy-harness-file-check.json`에 기록했다. 측정 데이터 디렉터리에는 쓰지 않는다. `git diff --check`도 통과했다. 단순 문서 규칙에는 영구 테스트 프로그램을 추가하지 않았다. 실행/재개/계산 자동화는 기존 Go 도구에, 승인 판단은 사용자와 지침에 남는다.

## 남는 경계

- 문서 계약은 실행 권한을 기술적으로 차단하는 시스템이 아니다. 새로운 세션에서도 관련 지침을 읽고 승인 범위를 확인해야 한다.
- 실제로 중단되는 **새 연구**나 미래 사용자의 승인 반응을 시험하지 않았다. 기존 손상/재개 증거와 계획 사례로 절차를 검토했다.
- 앱/콘텐츠/Go 원본 무변경이므로 브라우저·Go test/race/vet·성능 실험을 다시 실행하지 않았다. 이전 미검증을 완료로 바꾸지 않는다. 새 도구/코드에 맞는 검사·재개 스크립트가 실제 필요해질 때만 추가한다.
- 공개 전 기존 초안의 이미지 경로·소스 커밋·해석·Git 공개 범위와 작성자 의견은 사용자가 검토한다. Push/PR/배포는 수행하지 않는다.
