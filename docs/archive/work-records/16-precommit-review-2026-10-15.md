# 문서 정리·공개 범위·로컬 커밋 준비 점검

- 날짜: 2026-10-15. 시작 브랜치 `migration/phase1-monorepo`, 시작 HEAD `5fb158d85b136da67165429c8fbb735cd622a767`.
- 범위: 문서 분류·참조 갱신, 기존 변경/측정 자료 보존, 공개 위험 점검, 품질 검사, 논리적 로컬 커밋. Push·PR·배포·main/develop 병합은 하지 않는다.
- 사용자 결정: **“결과·초안은 보존하고 커밋 보류”**. 원본을 익명화해 덮어쓰거나 공개용 결과를 새로 만들지 않는다.

## 문서 역할과 이동

| 분류 | 위치·역할 | 처리 |
|---|---|---|
| Entry | 루트 README·AGENTS·CLAUDE·ARCHITECTURE, docs/README | 위치 유지. AGENTS에서 작업별 Guide만 선택해서 읽도록 연결 |
| Guides | docs/guides/의 00–07·14 | 기존9개 이동. 현행 목적/상태·아키텍처·콘텐츠·마이그레이션·Lab·품질·backlog·연구 절차 |
| 진행 중 계획 | docs/exec-plans/active/site-migration.md | 이동하지 않음. 릴리스 전 보류 게이트 유지 |
| Archive | docs/archive/work-records/의 08–13·15 | 기존7개 이동. 당시 설계·승인·실패·검증·미검증을 보존 |
| 기존 Archive | docs/archive/portfolio-renewal/, migration-proposal/ | 위치 유지. 참조 경로만 필요한 경우 갱신 |
| Templates | templates/ | 연구 계획·근거 기록·실험/학습/Writing 글 양식 유지 |

모든 기존 Markdown 문서는 새 경로에 보존한다. 루트 기준 참조와 이동 문서의 상대 링크를 갱신했다. 기존 Git 커밋에 이미 있는 경로 이력은 변경하지 않았다. 역사 기록의 현재 파일에서 로컬 저장소 경로는 `<repo>`, 백업 home은 `~` 표기로 정리했으며 실제 복구 위치 원문은 작업 전 로컬 사본에 보존했다. 당시 결정·측정·검증 범위를 새 결과로 덮어쓰지 않는다.

중복 규칙은 복사하지 않고 인덱스와 원본 링크로 연결했다. 루트 README에도 남아 있던 미리보기용 draft:false 안내를 콘텐츠 계약에 맞게 true 유지·격리 미리보기로 수정했다.

## 첫 Lab 글과 원본 검토

- 원본 위치: `labs/go-load-test/results/2026-10-14/`(로컬·커밋 보류).
- 초안: `content/lab/go-http-concurrency.md`(로컬·커밋 보류), **draft:true**. 본문을 수정하지 않았다.
- 14조건×3회=42개 raw JSON의 요청 분해·histogram 합·실제 elapsed 분모를 검사했다. 글의 주 결과 표14행은 summary.json의 형식화한 수치와 모두 일치한다. 총14,706,404요청. 기존 보존 manifest220개와 완료 manifest44개도 SHA-256 일치한다.
- 그래프3개는 results/plots에 존재한다. 글의 `/lab-assets/go-http-concurrency/{rps,p95,p99}.png`는 root-relative URL이며 **실제 public 디렉터리에는 없다**. 공개 전에 정적 경로 배치·링크·alt·모바일 표시를 검토해야 한다. 이번에는 이미지를 public으로 복사하지 않았다.
- 글에 가상의 자체 GitHub 커밋 링크는 없다. 코드/원본은 로컬 경로로 서술한다. 외부 [hey v0.1.4 report.go](https://github.com/rakyll/hey/blob/v0.1.4/requester/report.go) 링크는 실제 파일 페이지로 확인했다(2026-10-15). 원격 반영 후 자체 소스/근거 링크를 확정해야 한다.
- pprof를 gzip 해제해 검사하면 로컬 사용자·실행 파일·빌드 경로가 있다. progress.json에는 임시 hey 및 출력 프로파일의 절대 경로가 있다. 원본을 수정하면 기존 hash/증거 관계가 달라지므로 전부 보존하고 공개 범위를 보류했다.
- 커밋 후보에서 탐지한 비밀키 패턴은 없다. 패턴 검사는 비밀정보 부재의 완전한 증명이 아니다. 공개 기기 사양·시각·프로세스 ID·원본 범위도 공개용 사본 검토 시 결정한다.
- docs의 보류 자료 링크는 로컬 경로 표기로 바꿨다. 원격 checkout에 자료가 있다고 오인하지 않도록 루트/Go README에도 범위를 명시했다. 과거 검증 기록은 증거의 위치를 설명하며 자료가 모두 원격에 있다는 뜻이 아니다.

## Git·ignore·크기·배포

- 시작 시 staging은 비어 있었다. 기존 Phase 3 웹, Phase 4 Go, Harness 변경은 사용자 작업으로 보존하고 아래 단위로 기록한다. 기존 커밋을 amend/rebase/reset하지 않는다.
- `.env*`, `.dev.vars*`, resume/, docs/private/raw, node_modules, dist, .wrangler, Go bin/cache 제외를 확인했다.
- 추가 ignore: 루트의 `/content/lab/go-http-concurrency.md`, Go Lab의 `/results/2026-10-14/`. 향후 사용자 공개 범위 승인 후 규칙과 대상 파일을 함께 검토한다. `git add -f`로 우회하지 않는다.
- 시작 시 전체 추적/추적 후보418파일은 약2.83MiB, 최대 파일은 web package-lock 약203KB였다. 불필요한 실행 바이너리는 ignore되며 작은 그래프·프로파일도 이번에는 결과 보류에 포함된다.
- 현행 workflow의 Push/PR 대상 브랜치는 main/develop이다. 현재 migration 브랜치 Push는 이 두 앱 workflow 대상이 아니다. PR은 QA만, main은 변경 경로에 따라 웹 Production/API 배포, develop은 웹 Preview이며 API는 QA만 수행한다.
- 문서·템플릿·Lab-only 변경은 앱 workflow 대상이 아니다. 누적된 Phase 1 구조 변경을 main에 병합하면 **웹/API 양쪽 배포 대상**이다. 원격 상태와 Access·Secrets·실제 runner를 이번에 확인한 것은 아니다.

## 실행한 검사와 결과

| 검사 | 결과 |
|---|---|
| Web content:check / lint / format:check | 통과, 공개 글0개 |
| Web test / typecheck / build | 15/15·통과·통과(Node26.9.0) |
| 공개 후보 복사본 | 결과/초안이 없는 별도 트리에서도 content:check·typecheck·build 통과. 설치 의존성은 기존 node_modules를 재사용 |
| 실제 draft 제외 | 실제 수집0개. 생성 자산에 title/summary/slug/고유 본문/그래프 경로 없음, dist에 lab-assets 없음 |
| API test / typecheck | 1/1·통과(Node26.9.0), CI Node22 미검증 |
| Go test / race | `-count=1`로 통과, internal/lab 각각0.875s/1.844s. 신규 성능 실험 아님 |
| Go vet / Python unittest | 통과 / 3/3 통과. 테스트용 임시 파일만 사용 |
| 문서 링크·이전 경로·공개 후보 | 로컬 Markdown 링크136개·anchor1개가 Git index 내 대상과 일치, 이동16개 보존·옛 참조 제거. 결과/초안 제외 후보111파일 약0.80MiB, 최대203KB. 비밀키 패턴/home 절대경로 탐지 없음 |
| 원본/초안·앱 소스·refs 보존 | 원본307파일+초안1개 hash 동일. 앱/CI/Go 구현 등 총376파일 동일. 모든 기존 파일이 원래/이동 경로에 존재하며 main/develop/origin 유지 |

브라우저/실기기/운영/Cloudflare Access를 새로 확인하지 않았다. Phase 4의 과거 브라우저 기록과 이번 로컬 자동 검사를 구분한다. 부하 Runner와 결과 생성 main은 실행하지 않았다.

## 권장 로컬 커밋 단위

1. `feat(web): add validated Markdown Lab and Writing content` — 기존 Phase 3 앱 구현·lockfile·검사/fixture. Portfolio 경력/프로젝트는 유지하고 UI 문구만 추가된 기존 diff임을 확인.
2. `feat(lab): add independent Go HTTP load test tools` — Go 코드·계획·README·스크립트·검사·ignore. 결과/프로파일/초안 제외.
3. `docs: organize guides and archive research workflow records` — Entry·Guides·Archive·Templates·공개 보류 ignore·이번 검토 기록. Phase별 기록을 삭제하지 않고 새 위치에 보존.

## Push 판단과 복구

웹 `613bce2`와 Go 도구 `532fd9a`의 로컬 커밋을 기록했으며 문서 커밋은 마지막으로 생성한다. 실제 최종 해시는 Git log와 최종 보고를 따른다.

위 세 커밋의 대상만 확인되고 모든 검사가 통과하면 **현재 migration 브랜치에 한해 사용자 최종 승인 후 Push 준비 가능**하다. 결과/글의 공개 준비 완료나 main/develop 병합·배포 승인을 뜻하지 않는다. Push는 이번에 수행하지 않는다.

로컬 결과307파일과 초안1개는 ignore 상태로 보존한다. 원본 SHA snapshot·이동표·문서/ignore 작업 전 사본은 저장소 밖 로컬 임시 백업에 있다. 되돌려야 하면 새 커밋을 검토해 revert하거나 백업의 필요한 문서만 복구한다. 보류 파일에 git clean/reset을 사용하지 않는다. Phase 1의 저장소 복구 경로와 develop 미반영 작업은 그대로 유지한다.
