# Architecture — 한눈에 보는 구조

## 목적

개인 웹사이트(`Home`, `Portfolio`, `Lab`, `Writing`)와 실행 가능한 실험을 **하나의 Git 저장소**에 둔다. Lab은 기술적 호기심·이론·검증, Writing은 생활·생각·회고다. Portfolio는 경력과 프로젝트를 보여주는 하나의 페이지다. 독립 About 페이지는 추후 필요할 때 만든다.

## 현재 구조 (Phase 2 로컬 페이지)

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

- 현재 `apps/web`은 정적 경력/UI JSON으로 네 페이지와 Notes 호환 화면을 제공한다. `content/lab`, `content/writing`는 빈 디렉터리이며 Markdown 연결은 Phase 3에서 구현한다. 목표는 build-time 데이터 공급이며 초기 HTML 생성(SSG)을 뜻하지 않는다. **런타임 콘텐츠 API 추가 금지**.
- `apps/web` → 기존 Cloudflare R2의 공개 이미지 URL 사용. 인증/백엔드 호출 불필요.
- `apps/legacy-api` → **기존 사용처와 리소스가 확인될 때까지 보존**. 웹에서 신규 의존하지 않는다.
- `labs/*` → 각 실험별 독립 실행. `apps/web`에서 Lab 코드를 import하지 않는다.
- 실험 결과는 글에서 GitHub의 파일/커밋 링크로 참조한다. 웹 빌드에서 Go 실험을 실행하지 않는다.

## 현재 웹 라우트

| 경로 | 역할 |
|---|---|
| `/` | 간단 소개와 세 영역으로 가는 링크. 경력·프로젝트 중복 표시 없음 |
| `/portfolio/` | 기존 Portfolio 본문 전체와 경력/프로젝트/기술 섹션 메뉴 |
| `/lab/` | 기술 학습·실험 공간의 소개와 빈 목록 |
| `/writing/` | 일상·생각·회고 공간의 소개와 빈 목록 |
| `/notes/`, `/notes/:slug/` | 기존 목록·상세/없는 글 화면 유지, Lab 안내 제공 |
| 그 밖의 경로 | 페이지 없음 UI. SPA fallback이므로 HTTP 404 보장은 아님 |

일반 anchor와 pathname 분기로 이동하며 React Router는 추가하지 않았다. 끝의 slash가 없는 기본 경로도 지원한다. `?lang=en`과 테마·동의 저장을 유지한다. 옛 `/#experience`, `/#projects`, `/#skills`는 쿼리·해시를 보존해 브라우저에서 `/portfolio/`로 replace한다. 예전 저장된 섹션 이동도 이어받는다. 서버 301/DNS/Access 정책을 변경한 것은 아니다.

`/lab/:slug/`, `/writing/:slug/`의 실제 글과 Markdown 처리는 Phase 3의 후속 범위이며 현재는 페이지 없음 UI다. `/about/` 독립 페이지는 만들지 않는다. 초기 HTML은 하나의 공통 정적 셸이고 경로별 본문·메타데이터는 브라우저에서 적용한다.

## 스택·배포

기존 웹 스택(React 19/Vite 7/TypeScript, 웹 Node 26 / API CI Node 22), Cloudflare **Workers Static Assets** 및 R2, CI의 main Production / develop Preview를 우선 유지한다. Cloudflare Pages로 회귀하거나 새 DB·인증을 붙이지 않는다. 성능·SEO 요구가 확인되지 않은 상태에서 Next.js/SSG/SSR를 강제하지 않는다.

자세한 경계·결정 게이트는 `docs/02-target-architecture.md`와 `docs/04-migration-plan.md`에 따른다.
