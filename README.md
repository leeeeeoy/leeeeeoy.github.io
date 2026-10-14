# leeeeeoy — Personal Space

개인의 경험·생각·기술적 호기심을 기록하는 웹사이트와 독립 실험을 관리합니다.
현재 Phase 1은 로컬 구조 이전만 완료하며, 운영 UI와 `/`, `/notes/` 동작은 기존 포트폴리오 그대로입니다. Home/Lab/Writing UI와 Markdown 파이프라인은 다음 단계입니다.

**URL:** https://leeeeeoy.xyz

## 구조

```text
leeeeeoy/
├── apps/web/          # 기존 React + Vite 정적 SPA
├── apps/legacy-api/   # 기존 Worker/Hono/D1/R2 보존
├── content/lab/       # 기술 글용 디렉터리, 아직 빌드 입력 아님
├── content/writing/   # 개인 글용 디렉터리, 아직 빌드 입력 아님
├── labs/              # 독립 실험용 디렉터리, 코드 미확보
├── docs/              # 현행 설계·계획 + archive 역사 기록
├── templates/         # 글/실험 템플릿
└── .github/workflows/ # 영역별 CI/CD
```

## Frontend

| 항목 | 내용 |
|---|---|
| UI | React 19 + TypeScript |
| Build | Vite 7 |
| 개발 환경 | Node.js 26.x (`apps/web/.nvmrc`) |
| 코드 검사·포맷 | ESLint + TypeScript/React Hooks 권장 규칙, Prettier |
| 콘텐츠 | `src/content.json` 정적 데이터 |
| 스타일 | HTML/CSS 중심, 외부 UI·애니메이션 라이브러리 없음 |
| 이미지 | Cloudflare R2 |
| 배포 | Cloudflare Workers Static Assets |

```bash
cd apps/web
npm ci
npm run lint
npm run format:check
npm test
npm run typecheck
npm run build
npm run dev
```

Vite 빌드 결과는 `apps/web/dist/`에 생성됩니다.

Frontend의 로컬 개발과 CI는 Node.js 26.x를 사용합니다. nvm을 사용한다면
`apps/web`에서 `nvm use`로 버전을 선택합니다. `npm run lint:fix`는 린터의
자동 수정, `npm run format`은 코드 포맷을 적용합니다. TypeScript는 현재 5.9를 유지합니다.

기본 언어는 한국어이며 `?lang=en`으로 영어 버전을 공유할 수 있습니다.
상단 언어 링크와 내부 페이지 이동은 URL로 언어를 유지합니다.
공개 본문과 UI 문구는 `src/content.json`의 `ko`·`en`에서 함께 관리합니다.
JavaScript 실행 전의 검색·공유 미리보기 HTML은 기존 한국어 버전을 사용합니다.

## Backend

기존 Cloudflare Workers + Hono API와 D1/R2 바인딩을 보존합니다. Backend CI의 Node.js는 22이며 Frontend Node 26과 독립적으로 검사합니다.
현재 Frontend는 공개 콘텐츠를 빌드에 포함하므로 API를 호출하지 않습니다.

| 항목 | 내용 |
|---|---|
| Runtime | Cloudflare Workers |
| Framework | Hono |
| Database | Cloudflare D1 |
| Storage | Cloudflare R2 |
| Deploy | Wrangler |

```bash
cd apps/legacy-api
npm ci
npm run typecheck
npm test
```

## CI/CD

GitHub Actions는 변경된 영역만 검사하고 배포합니다.

- `apps/web/**`, `content/lab/**`, `content/writing/**`: 웹 검사와 배포 대상. 콘텐츠는 아직 빌드에 연결되지 않았습니다.
- `apps/legacy-api/**`: test, typecheck 후 Workers 배포
- `main`: Production
- `develop`: Frontend Preview

필요한 GitHub Secrets:

- `CLOUDFLARE_FRONTEND_API_TOKEN` (Frontend: Workers Scripts Write, 해당 Zone의 Workers Routes Write·Zone Read)
- `CLOUDFLARE_API_TOKEN` (기존 Backend)
- `CLOUDFLARE_ACCOUNT_ID`

## Cloudflare

```text
사용자 ──▶ Workers Static Assets (React SPA) ──▶ R2 (공개 이미지)
                    │
                    └─ 이전 API Worker·D1 설정 (Frontend는 호출하지 않음)
```

현재 지침은 [AGENTS](AGENTS.md), 경계는 [ARCHITECTURE](ARCHITECTURE.md), 상세 문서는 [docs 인덱스](docs/README.md)를 참고합니다.
이전 판단은 [역사 문서](docs/archive/portfolio-renewal/README.md), 실행 근거는 [Phase 1 기록](docs/10-phase1-migration-record-2026-10-14.md)에 보존합니다.

## Workers 운영

- `apps/web/wrangler.jsonc`로 정적 파일만 배포합니다. Worker 서버 코드와 DB 바인딩은 없습니다.
- `develop`: `preview-portfolio.leeeeeoy.xyz`에 배포하며 Cloudflare Access로 소유자만 접근합니다.
- `main`: `leeeeeoy.xyz` Workers Custom Domain으로 제공합니다. `www.leeeeeoy.xyz`와 기존 `portfolio.leeeeeoy.xyz`는 경로·쿼리를 유지해 대표 주소로 301 이동합니다. Pages 삭제·이전 Firebase Hosting 비활성화는 기존 README에 기록된 이력이며 이번 로컬 이전에서 관리 상태를 재조회하지 않았습니다.
- `workers.dev`와 버전 미리보기 URL은 비활성화해 Access 우회를 막습니다.
- `_headers`는 보안 헤더와 해시 파일의 1년 브라우저 캐시를 설정합니다. HTML은 기본 재검증 정책을 유지합니다.
- 운영 장애 시 검증된 이전 Worker 버전을 재배포하거나 rollback합니다. Pages로 자동 복귀하지 않습니다.
- 이전 Flutter의 서비스 워커 URL에는 등록 해제용 파일을 제공하며 `no-store`로 응답합니다. 새 앱은 서비스 워커를 등록하지 않습니다.
- 무료 정적 파일 요청과 Worker 코드 실행 한도는 별개입니다. 이후 API를 추가하면 별도 한도를 확인합니다.

배포 후 검증은 `apps/web`에서 다음 스크립트로 실행합니다.

```bash
node scripts/check-deployment.mjs https://leeeeeoy.xyz
node scripts/check-deployment.mjs https://www.leeeeeoy.xyz --redirect-to=https://leeeeeoy.xyz
node scripts/check-deployment.mjs https://portfolio.leeeeeoy.xyz --redirect-to=https://leeeeeoy.xyz
node scripts/check-deployment.mjs https://preview-portfolio.leeeeeoy.xyz --protected
```

이 검증은 운영 경로·헤더·배포 파일을 확인합니다. 미리보기에서는 익명 Access 응답을 확인하며, 소유자 로그인은 브라우저에서 별도로 확인합니다. GitHub 호스팅 러너는 기존 Cloudflare 보안 설정에 의해 Managed Challenge를 받을 수 있어 이 외부 접속 검증을 CI의 배포 성공 조건에는 넣지 않습니다.

## 로컬 이전과 배포 승인

현재 브랜치는 `migration/phase1-monorepo`이며 기존 `main`/`develop`과 origin URL은 유지합니다. 이번 단계에서 push·배포·Cloudflare 변경은 하지 않습니다.
문서·템플릿·Lab-only 변경은 앱 workflow를 실행하지 않습니다. PR은 검사만, main push는 Production, develop push는 웹 Preview라는 기존 정책을 유지합니다.
구조 이전 커밋에는 웹과 API 경로 및 두 workflow 변경이 모두 있으므로 향후 main에 반영하면 두 배포가 대상이 됩니다. API 동반 배포 승인 또는 별도 제한 방침 없이 main에 반영하지 않습니다.
비공개 원본·로컬 설정은 공개 트리 밖에 백업하며 `resume/`, `.claude/`, `.wrangler/`, 비밀파일은 새 추적 목록에서 제외합니다.
