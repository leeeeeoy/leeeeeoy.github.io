# leeeeeoy — Personal Space

개인의 경험·생각·기술적 호기심을 기록하는 웹사이트와 독립 실험을 관리합니다.
Phase 3에서 Markdown 기반 Lab·Writing 목록/상세와 빌드 검증을 구현했습니다. Go HTTP 실험의 첫 Lab 초안은 draft:true이며 공개 글은 0개라 빈 목록을 표시합니다. 이번 변경은 미배포 상태이며 운영 사이트를 이번 단계에서 검증하지 않았습니다.

**URL:** https://leeeeeoy.xyz

## 구조

```text
leeeeeoy/
├── apps/web/          # 기존 React + Vite 정적 SPA
├── apps/api/   # Hono 방문 집계 API · 기존 D1/R2 보존
├── content/lab/       # 공개 기술 글, Markdown 빌드 입력
├── content/writing/   # 공개 개인 글, Markdown 빌드 입력
├── labs/              # 독립 Go HTTP·DB 정합성·분산 결제 보상 실험
├── docs/              # Entry 인덱스·guides 현행 기준·archive 기록
├── templates/         # 글/실험 템플릿
└── .github/workflows/ # 영역별 CI/CD
```

## Frontend

| 항목           | 내용                                                |
| -------------- | --------------------------------------------------- |
| UI             | React 19 + TypeScript                               |
| Build          | Vite 7                                              |
| 개발 환경      | Node.js 26.x (`apps/web/.nvmrc`)                    |
| 코드 검사·포맷 | ESLint + TypeScript/React Hooks 권장 규칙, Prettier |
| 콘텐츠         | Portfolio/UI JSON + `content/` Markdown             |
| 스타일         | HTML/CSS 중심, 외부 UI·애니메이션 라이브러리 없음   |
| 이미지         | Cloudflare R2                                       |
| 배포           | Cloudflare Workers Static Assets                    |

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
Portfolio와 UI 문구는 `src/content.json`의 `ko`·`en`에서 관리합니다. Lab·Writing 본문은 Markdown 원문을 표시하며 영어 UI에서도 번역하거나 숨기지 않습니다.
JavaScript 실행 전의 검색·공유 미리보기 HTML은 공통 한국어 사이트 셸을 사용합니다. 브라우저가 실행되면 경로와 언어에 맞는 제목·설명·canonical을 적용합니다. 글별 초기 HTML 생성은 구현하지 않았습니다.

## 현재 페이지와 호환 경로

- `/`: 자기소개와 Portfolio/Lab/Writing 링크
- `/portfolio/`: 경력·프로젝트·문제 해결 사례 전체, 기존 섹션 이동
- `/lab/`, `/writing/`: 서로 다른 목적의 공개 글 목록·빈 상태, 가상 글 없음
- `/lab/:slug/`, `/writing/:slug/`: Markdown 상세와 없는 글 안내
- `/notes/`, `/notes/:slug/`: 기존 주소와 화면 유지, Lab 안내 추가
- 옛 루트의 `#experience`, `#projects`, `#skills`: 쿼리·해시를 유지해 브라우저에서 Portfolio로 이동
- 알 수 없는 경로: 페이지 없음 UI. HTTP 상태는 SPA fallback과 별개입니다.

[Phase 2 기록](docs/archive/work-records/11-phase2-pages-record-2026-10-14.md)에 검사 결과와 한계를 정리했습니다.

## 첫 글 작성과 로컬 확인

1. `templates/experiment.md`, `lab-note.md`, `writing.md` 중 필요한 템플릿을 `content/lab/{slug}.md` 또는 `content/writing/{slug}.md`로 복사합니다. 파일명은 소문자 영문·숫자·하이픈이고 하위 폴더는 사용하지 않습니다.
2. `title`, `date`, `summary`를 채웁니다. `YYYY-MM-DD` 자리에는 실제 날짜를 넣어야 초안도 검증에 통과합니다. `tags`·`updated`는 선택입니다.
3. `draft: true`를 유지합니다. 초안은 개발 서버에서도 제외되므로 화면 검토는 [콘텐츠 계약](docs/guides/03-content-and-writing.md)의 격리 미리보기 방식을 따릅니다. `draft: false` 전환은 사용자 공개 승인 후에만 합니다. **Public Git의 초안은 사이트와 무관하게 공개되므로 비공개 내용은 저장소 밖에서 작성합니다.**
4. `apps/web`에서 `npm run content:check`, `npm test`, `npm run build`를 실행하고 `npm run dev` 또는 `npm run preview`로 목록·상세·모바일·언어·링크를 확인합니다. dev는 content 파일 추가/수정/삭제를 자동 반영하고 preview는 rebuild가 필요합니다.
5. 실제 발행·원격 반영·배포는 별도 승인 범위입니다. Phase 4에서는 첫 글을 draft:true로 작성했으며 공개하지 않습니다.

[콘텐츠 계약](docs/guides/03-content-and-writing.md)과 [Phase 3 검사 기록](docs/archive/work-records/12-phase3-content-record-2026-10-14.md)을 참고합니다. raw HTML/MDX·자동 번역·코드 실행·문법 강조는 제공하지 않습니다.

## 첫 Lab 실험

[Go HTTP Load Lab](labs/go-load-test/README.md)은 웹과 독립 실행합니다. 42개 본 측정과 별도 보조 검증, 첫 Lab 글 `content/lab/go-http-concurrency.md`(draft:true)은 로컬에 보존합니다. **사용자 결정으로 결과 디렉터리와 이 초안은 ignore하며 커밋을 보류합니다.** 원격 저장소에 자료가 모두 있다고 가정하지 마세요. [Phase 4 기록](docs/archive/work-records/13-phase4-go-lab-record-2026-10-15.md)은 당시 검증 기록이며 [공개 준비 점검](docs/archive/work-records/16-precommit-review-2026-10-15.md)에 보류 이유를 정리합니다.

추가 독립 실험은 [구간 정합성 P0](labs/concurrency-integrity/README.md)와 [Booking Compensation Lab](labs/booking-compensation/README.md)입니다. 후자는 각각 독립 실행하는 Go 예약/일정 API와 두 DB, 가상 PG·Slack으로 결제 후 예약 실패·보상과 pool·알림 대기를 관찰하는 기준 구현입니다. 자동 복구·공개 글 구현 완료를 뜻하지 않습니다.

모든 `labs/**/results/`는 로컬 실행 자료로 보존하고 Git 추적에서 제외합니다. 코드·실행 절차·Research Record의 요약은 유지합니다. 새 clone에는 과거 측정 원본이 없으며, 재실행 결과는 환경과 동시성에 따라 달라질 수 있습니다.

## API

기존 Cloudflare Workers + Hono API와 D1/R2 바인딩을 보존합니다. Backend CI의 Node.js는 22이며 Frontend Node 26과 독립적으로 검사합니다.
경력·글 콘텐츠는 빌드에 포함합니다. 방문 합계만 기존 Worker/D1의 `/api/visits`를 조회하고, 새 분석 동의가 있을 때 등록합니다. [방문 집계 개발·개인정보·릴리스 계약](apps/api/README.md)을 참고하세요.

| 항목      | 내용               |
| --------- | ------------------ |
| Runtime   | Cloudflare Workers |
| Framework | Hono               |
| Database  | Cloudflare D1      |
| Storage   | Cloudflare R2      |
| Deploy    | Wrangler           |

```bash
cd apps/api
npm ci
npm run typecheck
npm test
```

## CI/CD

GitHub Actions는 변경된 영역만 검사하고 배포합니다.

- `apps/web/**`, `content/lab/**`, `content/writing/**`: 웹 검사와 배포 대상. 콘텐츠 검증은 Vite build에서 수행합니다.
- `apps/api/**`: test, typecheck 후 Workers 배포
- `main`: Production
- `develop`: Web·API Preview (방문 합계는 격리 D1 읽기 전용)

필요한 GitHub Secrets:

- `CLOUDFLARE_FRONTEND_API_TOKEN` (Web·API 공용: Workers Scripts Write, 해당 Zone의 Workers Routes Write·Zone Read; 기존 Secret 이름 유지)
- `CLOUDFLARE_ACCOUNT_ID`

## Cloudflare

```text
사용자 ──▶ Workers Static Assets (React SPA) ──▶ R2 (공개 이미지)
                    │
                    └─ 이전 API Worker·D1 설정 (Frontend는 호출하지 않음)
```

현재 지침은 [AGENTS](AGENTS.md), 경계는 [ARCHITECTURE](ARCHITECTURE.md), 상세 문서는 [docs 인덱스](docs/README.md)를 참고합니다.
이전 판단은 [역사 문서](docs/archive/portfolio-renewal/README.md), 실행 근거는 [Phase 1 기록](docs/archive/work-records/10-phase1-migration-record-2026-10-14.md)에 보존합니다.

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
문서·템플릿·Lab-only 변경은 앱 workflow를 실행하지 않습니다. PR은 검사만, main push는 Production, develop push는 웹·API Preview라는 기존 정책을 유지합니다.
구조 이전 커밋에는 웹과 API 경로 및 두 workflow 변경이 모두 있으므로 향후 main에 반영하면 두 배포가 대상이 됩니다. API 동반 배포 승인 또는 별도 제한 방침 없이 main에 반영하지 않습니다.
비공개 원본·로컬 설정은 공개 트리 밖에 백업하며 `resume/`, `.claude/`, `.wrangler/`, 비밀파일은 새 추적 목록에서 제외합니다.
