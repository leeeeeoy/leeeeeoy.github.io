# AGENTS.md — Personal Space

이 저장소는 **개인의 경험·호기심·생각을 기록하는 공개 웹사이트**와 실행 가능한 기술 실험을 관리한다. 이직용 포트폴리오가 프로젝트 전체의 목적이 아니다.

추측하지 말고 객관적으로 답한다. 사용자 의견에 근거 없이 동의하지 않는다.

Home/Portfolio/Lab/Writing과 Notes 호환 경로, Markdown 목록·상세를 운영에서 제공한다. Engineering Lab Harness와 독립 Go 실험을 관리하며, 실험 원본 결과와 첫 Lab 초안(draft:true)은 사용자 결정에 따라 로컬에 보존하고 커밋하지 않는다. 공개 글은 0개다. 저장소는 `leeeeeoy/personal-space`이며 배포는 Cloudflare Workers를 사용한다. [콘텐츠 계약](docs/guides/03-content-and-writing.md)을 따른다.

## 시작할 때 읽기

1. [ARCHITECTURE.md](ARCHITECTURE.md) — 경계와 구조 요약
2. [docs/README.md](docs/README.md) — 과제별 상세 문서 안내
3. 해당 변경 범위의 문서 및 실제 소스 코드만 읽는다. **모든 문서를 매번 읽지 않는다.**
4. 모노레포 이전 작업이면 [active plan](docs/exec-plans/active/site-migration.md)의 현재 단계만 진행한다.
5. 새 기술 질문을 탐구할 때는 [Lab Workflow](docs/guides/14-engineering-lab-workflow.md)를 따른다. 기본은 계획 후 승인 대기이며 승인된 범위는 다시 묻지 않는다. 결과는 핵심 답→원리→근거로 전달하고 이해 대화는 선택 사항이다. 후속 연구·초안·공개 승인은 구분한다.
6. 진단·리뷰·문서·보안 점검은 [작업별 검증 안내](docs/guides/08-agent-workflow.md)에서 해당 절차만 선택한다. 설치된 모든 스킬이나 전체 작업 모드를 중첩하지 않는다.

## 절대 지킬 규칙

- 사용자가 승인하지 않은 push, Production/Preview 배포, Cloudflare 리소스 삭제·이전, GitHub 저장소 변경, Secrets 변경을 실행하지 않는다.
- Cloudflare 작업은 프로젝트에 Wrangler 설정이 있으면 Wrangler를 사용하고, 없으면 cf CLI를 사용한다. 작업 범위는 현재 사용자 지시를 따르며 과거 세션의 일회성 승인을 다음 작업에 자동 적용하지 않는다.
- 기존 `leeeeeoy.xyz`, `preview-portfolio.leeeeeoy.xyz`, `portfolio.leeeeeoy.xyz`, `www.leeeeeoy.xyz`의 라우팅·접근 제어를 의도치 않게 변경하지 않는다.
- 확인된 운영 경력과 개인 실험 결과를 섞거나, 측정하지 않은 수치를 사실로 쓰지 않는다.
- 개인정보·회사 비공개 데이터·인증 정보는 커밋하지 않는다. `docs/guides/06-quality-and-safety.md`를 확인한다.
- 현 단계에서는 인증, 회원, 댓글, 관리자 UI, CMS, DB 추가, SSR 프레임워크 전환을 구현하지 않는다.
- Lab은 독립 실행을 우선하고 웹사이트 번들/배포에 의존하지 않는다.
- 작업 전 기존 동작을 확인하고 가장 작은 변경부터 수행한다. 테스트 결과가 확인되지 않으면 성공했다고 보고하지 않는다.

## 영역별 책임

| 영역               | 책임                                                                | 상세                                                               |
| ------------------ | ------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `apps/web/`        | React/Vite Home·Portfolio·Lab/Writing Markdown 목록·상세·Notes 호환 | [02-target-architecture.md](docs/guides/02-target-architecture.md) |
| `apps/api/`        | 기존 Worker/Hono/D1 및 동의 기반 방문 집계 API                      | [04-migration-plan.md](docs/guides/04-migration-plan.md)           |
| `content/lab/`     | 공개용 기술 글·실험 분석                                            | [03-content-and-writing.md](docs/guides/03-content-and-writing.md) |
| `content/writing/` | 공개용 일상·회고·생각                                               | [03-content-and-writing.md](docs/guides/03-content-and-writing.md) |
| `labs/`            | 실행 가능한 독립 실험 코드와 증거                                   | [05-lab-practices.md](docs/guides/05-lab-practices.md)             |
| `docs/`            | 설계 결정·작업 계획·운영 기준의 원본                                | `docs/README.md`                                                   |

## 작업 종료 조건

1. [품질 문서](docs/guides/06-quality-and-safety.md)의 변경 범위별 검사 실행: 문서·하네스만 바꾸면 링크 검사와 하네스 자체 테스트, Web/API/Go 변경은 해당 영역의 검사. 실행 불가 원인과 미검증을 기록한다.
2. 변경이 영향을 주는 경로·콘텐츠·링크·접근 제어 회귀를 확인한다. 로컬 검사를 운영·실제 장비 검증으로 보고하지 않는다.
3. 결과 보고에 **변경 파일 / 실행한 검사 / 미검증 항목 / 다음 단계** 포함
4. 문서와 코드가 불일치하면 같이 수정하거나 차이를 명시

## 앱별 구현 원칙

- Web은 React/Vite/TypeScript, HTML/CSS와 기존 컴포넌트를 우선한다. 접근성·reduced motion·이미지 크기·R2 URL·동의 동작을 보존한다.
- Portfolio 공개 데이터는 `apps/web/src/content.json`을 원본으로 유지한다. Lab/Writing은 content/의 Markdown을 빌드 시 검증한다. draft 기본값은 true이고 공개 글만 번들에 포함한다.
- router·전역 상태관리·Axios·UI/애니메이션 프레임워크·범용 추상화는 실제 요구 전 추가하지 않는다. 앱과 실험은 서로 직접 참조하지 않는다.
- 2026-10-25 사용자 승인으로 기존 D1에 방문 집계를 추가한다. 경력·글 API 의존은 추가하지 않는다. 집계·개인정보·개발·릴리스 계약은 [API README](apps/api/README.md)를 따른다.
- API는 Worker/Hono, `/api/*` JSON, Web Standard API와 단순 SQL을 유지한다. ORM·불필요한 Domain/Service/Repository 계층을 추가하지 않는다.
- Web Node 26 / API CI Node 22와 앱별 lockfile을 유지한다. PR은 배포하지 않고 main Production / develop 웹·API Preview 정책을 유지한다.
- 기존 공개 연락처·경력 데이터는 기능 보존 범위에서 그대로 둔다. 개인정보를 새 문서에 복제하거나 새 공개 범위를 추가하지 않는다.
- Entry는 루트 진입 파일과 docs 인덱스, 현행 Guides는 `docs/guides/`, 과거 작업·검증은 `docs/archive/`, 양식은 `templates/`에 둔다. Archive의 유효한 결정은 Guide에서 참조하되 과거 Pages·단일 페이지 제한·Backend 삭제 제안을 현재 지침으로 실행하지 않는다.

Claude Code는 `CLAUDE.md`를 통해 이 문서로 진입한다. 세부 규칙을 다른 진입 파일에 중복 복사하지 않는다.
