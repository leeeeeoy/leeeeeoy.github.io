# Source Repository — 확인된 상태와 과거 문서 구분

확인 기준: 2026-10-14, 기존 main `dad0449c6350c4ba8f618cb4d03a52bcee42af6b`에서 로컬 Phase 1 구조 이전. repo·origin·main/develop 참조를 보존하며 배포하지 않는다. [Phase 0 감사](08-migration-audit-2026-10-14.md)는 이전 전 스냅샷, [Phase 1 기록](10-phase1-migration-record-2026-10-14.md)은 이번 검사 근거다. Cloudflare 관리 상태·Secrets·배포 ID는 재조회하지 않았다.

## 확인한 파일과 사실

| 위치 | 확인된 내용 | 이전 시 의미 |
|---|---|---|
| `apps/web/` | React 19, TypeScript, Vite 7, Node 26 (`.nvmrc`) | 현재 위치; 소스 내용 보존 |
| `apps/web/src/content.json` | 한국어/영어 공개 프로필·경력·프로젝트 정적 데이터 | Portfolio의 원본으로 유지 |
| `apps/web/src/App.tsx` | URL pathname으로 `/notes/` 분기, 테마, Clarity 동의 | 라우팅/동의 동작 회귀 주의 |
| `apps/web/src/notes.ts` | `Engineering`, `Decision` 범주, `notes: Note[] = []` | 글 작성/렌더링 시스템은 확장 필요 |
| `apps/web/src/pages/NotesPage.tsx` | 제목·요약·태그·문단 리스트 렌더링 | Markdown 코드/표/이미지 표시 신규 요구 |
| `apps/web/test/content.test.mjs` | 경력·개인정보, `/notes/` 빈 목록, SPA 라우팅 등 문자열 기반 검증 | 경로 변경 시 검증 의도 유지하며 수정 |
| `apps/web/wrangler.jsonc` | Workers Static Assets, SPA fallback, Production·Preview Custom Domain | 경로 이동 시 Wrangler working dir 확인 |
| `apps/web/public/_headers` | 보안·캐시 응답 헤더 | 무단 변경 금지 |
| `.github/workflows/frontend-ci.yml` | `apps/web/**`, `content/lab/**`, `content/writing/**` 변경 때 테스트·빌드·배포, main/develop 구분 | workflow 경로 반영; content는 아직 build 입력 아님 |
| `apps/legacy-api/`와 `apps/legacy-api/wrangler.toml` | Worker/Hono/D1/R2 구성 | 현 위치에서 binding·vars 보존, 삭제 금지 |
| `.github/workflows/backend-ci.yml` | Backend 테스트, main 배포 | 경로만 변경, Node 22/main-only deploy 유지 |
| `README.md`와 `AGENTS.md` | 현재 웹/백엔드·보호 규칙·개인정보 규칙 | 목표 구조에 맞게 재작성하되 원칙 계승 |
| `docs/archive/portfolio-renewal/` | 2026년 이전 개편 당시 계획·의사결정 | 과거 판단의 기록으로 보존 |
| `apps/web/public/sitemap.xml` | 홈페이지 한 URL | 새 공개 글/경로 추가 시 갱신 검토 |

## 서로 다른 시대의 문서가 공존한다

- `docs/archive/portfolio-renewal/03-frontend-migration-plan.md`, `04-execution-phases.md`는 Flutter Web → React 전환과 **Cloudflare Pages**를 계획한다.
- **현재** `README.md`, `wrangler.jsonc`, CI는 React + **Cloudflare Workers Static Assets**를 사용한다.
- 과거 문서의 단일 `/` 페이지, `portfolio.leeeeeoy.xyz` canonical, Pages 관련 계획을 **현행 지침으로 재실행하지 않는다**.
- 현재 메인 도메인은 `leeeeeoy.xyz`, 기존 `portfolio.leeeeeoy.xyz` 및 `www`는 기존 문서상 리다이렉션 대상이고 `preview-portfolio.leeeeeoy.xyz`는 Access 보호 환경이다. 실제 라우팅은 배포 시 확인한다.
- 기존 앱 규칙은 루트 AGENTS로 통합했고 `labs/` 전체에 강제하지 않는다. 원문은 `archive/portfolio-renewal/legacy-agents.md`에 보존한다.

## 로컬 전환 결정 및 릴리스 전 미확인 항목

- 기존 main/develop과 모든 로컬 refs는 백업·복원 후 대조한다. 최신 원격 참조 조회 결과는 Phase 0 기록이며 이번 단계는 로컬 작업이다.
- Workers Static Assets 배포에서 사용하는 토큰·Secrets·환경·커스텀 도메인 소유 관계
- legacy API의 외부 사용처, D1 데이터 백업 여부
- 현재 사이트의 각 URL 및 모바일/데스크톱 스냅샷
- Go Load Lab 실험의 **실제 소스 경로**(현재 포트폴리오 레포에는 존재하지 않음)
- 방식은 기존 GitHub repo·이력·origin 유지, 로컬 루트 `leeeeeoy/` 전환으로 사용자 승인되었다. 새 repo·rename·push는 실행하지 않는다.

> 기존 실무 이력과 수치는 웹의 `content.json`을 보존하는 것이 이번 프로젝트의 기본이며, 개편 과정에서 임의로 새 경력 데이터를 생성하지 않는다.
