# Source Repository — 확인된 상태와 과거 문서 구분

확인 기준: 2026-10-25. Home/Portfolio/Lab/Writing은 Cloudflare Workers에서 운영하며 Notes 호환 경로를 유지한다. 운영 API의 방문 등록·중복 제외와 Secret의 CI 재배포 후 보존을 확인했다. Lab 원본 결과와 첫 글 초안(draft:true)은 로컬에만 보존하며 공개 글은 0개다. 저장소 이름은 `leeeeeoy/personal-space`로 변경했고 구형 GitHub Pages는 해제했다.

과거 구조 이전의 근거는 [Phase 0 감사](../archive/work-records/08-migration-audit-2026-10-14.md)부터 [Phase 3 기록](../archive/work-records/12-phase3-content-record-2026-10-14.md)까지 보존한다. 이번 공개 이력 정리와 미검증 범위는 [후속 감사](../archive/work-records/18-post-release-privacy-audit-2026-10-25.md)에 구분한다.

## 확인한 파일과 사실

| 위치                                   | 확인된 내용                                                                                            | 이전 시 의미                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| `apps/web/`                            | React 19, TypeScript, Vite 7, Node 26 (`.nvmrc`)                                                       | 현재 위치; 소스 내용 보존                                     |
| `apps/web/src/content.json`            | 한국어/영어 공개 프로필·경력·프로젝트 정적 데이터                                                      | Portfolio의 원본으로 유지                                     |
| `apps/web/src/App.tsx`                 | routes.ts의 명시적 pathname 분기, 기본 페이지·Markdown 목록/상세·Notes·없는 경로 UI, 테마·Clarity 동의 | 라우팅/동의 동작 회귀 주의                                    |
| `apps/web/src/notes.ts`                | `Engineering`, `Decision` 범주, `notes: Note[] = []`                                                   | Legacy 주소·데이터 보존; 새 Markdown 영역과 분리              |
| `apps/web/src/pages/NotesPage.tsx`     | 제목·요약·태그·문단 리스트 렌더링                                                                      | 기존 Notes 렌더러 유지; Markdown은 RecordPage                 |
| `apps/web/test/content.test.mjs`       | 경력·개인정보, `/notes/` 빈 목록, SPA 라우팅 등 문자열 기반 검증                                       | 경로 변경 시 검증 의도 유지하며 수정                          |
| `apps/web/wrangler.jsonc`              | Workers Static Assets, SPA fallback, Production·Preview Custom Domain                                  | 경로 이동 시 Wrangler working dir 확인                        |
| `apps/web/public/_headers`             | 보안·캐시 응답 헤더                                                                                    | 무단 변경 금지                                                |
| `.github/workflows/frontend-ci.yml`    | `apps/web/**`, `content/lab/**`, `content/writing/**` 변경 때 테스트·빌드·배포, main/develop 구분      | content 검증·빌드 입력 연결, 기존 branch/event/path 정책 유지 |
| `labs/go-load-test/`                   | 새 표준 라이브러리 HTTP 실험, 본42회·보조검증·그래프·README                                            | 과거 원본 복원이 아닌 독립 구현                               |
| `apps/api/`와 `apps/api/wrangler.toml` | Worker/Hono/D1/R2 구성                                                                                 | 현 위치에서 binding·vars 보존, 삭제 금지                      |
| `.github/workflows/backend-ci.yml`     | API 테스트, main 운영·develop Preview 배포                                                             | Node 22, Preview D1 격리·집계 읽기 전용                       |
| `README.md`와 `AGENTS.md`              | 현재 웹/백엔드·보호 규칙·개인정보 규칙                                                                 | 목표 구조에 맞게 재작성하되 원칙 계승                         |
| `docs/archive/portfolio-renewal/`      | 2026년 이전 개편 당시 계획·의사결정                                                                    | 과거 판단의 기록으로 보존                                     |
| `apps/web/public/sitemap.xml`          | Home/Portfolio/Lab/Writing 네 URL                                                                      | 새 공개 글/경로 추가 시 갱신 검토                             |

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
- 과거 Go Load Lab 원본은 미확보. 사용자 지시로 만든 새 실험의 소스/결과는 labs/go-load-test에 있으며 과거 결과와 동일하다고 주장하지 않음
- 방식은 기존 GitHub repo·이력·origin 유지, 로컬 루트 `leeeeeoy/` 전환으로 사용자 승인되었다. 당시 로컬 이전에서는 새 repo·rename·push를 실행하지 않았다. 이후 운영 반영과 저장소 이름 변경은 별도 사용자 승인으로 진행했다.

> 기존 실무 이력과 수치는 웹의 `content.json`을 보존하는 것이 이번 프로젝트의 기본이며, 개편 과정에서 임의로 새 경력 데이터를 생성하지 않는다.
