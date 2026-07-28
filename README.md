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
| 배포 | Cloudflare Pages |

```bash
cd frontend
npm install
npm test
npm run typecheck
npm run build
npm run dev
```

Vite 빌드 결과는 `frontend/dist/`에 생성됩니다.

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

- `frontend/**`: test, typecheck, build, SonarQube Quality Gate 후 Pages 배포
- `backend/**`: test, typecheck, SonarQube Quality Gate 후 Workers 배포
- `main`: Production
- `develop`: 검사만 실행

필요한 GitHub Secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `SONAR_TOKEN`

필요한 GitHub Repository Variables:

- `SONAR_ORGANIZATION`
- `SONAR_FRONTEND_PROJECT_KEY`
- `SONAR_BACKEND_PROJECT_KEY`

## Cloudflare

```text
사용자 ──▶ Pages (React SPA) ──▶ R2 (공개 이미지)
                    │
                    └─ Workers + D1 (기존 API, 정리 전 보존)
```

상세 전환 기준은 [포트폴리오 개편 계획](./docs/portfolio-renewal/README.md)을 참고합니다.
