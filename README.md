# leeeeeoy Portfolio

React 정적 SPA와 Cloudflare 인프라로 구성한 개인 포트폴리오 웹사이트입니다.

**URL:** https://portfolio.leeeeeoy.xyz

## 구조

```text
leeeeeoy_portfolio/
├── frontend/          # React + Vite 정적 SPA
├── backend/           # 기존 Cloudflare Workers API
├── docs/              # 개편 계획과 운영 문서
└── .github/workflows/ # 영역별 CI/CD
```

## Frontend

| 항목 | 내용 |
|---|---|
| UI | React 19 + TypeScript |
| Build | Vite 7 |
| 콘텐츠 | `src/content.json` 정적 데이터 |
| 스타일 | HTML/CSS 중심, 외부 UI·애니메이션 라이브러리 없음 |
| 이미지 | Cloudflare R2 |
| 배포 | Cloudflare Workers Static Assets |

```bash
cd frontend
npm install
npm test
npm run typecheck
npm run build
npm run dev
```

Vite 빌드 결과는 `frontend/dist/`에 생성됩니다.

기본 언어는 한국어이며 `?lang=en`으로 영어 버전을 공유할 수 있습니다.
상단 언어 링크와 내부 페이지 이동은 URL로 언어를 유지합니다.
공개 본문과 UI 문구는 `src/content.json`의 `ko`·`en`에서 함께 관리합니다.
JavaScript 실행 전의 검색·공유 미리보기 HTML은 기존 한국어 버전을 사용합니다.

## Backend

기존 Cloudflare Workers + Hono API는 새 Frontend가 안정화될 때까지 유지합니다.
현재 Frontend는 공개 콘텐츠를 빌드에 포함하므로 API를 호출하지 않습니다.

| 항목 | 내용 |
|---|---|
| Runtime | Cloudflare Workers |
| Framework | Hono |
| Database | Cloudflare D1 |
| Storage | Cloudflare R2 |
| Deploy | Wrangler |

```bash
cd backend
npm install
npm test
npm run deploy
```

## CI/CD

GitHub Actions는 변경된 영역만 검사하고 배포합니다.

- `frontend/**`: test, typecheck, build 후 Workers Static Assets 배포
- `backend/**`: test, typecheck 후 Workers 배포
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

상세 전환 기준은 [포트폴리오 개편 계획](./docs/portfolio-renewal/README.md)을 참고합니다.

## Workers 운영

- `frontend/wrangler.jsonc`로 정적 파일만 배포합니다. Worker 서버 코드와 DB 바인딩은 없습니다.
- `develop`: `preview-portfolio.leeeeeoy.xyz`에 배포하며 Cloudflare Access로 소유자만 접근합니다.
- `main`: `portfolio.leeeeeoy.xyz/*` Worker Route로 제공합니다. 기존 Pages와 DNS는 복구용으로 남습니다.
- `workers.dev`와 버전 미리보기 URL은 비활성화해 Access 우회를 막습니다.
- `_headers`는 보안 헤더와 해시 파일의 1년 브라우저 캐시를 설정합니다. HTML은 기본 재검증 정책을 유지합니다.
- 운영 장애 시 해당 Worker Route를 제거하면 보존한 Pages 배포로 돌아갑니다.
- 무료 정적 파일 요청과 Worker 코드 실행 한도는 별개입니다. 이후 API를 추가하면 별도 한도를 확인합니다.

배포 후 검증은 `frontend`에서 다음 스크립트로 실행합니다.

```bash
node scripts/check-deployment.mjs https://portfolio.leeeeeoy.xyz
node scripts/check-deployment.mjs https://preview-portfolio.leeeeeoy.xyz --protected
```

이 검증은 운영 경로·헤더·배포 파일을 확인합니다. 미리보기에서는 익명 Access 응답을 확인하며, 소유자 로그인은 브라우저에서 별도로 확인합니다. GitHub 호스팅 러너는 기존 Cloudflare 보안 설정에 의해 Managed Challenge를 받을 수 있어 이 외부 접속 검증을 CI의 배포 성공 조건에는 넣지 않습니다.
