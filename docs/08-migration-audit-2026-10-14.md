# 개인 웹사이트 전환 감사 — 2026-10-14

상태: 분석 완료 / 이전 실행 승인 대기. 이 문서는 현황과 변경 제안이며, 기존 지침을 교체하거나 이전을 승인하지 않는다.

실행 계획: [09-migration-execution-plan-2026-10-14.md](09-migration-execution-plan-2026-10-14.md).

## 1. 조사 범위와 근거

- 사용자가 지정한 순서로 루트 진입 문서, 신규 `docs/` 전체, 기존 AGENTS → DESIGN → README → 기존 docs, 소스·테스트·설정을 확인했다. `templates/` 세 파일도 확인했다.
- 실제 파일 기준은 `leeeeeoy_portfolio/`의 `main`, `dad0449c6350c4ba8f618cb4d03a52bcee42af6b`다.
- GitHub `ls-remote`로 `main`과 `develop` 참조를 조회했다. fetch, 브랜치·이력 수정, 커밋, push는 하지 않았다.
- 검사와 build는 추적 파일 및 기존 설치 의존성을 복사한 `/private/tmp/personal-space-audit-vm2f8dj0/`에서 실행했다. 원본의 node_modules·dist를 갱신하지 않았다. 설치·업그레이드는 하지 않았다.
- 외부 HTTP는 기존 `frontend/scripts/check-deployment.mjs`로 읽기 전용 확인했다. Cloudflare 관리 API/CLI, GitHub 설정 변경, 배포는 실행하지 않았다.
- 원본 이력서, 로컬 SQL/query 내용, Secrets 값을 열람하거나 이 문서에 복제하지 않았다. 로컬 도구 설정·계정 캐시는 파일 존재·추적 상태와 JSON 키만 확인했다.

아래에서 **확인**은 파일·명령 출력으로 확인한 사항, **문서상**은 기존 문서의 주장, **미확인**은 이번 조사로 확정할 수 없는 사항이다. 이전 작업의 기억을 운영 상태의 근거로 사용하지 않았다.

## 2. 현재 구조와 Git 상태

```text
leeeeeoy/                         # 현재 작업 폴더, Git 저장소 아님
├── 00-READ-ME-FIRST.md            # 제안 문서 패키지 안내
├── AGENTS.md / CLAUDE.md          # 전환 후 공통 지침 / 진입점 제안
├── ARCHITECTURE.md               # 목표 구조 요약
├── docs/                         # 신규 상세 설계 10개 Markdown
├── templates/                    # 실험 / 기술 노트 / 개인 글
└── leeeeeoy_portfolio/            # 현재 유일한 Git 저장소
    ├── .git/
    ├── .github/workflows/        # frontend-ci / backend-ci
    ├── frontend/                # React 정적 SPA
    ├── backend/                 # Worker/Hono API, D1/R2 바인딩
    ├── docs/portfolio-renewal/   # 이전 개편 문서 6개
    ├── AGENTS.md / README.md
    ├── DESIGN.md                # ignore된 Apple 디자인 참고
    ├── .claude/settings.local.json         # 추적 중
    ├── .wrangler/cache/wrangler-account.json # 추적 중
    └── resume/, backend/schema.sql, backend/query/ 등 # 로컬 ignore 자산
```

`apps/`, `content/`, `labs/`는 아직 없다. 신규 설계의 Go 실험도 이 작업 폴더에서 확보되지 않았다. 이름만 보고 `labs/go-load-test/`를 구현하거나 측정 결과를 만들 수 없다.

| 항목 | 확인 결과 |
|---|---|
| Git 루트 | `<local-home>/leeeeeoy/leeeeeoy_portfolio` |
| origin | `https://github.com/leeeeeoy/leeeeeoy.github.io.git` |
| 현재 브랜치·HEAD | `main` / `dad0449c6350c4ba8f618cb4d03a52bcee42af6b` |
| 원본 변경 사항 | staged / unstaged / 일반 untracked 변경 없음, 추적 파일 56개 |
| 원격 main | `dad0449c6350c4ba8f618cb4d03a52bcee42af6b` — 조회 시 로컬과 일치 |
| 원격 develop | `500e95d1f79a17185e9af4d18c0bfdde4c47c707` — 로컬 develop과 일치 |
| 기타 로컬 참조 | `feat/bilingual-portfolio`, `origin/gh-pages` 존재; 삭제 대상 아님 |
| 태그 | 로컬 tag 목록 없음; 원격 전체 tag/branch는 조회하지 않음 |
| 상위 폴더 문서 | Git 관리 밖에 있음. 현재 원본 Git 상태에는 표시되지 않음 |

`develop`에는 main의 Node 26·lint/format 변경이 아직 반영되지 않았다. 기존 Preview가 main과 같은 코드라고 가정하면 안 된다. 추적 파일이 깨끗하다는 사실은 ignore된 로컬 파일이 없다는 뜻도 아니다.

## 3. 실제 구현과 배포 경계

### Web

- lockfile 기준 React **19.2.8**, Vite **7.3.6**, TypeScript **5.9.3**, Wrangler **4.147.0**. Node 요구는 `26.x`; 이번 검사 환경은 **26.9.0**, npm **11.19.1**이다.
- `frontend/src/content.json`의 `ko`/`en` 정적 데이터가 웹 원본이다. 경력 3개, 프로젝트 3개, 대표 사례 4개, skillGroups 4개를 유지해야 한다. 경력 사실의 원자료를 이번에 재검증한 것은 아니다.
- `App.tsx`는 pathname을 나누어 `notes`만 별도 처리하고, 나머지는 Portfolio를 표시한다. 알 수 없는 경로도 현재 Portfolio로 간다. `/notes/:slug/`는 없는 글 안내를 제공하며, HTTP 404를 만드는 구현은 아니다.
- `notes.ts`는 Engineering/Decision 분류와 빈 배열이다. Markdown/frontmatter 파이프라인 및 직접 사용하는 Markdown 파서 의존성은 없다. 새 콘텐츠 시스템은 단순한 파일 이동만으로 완성되지 않는다.
- 링크는 일반 anchor이고 언어는 `?lang=en`으로 유지된다. `content.ts`가 모듈 로딩 때 언어를 선택한다. 라우터나 새 상태관리 없이 현재 패턴을 재사용할 수 있다.
- Home이 현재 Portfolio라는 가정이 `SiteChrome.tsx`의 section navigation과 App의 저장된 스크롤 처리에 들어 있다. Home 분리 때 이 두 호출 관계도 함께 수정해야 한다.
- 테마 저장 키, Clarity 동의 키와 운영 hostname 조건, reduced motion, skip link, dialog, R2 이미지 크기 지정은 보존 대상이다.
- `index.html`의 root는 비어 있고 canonical·OG·JSON-LD는 루트 Portfolio를 가리킨다. 빌드에 콘텐츠를 넣는다는 말은 본문을 초기 HTML로 생성한다는 뜻이 아니다.

### Legacy API

- `backend/src/index.ts`는 `/api/profile`, `/api/careers`, `/api/projects`, `/api/skills` GET API와 정보용 `/`를 제공한다.
- `wrangler.toml`에는 기존 Worker 이름, D1 `leeeeeoy-portfolio`, R2 `leeeeeoy-portfolio-assets`, 기존 binding·vars가 있다. 웹은 이 API에 새로 의존하지 않는다.
- API 테스트는 DB에 접근하지 않는 `/` 정보 응답 **1개**다. API별 SQL·운영 D1·R2 상태 또는 외부 소비자를 검증하지 못한다.
- CORS 코드에는 `localhost`와 `portfolio.leeeeeoy.xyz`가 허용되어 있으나, Origin이 `leeeeeoy.xyz`인 요청의 허용 분기는 없다. 현재 웹이 API를 호출하지 않으므로 이번 이전에서 임의로 수정하지 않는다.
- Backend CI는 Node **22**를 사용한다. Frontend의 Node 26을 모노레포 전체에 강제하면 현행 실행 경계를 바꾼다.
- ignore된 `schema.sql` 1개 및 `query/` 3개 파일이 로컬에 있다. 공개 검토 전에는 복사·커밋하지 않되, 원본을 폐기할 때 누락되지 않도록 비공개 백업 목록에 포함해야 한다.

### GitHub Actions

| 영역 | 검사 트리거 | 검사 | 배포 트리거·경로 |
|---|---|---|---|
| Frontend | main/develop push 및 그 브랜치 대상 PR; `frontend/**` 또는 해당 workflow | npm ci → lint → format:check → test → build; build 내부 typecheck | push만; quality에 needs. `workingDirectory: frontend`, main 기본 env / develop `preview` |
| Backend | 같은 branch/event; `backend/**` 또는 해당 workflow | npm ci → test → typecheck | main push만; quality에 needs. `workingDirectory: backend`, `deploy` |

두 배포 job에 GitHub `environment:` 승인 게이트는 **정의되어 있지 않다**. main 병합·push는 운영 배포로 이어질 수 있고, develop push는 웹 Preview 배포로 이어질 수 있다. 저장소 규칙·Secrets·외부 게이트의 실재 여부는 별도 확인이 필요하다.

Frontend Secrets 이름은 `CLOUDFLARE_FRONTEND_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, Backend는 `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`다. 이는 **설정의 참조 이름** 확인이며 실제 존재·권한·값 검증이 아니다.

### Cloudflare

- Frontend 설정은 Worker 코드 없이 `./dist`를 Workers Static Assets로 배포한다. Production·Preview 모두 SPA fallback, `workers_dev: false`, `preview_urls: false`다.
- Production Custom Domain 설정에는 **apex와 `portfolio.leeeeeoy.xyz` 둘 다** 남아 있다. Preview는 `preview-portfolio.leeeeeoy.xyz`다. `www` 리다이렉션과 Access 정책 자체는 이 파일에서 관리하지 않는다.
- 별칭이 실제 301로 응답해도 `portfolio` Custom Domain을 설정에서 제거해도 된다는 뜻은 아니다. DNS·Redirect Rules·Access·Worker 도메인 관계를 확인한 뒤에도 이번 이전에서는 그대로 보존한다.
- `_headers`의 보안/캐시, Preview noindex, `flutter_service_worker.js`의 등록 해제 및 no-store를 보존한다. 새 사이트에서 예전 Flutter 캐시가 되살아나지 않아야 한다.
- Pages 삭제·Firebase 비활성화는 README의 역사적 설명이다. 이번에 관리 상태를 재조회하지 않았으므로 실제 리소스 삭제 여부를 확정하지 않는다.

## 4. 문서별 처분 제안

이번에는 어떤 원본도 수정·삭제하지 않았다. 아래 상태는 **이전 승인 후 적용할 제안**이다. MERGE는 필요한 원칙을 현행 문서로 합치고 원본은 별도 보존하는 뜻이다. ARCHIVE도 원문 보존을 전제로 한다.

### 신규 진입 문서·설계·템플릿

| 대상 파일 | 제안 | 근거·적용 대상 |
|---|---|---|
| `00-READ-ME-FIRST.md` | ARCHIVE | ZIP/패키지 안내와 미포함 원본 설명은 실제 이전 완료 뒤 부적합. 전환 당시 자료로 보존하고 현재 사용법은 루트 README로 안내 |
| `AGENTS.md` | UPDATE | 아직 존재하지 않는 경로는 목표임을 명확히 하고 Git 방식·단계 승인 범위·CLI 선택 규칙·실제 검사 명령 정리 |
| `CLAUDE.md` | KEEP | AGENTS를 원본으로 삼는 짧은 진입점이 적합. Git에서 추적되도록 ignore 충돌 해결 필요 |
| `ARCHITECTURE.md` | UPDATE | 전체 구조는 적합. 확보 전 Go 실험을 확정 자산처럼 보이지 않게 표시하고 build-time 콘텐츠와 HTML 생성 구분 |
| `docs/README.md` | UPDATE | 이 감사·실행 계획 링크 및 문서의 제안/현행/역사 상태 안내 추가. 본문 규칙은 다른 문서에 재복제하지 않음 |
| `docs/00-vision-and-scope.md` | KEEP | 개인 공간 목적·Lab/Writing 구분·비목표가 이번 요청과 일치 |
| `docs/01-current-state.md` | UPDATE | 공개 main 열람 스냅샷을 로컬 HEAD·원격 참조·검사·HTTP 증거로 보강. 실환경 미확인 구분 유지 |
| `docs/02-target-architecture.md` | UPDATE | rename 없는 기존 repo 개편도 선택지에 추가. 초안 산출물 제외·slug namespace·404의 HTTP 한계·외부 content 개발 입력 확정 필요 |
| `docs/03-content-and-writing.md` | UPDATE | 내용/글쓰기 구분 유지. 필수 필드와 기본값, 카테고리별 slug 중복 기준, draft의 dist 제외 계약을 02와 일치시킴 |
| `docs/04-migration-plan.md` | UPDATE | repo 이름 변경을 기존 repo 재사용의 필수조건에서 분리. 루트 승격·로컬 자산·자동 Backend 배포 위험·승인 게이트 보완 |
| `docs/05-lab-practices.md` | KEEP | 독립 실행·측정/가설 구분·허가된 부하 대상 원칙 유지. Go 예시는 원본 확보 전 요구사항으로 실행하지 않음 |
| `docs/06-quality-and-safety.md` | UPDATE | Backend Node 22, 설치/테스트 한계, approved contact 예외, 경로별 배포와 승인 조건 명시 |
| `docs/07-future-considerations.md` | KEEP | 미래 기능 재검토 조건을 정리하며 이번 구현과 구분함 |
| `docs/exec-plans/active/site-migration.md` | UPDATE | 미시작 상태 유지. 이 감사 완료만으로 Phase 0 체크박스를 모두 완료하지 않음; 09의 작은 단계·검증·승인에 맞춤 |
| `templates/experiment.md` | KEEP | 질문·예상·환경·실측·한계 구분이 적합; placeholder 날짜는 실제 content에서 검증해야 함 |
| `templates/lab-note.md` | KEEP | 실험 없는 기술 학습 기록을 허용함 |
| `templates/writing.md` | KEEP | 개인 글에 실험 양식을 강제하지 않음 |

### 기존 프로젝트 문서

| 대상 파일 | 제안 | 근거·적용 대상 |
|---|---|---|
| `leeeeeoy_portfolio/AGENTS.md` | MERGE | 최소 구현·정적 데이터·접근성·API/SQL 규칙은 루트 AGENTS/02/06으로 계승. 단일 `/`, 단일 JSON 원칙은 Portfolio에 한정. 기존 원본은 `docs/archive/portfolio-renewal/AGENTS.md` 등에 보존 |
| `leeeeeoy_portfolio/DESIGN.md` | ARCHIVE | Apple 외부 디자인 참고이며 현재 사이트의 엄격한 규약 아님. 실제 CSS에는 문서가 금지한 dialog/card shadow도 있음. 현재 ignore 유지; 공개 아카이브 편입은 별도 검토 |
| `leeeeeoy_portfolio/README.md` | UPDATE | 실제 스택·명령·Worker 운영 정보가 유용함. 목표 루트 README로 역할·경로·새 콘텐츠 흐름을 갱신하고 리소스 실재 주장은 관측 시점 표기 |
| `leeeeeoy_portfolio/docs/portfolio-renewal/README.md` | ARCHIVE | Flutter 강제 AGENTS, Pages 계획 등 현재 상태와 다름. API 없는 정적 데이터 선택 이유는 보존 가치 있음 |
| `leeeeeoy_portfolio/docs/portfolio-renewal/01-current-state-and-resume-gap.md` | ARCHIVE | 당시 Flutter/API/이력서 비교와 미확정 수치 기록. 현행 데이터 변경 지시로 해석하지 않음 |
| `leeeeeoy_portfolio/docs/portfolio-renewal/02-data-renewal-plan.md` | ARCHIVE | 데이터 선정 이유·정적 원본 결정 기록 보존. D1 삭제 단계는 이번 범위와 충돌 |
| `leeeeeoy_portfolio/docs/portfolio-renewal/03-frontend-migration-plan.md` | ARCHIVE | Pages deploy와 이전 canonical 계획이 현재 Worker/apex와 다름 |
| `leeeeeoy_portfolio/docs/portfolio-renewal/04-execution-phases.md` | ARCHIVE | 이미 지난 Flutter→React 계획, Pages rollback·Backend 정리 단계는 재실행 금지 |
| `leeeeeoy_portfolio/docs/portfolio-renewal/05-privacy-and-content-policy.md` | MERGE | 새 `docs/06-quality-and-safety.md`에 프라이버시 원칙 통합, 기존 approved contact 예외는 사용자 확인. 원문은 다른 역사 자료와 함께 보존 |

기존 `leeeeeoy_portfolio/CLAUDE.md`는 실제 파일이 없고 ignore 규칙만 있다. 별도 문서 분류 대상이 아니다. 문서 **DELETE 제안은 없다**. 중복 내용은 탐색 진입점과 상세 원본을 구분해 정리하고 역사적 판단은 보존하는 편이 낫다.

## 5. 충돌과 결정이 필요한 차이

| 차이 | 실제 근거·영향 | 권고 또는 승인 항목 |
|---|---|---|
| 문서 전체 읽기 vs 과제 문서만 읽기 | 루트 AGENTS는 평소 선택 열람, 이번 요청은 전체 감사 | 이번 요청대로 전체 열람. 향후 매번 전체 읽기로 규칙 확대하지 않음 |
| 루트 제안 vs 기존 하위 AGENTS | 루트는 Home/Portfolio/Lab/Writing, 기존은 `/` 단일 페이지와 단일 공개 데이터 원본 | 이전 전에 하나의 루트 규칙으로 합치고 JSON 규칙은 Portfolio에 한정. 기존 Backend 제한은 그 앱에만 적용 |
| 최신 지침처럼 보이는 과거 계획 | 기존 renewal 문서의 Flutter/Pages/canonical/삭제 계획 | ARCHIVE 및 superseded 표시. 실무 경력 숫자는 현재 content.json을 유지 |
| 개인 이메일 전면 금지 vs 이미 허용하는 코드·테스트 | 기존 AGENTS/05는 금지, content.json·메일 링크·content.test는 approved contact를 허용 | 주소를 새 보고서에 복제하지 않음. 기존 공개 연락처 유지 예외를 승인할지 결정; 즉시 삭제하면 현재 테스트·연락 기능이 달라짐 |
| 새 CLAUDE 진입점 vs ignore | 기존 루트 `.gitignore`의 `CLAUDE.md` 패턴 | 새 공통 진입점은 추적하도록 해당 패턴 수정. 기존 로컬 파일을 일괄 add하지 않음 |
| 패키지 안내의 미포함 원본 vs 현재 폴더 | `00-READ-ME-FIRST.md`는 ZIP에 원본 없다고 설명하지만 현재 하위 repo 존재 | 이전 완료 후 패키지 안내를 역사 자료로 옮기고 README로 탐색 통합 |
| Backend 보존 vs CI 경로 변경 | frontend/backend 모두 이동하면 main에서 두 deploy가 실행될 수 있음 | Backend 검사는 유지, 구조 이전 때문에 불필요한 운영 API 배포를 자동 승인하지 않음 |
| 보호 정책의 파일 선언 vs 실환경 | Wrangler의 false 설정·HTTP Access 차단은 확인, Access 세부 허용자·다른 우회 URL 미확인 | 선언과 관측을 분리. 인증 사용자 브라우저 및 관리 상태는 릴리스 전 확인 |
| slug·draft 계약 미확정 | 02는 draft 기본 true 추천, 03은 필수 권장; 중복 slug 범위 불명확 | 필수 title/date/summary, draft 누락은 true, boolean 타입 강제 권고. 동일 영역에서 중복 금지, 영역 간 동일 slug 허용 제안 |
| 정적 콘텐츠 vs 초기 HTML | 현재 client SPA, 새로운 Markdown 도구 없음 | build-time 데이터 공급부터 구현. SSR/SSG 전환·검색 노출 보장은 이번 단계에서 하지 않음 |

추가로 root `.gitignore`의 `.env.*.json`만으로 모든 위치의 비밀 파일을 막을 수 없다. 앱별 ignore와 루트 ignore를 합쳐 점검해야 한다. ignore 추가로 **이미 추적 중인 파일이나 과거 이력이 지워지는 것은 아니다**.

## 6. 파일·설정 이전 목록

| 현재 대상 | 목표 | 처리 원칙 |
|---|---|---|
| `frontend/` 추적 파일 전체 | `apps/web/` | 소스·test·scripts·public·lock·.nvmrc·lint/format/tsconfig·Wrangler 동반 이전. 내부 상대 경로는 먼저 그대로 유지 |
| `backend/` 추적 파일 전체 | `apps/legacy-api/` | 소스·test·Vitest·lock·tsconfig·Wrangler와 D1/R2 binding 보존. 이름·ID·vars 변경 금지 |
| `.github/workflows/*.yml` | 루트 동일 위치 | paths, node-version-file, cache-dependency-path, 모든 working-directory / workingDirectory를 새 경로로 반영 |
| 신규 루트 문서·docs·templates | 목표 루트 | 기존 AGENTS/README와 충돌 검토 후 선택적으로 합침. 현재 이번 감사·계획도 포함 |
| 기존 renewal 문서 6개 | `docs/archive/portfolio-renewal/` 권고 | 원문·상대 링크 함께 보존하고 역사 상태 표기. 문서 이동도 이후 승인 대상 |
| 기존 `.gitignore` 및 앱별 ignore | 루트 및 각 앱 | root CLAUDE 추적, 비밀파일·resume·docs/private/raw·캐시 제외, 앱별 DB 자료 보호 계승 |
| `.claude/settings.local.json`, 루트 `.wrangler/cache/wrangler-account.json` | 새 현행 소스에서 제외 권고 | 현재 추적 중인 로컬 권한/계정 메타데이터. 값 검토 전 그대로 수입하지 않음. 이후 승인된 untrack은 과거 이력 삭제와 다름 |
| DESIGN·resume·schema.sql·query 등 ignore 자산 | 별도 비공개 백업 | 존재/범위만 확인. 사용자가 보존 위치·공개 여부를 결정. 복사 누락과 공개 유입 모두 방지 |
| node_modules, dist, .vite, 앱 .wrangler, .DS_Store | 이전 소스에 포함하지 않음 | 재생성 가능한 환경/캐시. 원본 삭제는 이번 작업 및 무기능 이전의 필요조건 아님 |
| `.git`, refs, 원격 설정 | 선택한 Git 전략에 따라 보존 | 새 outer git init 후 하위 repo를 gitlink로 추가하지 않음; 단순 `.git` 승격도 하지 않음 |

## 7. 실제 수행한 검증과 한계

| 검사 | 결과 | 해석 범위 |
|---|---|---|
| `git status`, log, refs, ls-files, diff, `diff --check` | 통과 / 원본 변경 없음 | 로컬 추적 파일 기준 |
| `git ls-remote --heads origin main develop` | 두 브랜치 일치 | GitHub Settings, 모든 branch/tag, 진행 중 Actions는 별도 |
| Frontend `npm run lint`, `npm run format:check` | 통과 | 임시 복사본의 기존 설치 의존성 사용 |
| Frontend `npm test` | **11/11 통과** | 데이터·소스 assertion·양언어 정적 렌더·서비스워커 self-check. 실제 브라우저 상호작용 전체가 아님 |
| Frontend `npm run typecheck`, `npm run build` | 통과 | 현재 구현의 Node 26 기준 baseline |
| Backend `npm run typecheck`, `npm test` | 통과 / **1/1 통과** | 테스트 포트 제한 해제 후 통과. 실행 Node 26이며 CI Node 22 재현은 미검증 |
| npm lock / 설치 버전 비교 | 존재하는 설치 항목의 version 불일치 0 | fresh `npm ci`·무결성·공급망 검증을 대체하지 않음 |
| 운영 HTTP 검사 | 루트·영문·Notes 4 URL, 헤더·캐시 및 JS/CSS 2개 hash 일치 | 클라이언트 렌더·모바일·메타데이터의 모든 경로 미검증 |
| www / portfolio HTTP 검사 | 각각 3 URL **301 및 경로·쿼리 보존** 확인 | DNS/Redirect Rules 관리 설정은 미조회 |
| Preview `--protected` | 익명 Access 차단 통과 | 소유자 로그인과 인증 후 화면은 미검증 |
| 작성 문서 검사·원본 대조 | 문서 26개 분류, 새 문서의 로컬 링크·code fence·공백 검사 통과, 원본 74개 파일 hash 동일 | 원본 지침·문서·추적 파일 및 DESIGN 기준; 전체 Git 이력 개인정보 검사는 아님 |

최초 sandbox 실행의 Backend `listen EPERM`과 GitHub DNS 오류는 제한을 해제한 읽기 전용 재검사에서 해결되었다. 제품 결함이나 최종 미해결 검증 실패로 분류하지 않는다.

미검증: Cloudflare 배포 ID/실행 이력, Access 대상·허용자·우회 경로, R2 전체 이미지·객체, D1 데이터/백업/사용처, GitHub Secrets/보호 규칙/Actions 연결, 기존 모든 Git 이력의 개인정보, 원본 SQL·이력서 내용, fresh install, Backend Node 22, 브라우저 시각·상호작용, Go 원본.

## 8. 결론 및 다음 승인

목표 구조는 기존 React/Vite와 Worker Static Assets를 유지하면서 적용 가능하다. 구조 이동과 UI/Markdown 구현을 분리하고, 기존 GitHub 저장소 재사용을 우선 검토한다. GitHub 이름 변경은 필수 작업이 아니다.

다음 요청에서 먼저 결정할 사항은 Git 전략과 최종 로컬 루트, 새 공통 지침 및 역사 문서 보존 위치, 기존 공개 연락처 예외, 로컬 자산 백업·추적 제외 범위다. 구조 이전 승인만으로 Preview/Production 배포나 Backend 변경을 승인한 것으로 해석하지 않는다.

이번 변경은 이 감사와 별도 실행 계획의 추가뿐이다. 기존 코드·설정·문서·Git 이력·운영 리소스는 변경하지 않았다.
