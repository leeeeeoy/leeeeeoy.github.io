# Architecture — 한눈에 보는 구조

## 목적

개인 웹사이트(`Home`, `Portfolio`, `Lab`, `Writing`)와 실행 가능한 실험을 **하나의 Git 저장소**에 둔다. Lab은 기술적 호기심·이론·검증, Writing은 생활·생각·회고다. Portfolio는 경력과 프로젝트를 보여주는 하나의 페이지다. 독립 About 페이지는 추후 필요할 때 만든다.

## 현재 구조 (Phase 4 로컬 실험·초안)

```text
leeeeeoy/
├── apps/
│   ├── web/                 # 기존 React 19 + Vite + TS
│   └── legacy-api/          # 기존 Worker + Hono, 보존
├── content/
│   ├── lab/                 # 공개 기술 글(Markdown)
│   └── writing/             # 공개 개인 글(Markdown)
├── labs/
│   └── go-load-test/        # 독립 Go HTTP 실험·원본 결과·재현 문서
├── docs/
│   ├── README.md
│   ├── guides/             # 현재 유효한 상세 설계·운영 기준
│   ├── archive/            # 과거 설계·Phase별 작업/검증 기록
│   ├── exec-plans/active/
├── templates/              # 연구 계획·근거 기록·글 양식
├── .github/workflows/
├── AGENTS.md
├── CLAUDE.md
└── ARCHITECTURE.md
```

## 의존 관계

- `apps/web`은 정적 경력/UI JSON과 빌드 시 검증한 Markdown으로 기본 페이지·글 상세·Notes 호환 화면을 제공한다. `content/lab`에는 첫 Go 실험 초안(draft:true)이 있고 공개 글은 0개라 목록은 비어 있다. Writing도 공개 글이 없다. Vite virtual module에는 공개 글만 포함하며 YAML 파서는 빌드 전용이다. 이는 초기 HTML 생성(SSG)을 뜻하지 않는다. **런타임 콘텐츠 API 추가 금지**.
- `apps/web` → 기존 Cloudflare R2의 공개 이미지 URL 사용. 인증/백엔드 호출 불필요.
- `apps/legacy-api` → **기존 사용처와 리소스가 확인될 때까지 보존**. 웹에서 신규 의존하지 않는다.
- `labs/*` → 각 실험별 독립 실행. `apps/web`에서 Lab 코드를 import하지 않는다.
- 실험 결과는 글에서 GitHub의 파일/커밋 링크로 참조한다. 웹 빌드에서 Go 실험을 실행하지 않는다.

## 현재 웹 라우트

| 경로 | 역할 |
|---|---|
| `/` | 간단 소개와 세 영역으로 가는 링크. 경력·프로젝트 중복 표시 없음 |
| `/portfolio/` | 기존 Portfolio 본문 전체와 경력/프로젝트/기술 섹션 메뉴 |
| `/lab/` | 기술 학습·실험 공간의 소개와 공개 글 목록/빈 상태 |
| `/writing/` | 일상·생각·회고 공간의 소개와 공개 글 목록/빈 상태 |
| `/lab/:slug/`, `/writing/:slug/` | Markdown 상세·없는 글 안내와 목록 복귀 |
| `/notes/`, `/notes/:slug/` | 기존 목록·상세/없는 글 화면 유지, Lab 안내 제공 |
| 그 밖의 경로 | 페이지 없음 UI. SPA fallback이므로 HTTP 404 보장은 아님 |

일반 anchor와 pathname 분기로 이동하며 React Router는 추가하지 않았다. 끝의 slash가 없는 기본 경로도 지원한다. `?lang=en`과 테마·동의 저장을 유지한다. 옛 `/#experience`, `/#projects`, `/#skills`는 첫 진입과 같은 문서의 hashchange 모두 쿼리·해시를 보존해 브라우저에서 `/portfolio/`로 replace한다. 예전 저장된 섹션 이동도 이어받는다. 서버 301/DNS/Access 정책을 변경한 것은 아니다.

slug는 소문자 영문·숫자·하이픈 파일명에서 결정한다. 같은 영역의 slug 중복은 실패한다. draft 생략/true는 목록·상세·빌드 번들에서 제외한다. [콘텐츠 계약](docs/guides/03-content-and-writing.md)과 [Phase 3 기록](docs/archive/work-records/12-phase3-content-record-2026-10-14.md)을 따른다. `/about/` 독립 페이지는 만들지 않는다. 초기 HTML은 하나의 공통 정적 셸이고 경로별 본문·메타데이터는 브라우저에서 적용한다.

## 스택·배포

기존 웹 스택(React 19/Vite 7/TypeScript, 웹 Node 26 / API CI Node 22), Cloudflare **Workers Static Assets** 및 R2, CI의 main Production / develop Preview를 우선 유지한다. Cloudflare Pages로 회귀하거나 새 DB·인증을 붙이지 않는다. 성능·SEO 요구가 확인되지 않은 상태에서 Next.js/SSG/SSR를 강제하지 않는다.

자세한 경계·결정 게이트는 `docs/guides/02-target-architecture.md`와 `docs/guides/04-migration-plan.md`에 따른다.
