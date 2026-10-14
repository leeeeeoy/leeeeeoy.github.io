# 개인 웹사이트 모노레포 실행 계획 — 2026-10-14

상태: 최초 실행안 보존 / Phase 1 로컬 이전 승인. 현재 진행·결과는 [active plan](exec-plans/active/site-migration.md)과 [Phase 1 기록](10-phase1-migration-record-2026-10-14.md)을 따른다.

현황과 파일별 처분 근거: [08-migration-audit-2026-10-14.md](08-migration-audit-2026-10-14.md).

이 문서의 명령은 이후 승인된 작업에서 사용할 검증 예시다. 현재 파일 이동, Git 변경, 저장소 생성, CI 변경 또는 배포를 지시하지 않는다. 기존 실행 계획의 Phase 0를 자동 완료하지 않는다.

## 1. 적용 가능한 최소 구조

```text
leeeeeoy/                      # 최종 로컬 이름 후보; 확정 전
├── .git/                      # 최종 저장소 하나, 내부 중첩 repo 없음
├── .github/workflows/
│   ├── frontend-ci.yml
│   └── backend-ci.yml
├── apps/
│   ├── web/                   # frontend의 소스·검사·배포 설정 전체
│   └── legacy-api/            # backend 보존; 별도 lockfile / Node 22 CI
├── content/
│   ├── lab/                   # 공개 기술 Markdown
│   └── writing/               # 공개 개인 Markdown
├── labs/
│   └── <실제 확보한 실험>/     # 각 README / 자체 의존성 / 선택적 소형 결과
├── docs/
│   ├── README.md
│   ├── exec-plans/active/site-migration.md
│   ├── archive/portfolio-renewal/ # 기존 원문·링크를 함께 보존
│   └── ...                    # 현행 설계·감사·계획
├── templates/
├── .gitignore
├── README.md
├── AGENTS.md
├── CLAUDE.md
└── ARCHITECTURE.md
```

루트 package.json/workspaces, Nx/Turbo, 공통 runtime, Go workspace, 공통 Docker 구성은 추가하지 않는다. 앱별 lockfile과 도구를 유지한다. `labs/` 실험은 웹 코드에서 import하지 않으며, Go 코드를 확보하기 전에는 빈 프로젝트를 만들어 채우지 않는다.

| 경계 | 입력·출력 | 검사·배포 책임 |
|---|---|---|
| Web | Portfolio JSON + 공개 Markdown → `apps/web/dist` | Node 26, lint/format/test/typecheck/build; 웹 Worker만 |
| 콘텐츠 | `content/lab`, `content/writing` | 메타데이터·안전한 렌더·링크 검사, 웹 build 입력 |
| Legacy API | 기존 Hono/SQL/Worker config | 별도 npm test/typecheck, 기존 D1/R2 보존; 웹 신규 의존 없음 |
| Lab | 언어별 코드·환경 → 재현 가능한 결과 | 각 실험 README의 명령, 해당 실험만 검사; 웹 자동 배포 없음 |
| 설계·템플릿 | 작업 지침·작성 가이드 | 문서/링크 검토; 문서만 바꿔 웹·API를 배포하지 않음 |

### 현재 코드에서 바로 적용되지 않는 부분

1. **루트 Git 승격:** `.git`만 상위로 옮기면 index의 상대 경로와 실제 파일 위치가 달라진다. 최종 구조를 별도 작업본에서 완성·검증한 뒤 로컬 경로를 교체하는 방법을 권고한다.
2. **콘텐츠 입력:** 현재 Vite root는 앱이며 콘텐츠는 그 바깥에 놓일 예정이다. 구현 단계에서 Vite build/dev가 루트의 `content/`만 읽도록 작은 build-time loader를 검토한다. 임의 홈 디렉터리나 Lab 결과를 읽는 loader는 만들지 않는다.
3. **Markdown:** 현재 직접 사용하는 parser가 없다. 필요한 문법(문단/제목/링크/이미지/코드/표)만 지원할 도구를 확인하고 별도 선택 후 도입한다. YAML/Markdown 전체를 자체 정규식 parser로 재구현하지 않는다. 라이브러리는 이번에 설치하지 않는다.
4. **초안:** 브라우저에서 목록만 필터링하면 원문이 JS나 다른 dist 파일에 남을 수 있다. frontmatter 검증 후 **발행 글만 build 출력에 공급**하도록 설계한다. Public Git의 원문 공개는 별개다.
5. **404/SEO:** 현재 SPA fallback과 pathname 분기는 알 수 없는 경로도 200 HTML로 제공할 수 있다. 우선 명확한 UI의 없는 경로 안내를 구현하되 HTTP 404·글별 초기 HTML/OG를 보장하지 않는다. 그 요구가 확정될 때 별도 검토하며 SSR 프레임워크 전환은 제외한다.
6. **Home 분리:** `SiteChrome.navigateToSection`, App의 section scroll, 양언어 데이터/UI·메타데이터·검사 스크립트까지 함께 반영해야 한다. PortfolioPage를 옮기는 것만으로 완료되지 않는다.

## 2. Git 방식 비교와 권고

로컬 작업 폴더 위치, Git 이력의 출처, GitHub repo 이름은 서로 다른 결정이다. 기존 repo를 유지하면서 로컬 루트를 `leeeeeoy/`로 바꾸는 데 GitHub rename은 필요하지 않다.

| 방식 | 이력·설정 | 장점 | 비용·위험 | 판단 |
|---|---|---|---|---|
| A. 기존 GitHub repo 유지 + 기존 이력 위에 구조 이전 커밋 | 이전 commit ID 유지; 같은 GitHub repo를 사용 | 외부 연결을 가장 적게 바꿈, 기존 PR/설정의 이전 불필요 | 경로 수정·로컬 루트 교체·기존 역사 개인정보 검토 필요 | **우선 권고** |
| A-추가. A 이후 GitHub 이름 변경 | 같은 repo의 새 이름 | 정체성·표기 변경 가능 | 하드코딩한 소스 링크, clone remote, webhook/외부 연결, Pages 사용 여부 확인 | 선택사항, 구조 이전과 별도 승인 |
| B. 새 repo + 기존 이력 복제 | commit은 유지 가능; GitHub 설정은 새로 구성 | 새 이름·권한·운영 경계를 명확히 분리 | Secrets/Rulesets/Environment/Access 연계/배포 권한 확인·재설정, 두 repo의 동일 Worker 배포 충돌 | 별도 repo가 실제 필요한 경우 |
| C. 새 repo + 검토한 현재 파일만 initial commit | 과거 이력은 새 repo에 없음; 원본에서 보존 | 공개할 파일을 선별하기 쉬움 | blame·이력 탐색 단절, 설정 재구성 비용은 B와 같음; 현재 파일 개인정보도 검토 필요 | 이력 분리가 목적일 때만 |

GitHub rename은 일반 저장소 링크 및 Git 작업을 새 이름으로 연결하지만, project site URL과 그 저장소가 제공하는 Action 호출은 별도 주의가 필요하다. 원래 이름을 재사용하면 redirect가 끊길 수 있다. 이 사실은 현재 repo의 외부 연결이 안전하다는 증거가 아니다. [GitHub 공식 rename 문서](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository).

새 repo에 Git 이력을 복제하는 작업은 Git 객체·refs 이전이며, Secrets·Settings가 복제된다는 뜻은 아니다. GitHub가 안내하는 bare/mirror 방식을 참고하되, 이 프로젝트에서는 `gh-pages` 등 전체 refs를 무조건 공개하거나 활성화할 필요가 없으므로 이관 refs를 먼저 결정한다. [GitHub 공식 복제 문서](https://docs.github.com/en/repositories/creating-and-managing-repositories/duplicating-a-repository).

**권고 이유:** 현재 56개 추적 파일의 작고 독립적인 두 앱이며 웹·API 경계와 CI가 이미 있다. 신규 사이트 목적만으로 GitHub·Cloudflare 연결을 재구축할 근거가 없다. A로 먼저 기능 없는 이전을 검증하고 이름 변경은 필요할 때 추가한다. 다만 기존 전체 이력의 공개 정책이 충돌한다면 C를 재검토한다. 이력 정화·force push는 이 계획의 범위가 아니다.

### A를 택할 때의 안전한 로컬 절차

1. 원본의 전체 refs 백업과 별도의 ignore/untracked 비공개 자산 백업을 만든다. 새 docs/templates도 아직 Git 밖이므로 별도 백업한다.
2. 원본과 겹치지 않는 staging 경로에 이력을 복제한 작업본을 만들고 migration branch에서 변경한다. 원본은 그대로 두고, clone의 origin이 로컬 원본을 가리킬 수 있다는 점을 확인하여 원격 연결을 명시적으로 설정한다.
3. 작업본에서 `frontend`/`backend`를 목표 경로로 옮기는 **새 커밋**을 만든다. 전체 이력 재작성은 하지 않는다. 원문 문서·새 지침 충돌을 검토한 뒤 합친다.
4. 검사와 파일 대조가 끝난 뒤 기존 `leeeeeoy/`를 별도 백업 위치에 보존하고 staging 작업본을 최종 로컬 경로로 교체한다. 이름 충돌이 있는 현재 폴더 위에 덮어쓰지 않는다.
5. 최종 root의 Git·refs·원격과 파일 경로를 재검사한다. 내부 `leeeeeoy_portfolio/.git`을 중첩 Git 저장소로 두지 않는다. 이 백업을 나중에 지우는 작업도 별도 승인이다.

`git bundle --all`은 refs가 도달하는 Git 객체 백업이며 작업 트리·ignore 자산·GitHub Settings의 백업이 아니다. 생성 후 `git bundle verify`와 별도 복원 작업본으로 검증한다. [Git bundle 문서](https://git-scm.com/docs/git-bundle).

일반 파일 이동은 작업 브랜치에서 검토 가능한 커밋으로 남긴다. `git mv`는 index를 갱신하지만 commit 전까지 이전이 확정되지 않는다. [Git mv 문서](https://git-scm.com/docs/git-mv). `.git`만 이동하거나 상위 `git init` 후 하위 repo를 통째로 add하는 방식은 권고하지 않는다.

## 3. 단계별 실행 계획

각 단계의 시작에는 승인 범위를 기록하고 종료에는 변경·검증·미검증·다음 단계를 보고한다. 아래 작은 단계는 최초 Phase 0–5의 세분화다. 이후 사용자 승인으로 S1–S3의 로컬 전환을 진행하며 S4의 Preview 배포와 S8 운영 릴리스는 이번 범위에서 제외했다.

### S0 — 전략·운영 baseline 확정 (기존 Phase 0)

- **목표:** 무손실 이전과 배포 복구에 필요한 기준·승인 범위를 확정.
- **대상:** 이번 감사/계획, `docs/01-current-state.md`, `docs/04-migration-plan.md`, active plan. 소스 변경 없음.
- **작업:** A/B/C 및 로컬 루트 선택, refs/미추적 자산 목록 확인, 공개 연락처 예외 결정, GitHub 설정·Secrets 존재/권한(값 제외)·진행 중 배포 확인. 현재 Production/Preview Worker 배포 ID와 이전 검증 버전, 도메인/Access 관계를 기록. 읽기 전용 Cloudflare 조회가 필요하면 프로젝트의 Wrangler 설정이 있으므로 Wrangler를 사용.
- **검증:** `git -C leeeeeoy_portfolio status --short --branch`, `rev-parse HEAD`, `ls-remote --heads origin main develop`; 감사의 HTTP 4개 명령; 소유자 로그인/핵심 화면 확인.
- **완료:** 전략·기준 commit·백업 위치·복구 버전·공통 지침·배포 승인 범위가 기록됨. 아직 이 게이트는 완료되지 않았다.
- **위험:** 조회 결과에 민감 정보를 기록하거나 이미 진행 중인 배포를 놓칠 수 있음.
- **복구:** 읽기 전용 단계이므로 원본 복구 불필요; 민감 기록은 공개 파일에 작성하기 전에 제외. 배포 ID 미확보 상태에서 릴리스하지 않음.

### S1 — 백업과 격리된 작업본 준비 (Phase 0/1)

- **목표:** 원본을 유지하면서 최종 루트 후보에서 작업할 기반 확보.
- **대상:** 별도 비공개 backup/staging 경로, 새 docs/templates, Git refs; 선택 B/C일 경우 승인된 새 repo 준비.
- **작업:** Git bundle/복원 대조, 미추적·ignore 자산의 선별 비공개 백업, staging branch 준비. 이력 복제와 GitHub repo 생성 권한을 구분. 새 repo에서 기존 repo와 동시에 동일 Worker를 배포하지 않도록 배포 주체를 먼저 정함.
- **검증:** `git bundle verify <backup.bundle>`, 복원 작업본 `git fsck --full`, HEAD/refs 목록·파일 hash 비교, `git status --short`, `git rev-parse --show-toplevel`. origin은 자격정보 없이 표시.
- **완료:** 원본·외부 서비스 그대로, 복구 가능한 작업본 및 비공개 자산 백업 확보. 이전한 refs 범위가 명시됨.
- **위험:** 단순 clone은 ignore 자산을 보존하지 않음; 새 main에 workflow와 Secrets를 함께 넣으면 의도치 않은 배포 가능.
- **복구:** staging을 사용하지 않고 원본으로 계속 작업. 백업·원본은 삭제하지 않음.

### S2 — 파일 위치·문서 경계만 이전 (Phase 1 전반)

- **목표:** 기능과 리소스 정체성을 바꾸지 않고 apps 구조 완성.
- **대상:** `frontend/` → `apps/web/`, `backend/` → `apps/legacy-api/`, 루트 README/AGENTS/CLAUDE/ARCHITECTURE/.gitignore, docs/templates/역사 문서.
- **작업:** tracked 파일 전체를 동반 이동, 앱별 lockfile 유지, approved 지침 합침, 역사 문서 원문 보존. approved 범위에서 로컬 설정/캐시를 추적 대상에서 제외하고 ignore 보완. SQL·resume·private 원문을 소스로 가져오지 않음. 이 단계는 workflow 변경과 이어서 검증해야 하며 중간 상태를 main/develop에 push하지 않음.
- **검증:** staged 이동은 `git diff --cached --summary --find-renames`, 커밋 후에는 `git diff --summary --find-renames <기준-commit> HEAD`로 확인. `git diff --check` 및 `git diff --cached --check`; 원본과 옮긴 소스/JSON/public/Wrangler의 파일 hash 대조(의도한 문서·경로 변경 제외). `git ls-files`로 root CLAUDE가 포함되고 local metadata·비밀파일·중첩 repo가 새 추적 목록에 없는지 점검.
- **완료:** 경력 데이터·public 자산·Worker 이름/도메인/binding/vars·앱 내부 상대 경로가 동일. 역사 원문/링크 유지, 기존 지침과의 차이는 문서에 기록.
- **위험:** dotfile/ignore 자산 누락, CLAUDE ignore, private 파일 공개, 원본 위 덮어쓰기.
- **복구:** staging의 해당 이전 커밋을 되돌리거나 원본 작업본 사용. 공유 이력에 reset/force push 하지 않음.

### S3 — CI 경로와 로컬 동등성 (Phase 1 후반)

- **목표:** 새 경로에서도 기존 검사·배포 경계를 유지하고 구조 이전 회귀를 차단.
- **대상:** 두 workflow의 paths/Node/cache/working-directory/workingDirectory, 관련 README, deployment checker; 앱 설정은 실제 경로 의존 부분만.
- **작업:** 웹 paths에 `apps/web/**`, `content/lab/**`, `content/writing/**`, 해당 workflow 추가. API는 `apps/legacy-api/**` 및 해당 workflow. 웹 Node 26·API Node 22 유지. Lab-only/docs-only 변경은 앱 deploy 대상이 아님을 검토. API 배포 조건은 main만 유지하되, 구조 이전 릴리스에서 API까지 자동 배포할지 별도 승인 또는 임시 게이트 결정.
- **검증:** `apps/web`에서 `npm ci`, `npm run lint`, `npm run format:check`, `npm test`, `npm run typecheck`, `npm run build`; Node 22의 `apps/legacy-api`에서 `npm ci`, `npm test`, `npm run typecheck`; `git diff --check`. 테스트/빌드 실패 시 deploy가 진행되지 않는 needs/if 관계 확인.
- **트리거 완료 조건:** 웹 파일·각 content 영역·웹 workflow → 웹 QA, API 파일·API workflow → API QA, PR → deploy 없음, Lab/docs-only → 앱 deploy 없음. 선택한 branch/event마다 경로 조건을 표로 검토하고 승인된 PR에서 실제 QA 확인. migration branch push만으로 기존 workflow의 QA가 실행된다고 가정하지 않음.
- **위험:** old path가 남으면 검사 미실행 또는 build 실패. 기존 develop은 main보다 뒤처져 있어 기준 혼합 위험.
- **복구:** main/develop에 아직 반영하지 않은 staging 변경을 되돌림. 기존 CI와 원본 운영 유지. 이미 공유한 경우 경로 변경 커밋 revert를 PR로 준비하며 main push의 재배포도 승인 범위 확인.

### S4 — 무기능 Preview 및 로컬 루트 교체 (Phase 1 완료)

- **목표:** 구조 변경만으로 화면·접근 제어가 유지되는지 확인.
- **대상:** 승인된 develop/Preview 배포, 최종 로컬 루트; 기존 웹 public/config은 그대로.
- **작업:** Preview 배포 **별도 승인 후** 구조 변경만 올림. Node/tooling 차이를 포함해 develop 기준 정리. 원격 Preview 확인 후 staging을 최종 로컬 경로로 교체하되 이전 폴더는 비공개 backup 위치에 보존.
- **검증:** `node scripts/check-deployment.mjs https://preview-portfolio.leeeeeoy.xyz --protected`; 소유자 브라우저에서 `/`, `/?lang=en`, `/notes/`, 없는 Notes 상세, 테마·동의·모바일·키보드·이미지·서비스워커 확인. Production HTTP 검사 재실행. 최종 root Git/HEAD/refs/원격/단일 repo 확인.
- **완료:** baseline 동등성, 익명 차단 + 인증 사용자 정상 접근, Production 무변경, 로컬 원본 복구 가능.
- **위험:** Preview 공개 노출, 다른 env 배포, 원본 폴더 덮어쓰기. Access/noindex는 서로 다른 목적이므로 noindex만으로 보호를 대체하지 않음.
- **복구:** 원본 작업 경로 사용, 승인된 기존 Preview 버전 복원. 도메인/Access 변경으로 문제를 우회하지 않음.

### S5 — Home/Portfolio/Lab/Writing 라우트 (Phase 2)

- **목표:** 개인 웹사이트의 영역을 나누면서 기존 Portfolio 전체 보존.
- **대상:** App, SiteChrome, PortfolioPage, 최소 Home/Lab/Writing 화면, content.json의 UI, styles, index.html/public metadata, web test 및 check-deployment 스크립트.
- **작업:** `/portfolio/`로 기존 콘텐츠 제공, Home 간단 소개, 두 글 영역 빈 상태, 명확한 없는 경로 안내. section navigation과 저장된 scroll 목적지를 `/portfolio/`에 맞춤. `?lang=en`·테마/동의 키 유지. `/notes/`는 기술 기록 성격상 `/lab/` 안내/별칭을 권고하되 HTTP redirect 여부와 없는 slug 처리는 승인 후 확정. 무조건 모든 없는 Notes slug를 존재하는 글처럼 연결하지 않음.
- **검증:** Web 전체 QA + baseline 3경력/3프로젝트/4대표사례 및 양언어 사실·링크 유지 검사; 신규 route 직접 접근·새로고침·뒤로가기·section link·동의 전 Clarity 미로딩·reduced motion. 옛 루트 hash/외부 section 링크가 있다면 호환 확인. HTTP checker의 기존 고정 canonical 기대값도 새 페이지 정책에 맞춰 수정.
- **완료:** 정보 손실 없음, 역할이 구분된 네 경로 및 없는 경로 UI, 양언어 동작 유지. 이 단계만으로 운영 릴리스하지 않음.
- **위험:** 루트 링크 의미 변경, Home에서 경력 section 찾기 실패, 경로별 metadata의 Portfolio 오표기.
- **복구:** 해당 UI 커밋 revert, 구조 이전만 완료된 버전으로 복귀. 이전 production은 유지.

### S6 — Markdown 발행 파이프라인 (Phase 3)

- **목표:** Markdown 파일 변경만으로 두 독립 영역의 목록·상세 표시.
- **대상:** `content/lab`, `content/writing`, 최소 build-time loader/renderer·Vite 설정·콘텐츠 검사·웹 화면·메타데이터/sitemap·CI paths.
- **작업:** 파일명 slug 권고, title/date/summary 검증, 실제 날짜 검증, draft boolean 검증 및 누락 시 true, 영역별 중복 slug 거부. raw HTML/MDX 실행 차단, 위험 URL scheme 차단, 링크/이미지/코드/표 접근성 유지. 초안은 목록·상세·sitemap뿐 아니라 dist 데이터에서도 제외. dev에서 외부 content 갱신을 반영하도록 watch 확인.
- **검증:** 필수값 누락/잘못된 날짜/문자열 draft/중복 slug가 실패하는 작은 검사; 초안 원문 고유 marker가 dist에 없는지 검사. 두 영역 각각 published/draft fixture로 분리·목록·상세 확인, 코드블록·긴 표·alt·긴 URL·위험 링크 테스트. fixture는 공개 승인한 합성 내용만. Web 전체 QA와 Preview 수동 회귀.
- **완료:** 합성 fixture와 승인된 실제 글 1편으로 발행 경로 검증, 신규 콘텐츠-only 변경 CI 확인. 글은 한국어만 있어도 UI 영문에서 본문 언어를 명확히 표시; 영문 자동 생성 없음.
- **위험:** draft leak, HTML/script·URL 실행, bundle 크기 증가, invalid metadata의 조용한 누락, 한국어 글을 영어 본문으로 오표기.
- **복구:** 콘텐츠 파이프라인·샘플 커밋 revert 또는 발행 글을 draft로 전환해 승인된 재배포. Public Git의 민감 원문은 draft 전환으로 숨길 수 없으므로 애초에 넣지 않음.

### S7 — 실험 자산의 독립 이관 (Phase 4, 원본 확보 후)

- **목표:** 실제 Lab 코드·출처·재현성을 웹과 독립적으로 보존.
- **대상:** 확보한 `labs/<name>`의 코드/README/자체 의존성·소형 결과, 필요한 경우 해당 실험 CI, 관련 Lab 글의 코드 링크.
- **작업:** Go Load Lab 원본 경로·저작/기여·공개 허용·의존성을 확인한 후 이전. 실제 명령·환경·가설/실측·한계 작성. 웹 build에서 실행하지 않음. 외부 운영 서버에 부하를 보내지 않음.
- **검증:** Go라면 해당 디렉터리에서 `go test ./...`, 지원 환경에서 `go test -race ./...`, README의 로컬 실행 재현. 다른 언어는 해당 README 명령 사용. Lab-only 변경이 웹/API deploy를 유발하지 않는지 확인.
- **완료:** 독립 실행·테스트 및 측정 출처 확인, 비공개 데이터 없음. 원본 미확보면 보류로 남기고 웹 릴리스의 필수조건으로 만들지 않음.
- **위험:** 수치·코드 출처 혼동, 개인정보 포함 결과, 테스트 부하의 외부 유출.
- **복구:** 해당 Lab 신규 커밋만 되돌림. 웹과 운영 리소스 영향 없음.

### S8 — 운영 릴리스와 최종 기록 (Phase 5)

- **목표:** 승인한 개인 웹사이트 버전을 기존 도메인에 안전하게 전환.
- **대상:** 선택한 배포 주체 repo의 main, web Worker 배포, 최종 README/docs/active plan.
- **작업:** Preview 최종 확인, 현재/복구 Worker 배포 ID 재확인, GitHub Settings/Secrets/접근 제어 및 단일 배포 주체 확인. **main 병합·push 자체가 배포라는 점을 명시해 별도 승인**. API 동반 배포는 승인/게이트 결정에 따르며 D1/R2·Worker 삭제/rename은 하지 않음.
- **검증:** Web/API의 변경 범위 QA, 배포된 새 경로·기존 Notes 호환·alias path/query·영문 링크·헤더·자산 hash·R2 이미지·서비스워커 no-store·동의·모바일·Access 확인. 기존 checker의 신규 경로/metadata 기대값을 사용. main/dev 실제 Actions 결과 및 배포 대상 확인.
- **완료:** 변경한 사이트 실제 URL과 보호 정책 확인, 원본 복구 가능, 기존 리소스 보존, docs의 제안/완료/미검증 상태 갱신.
- **위험:** 두 repo 동시 배포, old develop 재배포, 의도치 않은 API 배포, SPA 200을 정상 글 존재의 근거로 착각.
- **복구:** 자동 배포 원인을 먼저 제어한 뒤 승인된 검증 버전으로 web Worker rollback/redeploy. layout 커밋까지 무조건 되돌리지 말고 마지막 정상 UI+경로 버전을 우선 사용. API가 배포됐다면 그 Worker는 별도 복구; DB/스토리지는 변경하지 않음. DNS·Access 정책은 현행 유지, 필요한 수정은 별도 승인.

## 4. 배포와 경로 변경 전 승인해야 할 결정

| 시점 | 결정 | 권고 / 미확정 |
|---|---|---|
| 실제 이전 시작 전 | A/B/C, 최종 로컬 루트 및 백업 위치 | A + `leeeeeoy/` 목표 권고; 확정 아님 |
| 실제 이전 시작 전 | GitHub 최종 이름, rename/새 repo 생성 여부 | 현 이름 유지로 시작 권고; rename은 독립 선택 |
| 문서/추적 변경 전 | 공통 AGENTS, 역사 문서 경로, CLAUDE 추적, 로컬 설정/캐시 제외 | 감사의 분류 제안 적용 여부 |
| 원본 폐기/로컬 교체 전 | DESIGN·SQL/query·resume 등 비공개 자산의 보존 | 공개 source와 분리, 원본 백업 유지 |
| UI/콘텐츠 구현 전 | 기존 공개 이메일 예외, `/notes/` 호환, slug/draft/Markdown 도구 | 현 연락처 유지 예외, 파일명 slug, 영역별 중복 금지, 초안 기본 true 권고 |
| develop push 전 | Preview 배포와 인증 사용자 검증 | 구조 검증용 Preview와 UI 릴리스 Preview를 구분 |
| main push/병합 전 | Production 배포 및 API 동반 배포 여부 | 웹 배포만 필요하면 API deploy를 임시 게이트로 막는 변경도 함께 승인 |
| 실제 글 게시 전 | 첫 글 내용/합성 예시 게시 여부 | 샘플을 사실·실측처럼 게시하지 않음 |

추가 라이브러리, 로그인/댓글/CMS/관리자/DB, SSR 프레임워크 전환, Cloudflare/GitHub 리소스 삭제·이전·Secrets 변경, 기존 이력 재작성은 이 계획의 승인에 자동 포함되지 않는다.

## 5. 이번 작업 종료 기록

- **추가 파일:** 감사 문서 `08-migration-audit-2026-10-14.md`, 이 실행 계획 `09-migration-execution-plan-2026-10-14.md`.
- **검사:** 현재 Frontend QA 전체 및 11개 테스트, Backend typecheck 및 1개 테스트, 원격 main/develop 참조, 운영/alias/Preview HTTP baseline. 상세 한계는 감사 7절에 기록.
- **남은 검증:** fresh npm ci, Backend Node 22, 브라우저, 관리 리소스/Secrets/보호 규칙/배포 ID, 전체 Git 역사 개인정보, Lab 원본.
- **다음 단일 작업:** 사용자의 Git 전략·루트·구조 이전 범위 승인 후 S0의 미확인 기준을 완성. 승인 전 실제 이전과 배포를 진행하지 않는다.

## 2026-10-14 Phase 1 승인에 따른 변경 기록

- Git 방식 A, 최종 로컬 루트 `leeeeeoy/`, repo 이름·origin 유지가 승인되었다. main/develop 변경·push·배포는 금지다.
- 원본 `.git`의 단순 이동 대신 전체 refs bundle에서 별도 작업본을 복원·검증한 후 루트에 적용한다. 기존 작업 폴더는 소유자 전용 backup 경로로 보존하며 이름 충돌로 덮어쓰지 않는다.
- 구조/문서/CI 경로만 수정하고 UI·데이터·연락처·Notes·보안/Access 설정을 유지한다. slug·Markdown·새 라우트 결정은 후속 단계에 남긴다.
- 운영/Preview 배포 및 관리 상태 검증은 보류다. 로컬 Phase 1 승인으로 S4/S8 배포 승인까지 받은 것으로 해석하지 않는다.

## 2026-10-14 Phase 2 구현 결정

기본 네 페이지와 내비게이션은 현재 migration branch에서 로컬 구현한다. Notes 주소·화면을 유지하고 Lab 안내를 추가하는 방식을 선택했다. 옛 root section hash와 저장된 섹션 이동은 Portfolio로 이어받는다. Markdown·글 상세·실험·배포는 제외한다. 실제 결과와 현재 한계는 [Phase 2 기록](11-phase2-pages-record-2026-10-14.md)에 남긴다.
