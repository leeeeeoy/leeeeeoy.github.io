# Phase 3 — Markdown 콘텐츠 시스템과 로컬 검증

- 날짜: 2026-10-14
- 상태: 완료(로컬), 실제 글·실험·원격 반영·배포 없음. 여기서 종료한다.
- 기준: migration/phase1-monorepo, Phase 2 HEAD `5fb158d`. 시작 작업 트리는 clean이었다. Phase 1/2 커밋·main/develop/origin을 보존하며 이번 변경은 로컬 작업 트리에 둔다.
- 승인 범위: Markdown 수집·검증·목록/상세·템플릿·필요한 의존성·로컬 검사. 사용자 지시의 실제 글 금지가 종전 계획의 첫 글 발행 검증을 대체했다.

## 1. 콘텐츠 구조와 확정 계약

```text
content/lab/.gitkeep                 # 실제 글 없음
content/writing/.gitkeep             # 실제 글 없음
templates/experiment.md              # 질문·가설·관측·공식 비교·한계·다음 검증
templates/lab-note.md                # 실험 없는 이론/학습도 허용
templates/writing.md                 # 기본 메타데이터와 자유 본문
apps/web/test/fixtures/markdown.md   # 공개 content와 분리한 합성 검증 자료
```

글을 작성할 때는 `content/{lab|writing}/{slug}.md`로 추가한다. 파일명 slug·디렉터리 section을 사용하며 같은 영역 내 중복은 실패하고 서로 다른 영역의 같은 slug는 허용한다. title/date/summary 필수, tags/draft/updated 선택이다. draft 기본값은 true, 명시적 false만 공개한다. 날짜는 달력 날짜까지 검증하며 updated는 date 이후 또는 같은 날이어야 한다. 평면 Markdown과 .gitkeep만 허용하고 symlink/하위 폴더는 거부한다.

[03 계약](../../guides/03-content-and-writing.md)이 상세 규칙·첫 글 작성 방법의 원본이다. 초안이 Public Git에서 공개된다는 기존 개인정보 원칙을 유지한다.

## 2. 수집·렌더링 선택

- `scripts/content.ts`: YAML 파싱, 오류의 파일/필드 표시, slug/타입/날짜/중복 검증, 모든 초안 검증 후 공개 글만 추출, date 내림차순.
- `vite.config.ts`: Node에서 저장소 root content를 읽어 `virtual:posts`에 공개 글만 직렬화한다. buildStart에도 검증하여 잘못된 입력은 빌드를 실패시킨다. dev watcher는 추가/수정/삭제 때 모듈 무효화와 reload를 수행한다.
- `src/posts.ts`와 `content-module.d.ts`: 공개 배열·section/slug 조회·타입 계약. 런타임 API·생성된 JSON 파일의 Git 추적·원본 Markdown glob·CMS를 추가하지 않았다.
- React 렌더러는 [react-markdown 10.1.0](https://github.com/remarkjs/react-markdown)과 [remark-gfm 4.0.1](https://github.com/remarkjs/remark-gfm)을 사용한다. React 요소 기반이며 표/취소선 등 필요한 Markdown을 지원한다. [yaml 2.9.1](https://eemeli.org/yaml/)과 @types/node 26은 개발/빌드 의존성이다. [Vite virtual module](https://vite.dev/guide/api-plugin#virtual-modules-convention)을 사용했다.
- skipHtml·기본 URL 안전 처리 유지, raw HTML/MDX/코드 실행 없음. 위험 URL은 링크/이미지 요소 대신 텍스트만 표시한다. 외부 링크는 noopener/noreferrer, 내부 root/상대 경로는 UI 언어 유지.
- 기존 폰트·색·폭·hero·note-article 스타일을 재사용했다. 코드/표의 독립 가로 스크롤·키보드 포커스·focus ring, 반응형 이미지·lazy/async와 alt를 지원한다. 본문 #은 h2로 표시하고 템플릿은 ##부터 사용한다.
- 문법 강조 패키지는 추가하지 않았다. 빈 content 기준 JS는 기존 261.71 KB / gzip 82.00 KB에서 약 425.03 KB / gzip 131.72 KB로 증가한다. YAML은 브라우저 번들에 넣지 않는다. 글이 매우 많아지면 현재 전체 공개 본문 포함 방식의 비용을 재검토한다.

## 3. 주소와 UI 동작

| 주소 | 동작 |
|---|---|
| /lab/, /writing/ | 각 영역의 공개 글을 최신순으로 표시. 실제 글은 0개여서 기존 빈 상태 유지 |
| /lab/:slug/, /writing/:slug/ | title/date/updated/summary/tags와 Markdown 원문·위/아래 목록 복귀 |
| 없는 글·초안 slug | 같은 없는 글 안내, 현재 영역 메뉴 표시, 해당 목록 복귀 |
| /, /portfolio/ | 기존 Home과 Portfolio 유지 |
| /notes/, /notes/:slug/ | 기존 Notes 렌더러·주소·Lab 안내 유지, 자동 이전/삭제 없음 |

기존 일반 anchor/pathname 방식을 확장했다. 새로운 라우터·상태관리·UI 도구를 추가하지 않았다. ko/en 공통 UI를 추가하고 한국어 본문도 영어 UI에서 그대로 보여준다. 브라우저 title/description은 글 metadata를 사용한다. canonical에는 언어 query를 넣지 않는다.

## 4. 변경·보존 파일

- 추가: `apps/web/scripts/content.ts`, `check-content.ts`, `src/posts.ts`, `content-module.d.ts`, `pages/RecordPage.tsx`, `test/posts.test.mjs`, `test/fixtures/markdown.md`.
- 수정: `vite.config.ts`, `tsconfig.json`, package/lock, App/routes/content.ts, UI JSON, RecordListPage, styles, 기존 localization 검사.
- 문서: root AGENTS/ARCHITECTURE/README, docs 01/02/03/04/06/README/active plan와 이 기록. Phase 1/2 기록·감사 원문은 보존했다.
- 템플릿: 본문 제목을 ##부터 시작하도록 조정하고 실험의 한계/다음 검증 분리, Writing 선택 tags 제거. 실제 콘텐츠는 추가하지 않았다.
- **동일성 대조:** ko/en의 ui 외 데이터 전체, PortfolioPage.tsx·notes.ts·main.tsx, CI 두 workflow·Wrangler·_headers는 Phase 2 HEAD와 동일하다. 기존 경력 3개·프로젝트 3개·대표 사례 4개·R2/외부 URL은 유지한다. API/labs·운영 자산은 변경하지 않았다. 기존 dependency 버전도 lock에서 유지된다.

## 5. 자동 검사

```bash
cd apps/web
npm ci
npm run content:check
npm run lint
npm run format:check
npm test
npm run typecheck
npm run build
```

모두 통과했다. 콘텐츠 검사는 공개 글 0개, test는 **15/15**이다. 기존 12개 검사를 유지하고 새 상세/없는 글 요구에 기대값을 갱신했다. 새 3개 테스트는 다음을 여러 사례로 확인한다.

- 필수 필드·타입·윤년/달력 날짜·updated·slug·BOM/CRLF·잘못된 YAML/중복 key·과도한 alias·초안 기본값.
- 날짜 정렬·영역 분리·중복(초안 포함)·하위 폴더 거부·잘못된 초안 실패.
- 격리 임시 앱의 실제 Vite dev/production build, ko/en App 렌더링, heading/문단/표/코드/이미지/링크, HTML/위험 URL 차단, 목록/상세/없는 초안, metadata·언어 보존·끝 slash 없는 상세의 상대 링크, 공개 두 영역 번들 포함과 명시/기본 초안 dist 제외, 잘못된 파일의 build 실패.

테스트는 임시 앱 복사본에만 합성 파일을 놓고 종료 때 지운다. 실제 content/production build에는 검증 자료를 넣지 않는다. Backend는 변경이 없어 재검사하지 않았다. 이전 API Node 22 미검증도 유지한다.

## 6. 실제 로컬 Chrome

실제 앱의 빈 production build와 별도 임시 앱의 합성 콘텐츠 dev/production build를 각각 localhost에서 검사했다. 운영·Preview는 대상으로 하지 않았다.

- desktop 1440px, mobile 390px·320px에서 Markdown·기본 페이지 폭 확인. 긴 코드/표는 지역 가로 스크롤되고 오른쪽 방향키로 실제 scrollLeft가 증가했다.
- 합성 글 목록→상세·목록 복귀, 직접 진입/reload·뒤로/앞으로, Lab/Writing 현재 메뉴, 초안 주소의 없는 글 안내.
- dev 파일 추가→수정→삭제가 수동 reload 없이 화면에 반영됨. 최신 작성일 글이 먼저 표시됨.
- 영어 UI의 한국어 원문·title·summary 유지, root/상대 내부 링크와 목록 복귀의 lang=en 유지.
- 라이트/다크와 reload 저장, skip-to-content 후 main focus와 다음 Tab의 본문 링크.
- 표/코드/강조/인용/목록·언어 class, 정적 SVG 이미지와 R2 WebP 로딩. raw script/event handler 0개, 위험 링크 실행 요소 0개.
- 실제 빈 앱의 8개 URL × 2언어 화면·메뉴·없는 글/Notes 확인. Portfolio 경력 3개·프로젝트 3개·상세 펼침·섹션 이동, R2 이미지 3개 로딩·원래 링크, 옛 root ?lang=en#projects의 Portfolio 연결 확인.
- 관측 console warn/error 없음. 임시 viewport와 theme 복원, 테스트 탭/서버 정리.

확인 화면: `/private/tmp/leeeeeoy-phase3-article-mobile.png`, desktop screenshot 및 `/private/tmp/leeeeeoy-phase3-browser-checks.json`. 이는 테스트 자료의 로컬 화면이며 실제 발행 증거가 아니다. 실제 기기·Safari·screen reader·OS reduced-motion 변경 검증은 하지 않았다. 기존 reduced-motion 자동 검사는 유지한다.

## 7. CI와 의존성 위험

CI YAML은 변경하지 않았다. 기존 웹 paths는 apps/web와 content/lab·writing을 이미 포함한다. Node/lockfile/working-directory도 현재 위치와 맞으며 build에서 콘텐츠 검증이 실행된다. 문서/templates/labs-only는 웹·API를 트리거하지 않고 content-only는 웹만 대상이다. event/branch/path **54 조합** 정적 검사 통과, PR 배포 없음·main Production/develop Preview 유지. 실제 GitHub runner는 미검증이다.

fresh npm ci와 npm audit가 기존 개발 도구 계열 high 4건(Wrangler/miniflare/sharp, source-map-js)을 보고했다. 설치 전 lock에 있던 동일 버전이고 이번 렌더러에 대한 권고는 아니다. `npm audit --omit=dev`는 당시 알려진 권고 0건이다. 광범위 공급망 검증으로 해석하지 않는다. 배포 도구/CI 버전을 임의로 바꾸지 않았으므로 개발 도구 보안 업데이트는 별도 검토해야 한다. 기존 fsevents install-script 경고도 정책 변경 없이 기록한다.

## 8. 잔여 한계와 중단

- SPA HTTP 상태는 없는 글 UI와 별개이며 HTTP 404/SSG·글별 초기 HTML/OG는 제공하지 않는다. sitemap은 네 기본 경로만 포함한다. 실제 글 검색 노출은 릴리스 전 검토한다.
- 표준 Markdown 이미지의 width/height 별도 문법은 추가하지 않았다. intrinsic 비율·반응형 표시를 사용하며 로딩 전 높이 확보는 실제 글에서 필요할 때 보완한다.
- 공개 글 본문 전체가 번들에 포함되는 소규모 사이트 방식이다. 초안은 제외되지만 public Git의 비공개 보호는 제공하지 않는다.
- 운영/인증 Preview·Cloudflare Access/Secrets/D1/R2·실제 GitHub CI·API Node 22·전체 Git 이력 개인정보·Go 원본의 이전 미검증은 그대로다. 구조 이전 전체를 main에 넣을 때 웹/API 동반 배포 위험도 유지한다.

다음 글은 03/README의 절차로 작성자가 공개 범위를 검토한 뒤 로컬 확인할 수 있다. Phase 4 실험 연결은 별도 지시가 있어야 한다. 이번 Phase 3 종료 후 실제 글 작성·추가 구현·push·PR·배포를 진행하지 않는다.
