# Architecture — 한눈에 보는 구조

## 목적

개인 웹사이트(`Home`, `Portfolio`, `Lab`, `Writing`)와 실행 가능한 실험을 **하나의 Git 저장소**에 둔다. Lab은 기술적 호기심·이론·검증, Writing은 생활·생각·회고다. Portfolio는 경력과 프로젝트를 보여주는 하나의 페이지다. 독립 About 페이지는 추후 필요할 때 만든다.

## 현재 구조 (Phase 1 로컬 이전)

```text
leeeeeoy/
├── apps/
│   ├── web/                 # 기존 React 19 + Vite + TS
│   └── legacy-api/          # 기존 Worker + Hono, 보존
├── content/
│   ├── lab/                 # 공개 기술 글(Markdown)
│   └── writing/             # 공개 개인 글(Markdown)
├── labs/
│   └── .gitkeep             # 원본 확보 전, 실험 코드 없음
├── docs/
│   ├── README.md
│   ├── exec-plans/active/
│   └── ...                  # 상세 설계·운영 기준
├── templates/
├── .github/workflows/
├── AGENTS.md
├── CLAUDE.md
└── ARCHITECTURE.md
```

## 의존 관계

- 현재 `apps/web`은 기존 공개 경력 JSON·Notes만 사용한다. `content/lab`, `content/writing`는 빈 디렉터리이며 Markdown 연결은 Phase 3에서 구현한다. 목표는 build-time 데이터 공급이며 초기 HTML 생성(SSG)을 뜻하지 않는다. **런타임 콘텐츠 API 추가 금지**.
- `apps/web` → 기존 Cloudflare R2의 공개 이미지 URL 사용. 인증/백엔드 호출 불필요.
- `apps/legacy-api` → **기존 사용처와 리소스가 확인될 때까지 보존**. 웹에서 신규 의존하지 않는다.
- `labs/*` → 각 실험별 독립 실행. `apps/web`에서 Lab 코드를 import하지 않는다.
- 실험 결과는 글에서 GitHub의 파일/커밋 링크로 참조한다. 웹 빌드에서 Go 실험을 실행하지 않는다.

## 현재 라우트와 향후 제안

Phase 1에서는 `/` Portfolio, `/notes/` 목록, `/notes/:slug/` 상세/없는 글 안내를 그대로 유지한다. 아래 라우트는 Phase 2 이후의 제안이며 아직 구현하지 않았다.

| 경로 | 역할 |
|---|---|
| `/` | Home: 간단 소개와 최신 기록 링크 |
| `/portfolio/` | 기존 포트폴리오 정보의 전체 보기 |
| `/lab/`, `/lab/:slug/` | 기술 글·검증 기록 |
| `/writing/`, `/writing/:slug/` | 회고·일상·생각 |

실제 구현 전 기존 `/`, `/notes/`, `/notes/:slug/` 처리와 외부 링크를 점검한다. 미발행 Notes 페이지라도 기존 동작을 깨뜨리지 않도록 리다이렉션/별칭/404를 명시적으로 결정한다. `/about/` 독립 페이지는 이번 범위가 아니다.

## 스택·배포

기존 웹 스택(React 19/Vite 7/TypeScript, 웹 Node 26 / API CI Node 22), Cloudflare **Workers Static Assets** 및 R2, CI의 main Production / develop Preview를 우선 유지한다. Cloudflare Pages로 회귀하거나 새 DB·인증을 붙이지 않는다. 성능·SEO 요구가 확인되지 않은 상태에서 Next.js/SSG/SSR를 강제하지 않는다.

자세한 경계·결정 게이트는 `docs/02-target-architecture.md`와 `docs/04-migration-plan.md`에 따른다.
