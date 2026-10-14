# Phase 2 — 개인 웹사이트 기본 페이지와 내비게이션

- 날짜: 2026-10-14
- 상태: 완료(로컬) / Phase 3 승인 대기
- 기준: `migration/phase1-monorepo`, Phase 1 HEAD `8d9db50`; 시작 시 작업 트리 clean.
- 범위: Home/Portfolio/Lab/Writing, 공통 레이아웃·내비게이션·호환 경로·양언어 UI·검사.
- 금지 범위: push·PR·Production/Preview 배포·Cloudflare 변경, Markdown·실제 글·Lab 실험·API/DB·로그인/CMS.

## 1. 실제 페이지와 URL 정책

| 주소 | 현재 동작 |
|---|---|
| `/` | 이름·소개·공간 설명과 세 영역 링크. 경력·프로젝트 카드를 복제하지 않음 |
| `/portfolio/` | 기존 PortfolioPage를 그대로 렌더. 경력·프로젝트·대표 사례·상세/링크/이미지 유지 |
| `/lab/` | 기술적 질문·학습·실험 공간 소개와 공개 기록 없음 상태 |
| `/writing/` | 일상·생각·회고 공간 소개와 공개 기록 없음 상태 |
| `/notes/` | 기존 빈 목록·Engineering/Decision 분류 유지, 새 기술 기록은 Lab에 둔다는 안내 |
| `/notes/:slug/` | 기존 상세/없는 글 안내 유지. 없는 글에는 Notes·Lab 링크 제공 |
| 알 수 없는 경로 | 페이지 없음 UI와 Home 링크. 존재하는 글로 위장하거나 Portfolio로 fallback하지 않음 |

기본 페이지는 끝 slash 없이도 지원한다. `/lab/:slug/`, `/writing/:slug/`는 이번에 구현하지 않았으며 현재는 페이지 없음 UI다. 별도 About은 없다.

Notes를 일괄 redirect하지 않은 이유: 실제 글은 0개지만 원래 목록/상세 계약과 URL을 보존하면서 새 목적지를 설명할 수 있다. Notes 화면에서는 Lab 메뉴를 해당 영역으로 표시한다. 기존 `notes.ts`와 상세 렌더 분기는 삭제하지 않았다.

옛 `/#experience`, `/#projects`, `/#skills`는 브라우저에서 `/portfolio/`로 `location.replace`한다. 쿼리와 해시를 그대로 유지한다. 예전 `portfolio-scroll-target` 저장값도 알려진 섹션일 때 이어받으며 저장소 접근이 막혀도 hash 연결은 동작한다. 새 Portfolio 섹션 메뉴는 기존처럼 URL에 hash를 추가하지 않고 스크롤한다. 고정 Header가 제목을 가리지 않도록 scroll margin을 적용했다.

## 2. 구현과 디자인 선택

- pathname을 검증하는 작은 `routes.ts`를 App/Header/metadata에서 공유한다. 이동은 기존 일반 anchor를 유지한다. React Router·전역 상태·새 의존성을 추가하지 않았다.
- Home은 기존 hero·색상·폰트·폭·hairline을 재사용하고 세 공간을 단순한 글줄 형태로 연결한다. 새 성과 수치·경험·가치관·가상 게시글을 만들지 않았다.
- Lab/Writing은 RecordListPage에서 기본 레이아웃만 공유한다. 본문·목적·빈 상태 설명은 다르고 공통 콘텐츠 분류를 강제하지 않는다. 데이터 로더나 미래 목록 API를 미리 만들지 않았다.
- Header에 네 기본 메뉴, `aria-current`와 밑줄을 제공한다. Portfolio에만 기존 세 섹션 메뉴를 둔다. 모바일에서도 메뉴를 숨기지 않고 행으로 배치한다.
- 키보드 focus/skip-to-main·44px 높이의 메뉴·아이콘 접근 이름·기존 reduced-motion 규칙을 유지/보완했다. 모바일의 아이콘-only GitHub 링크도 이름을 갖는다.
- Footer의 연락처·외부 링크·테마/동의·Cloudflare dialog는 유지한다. Portfolio는 기존 문구를 사용하고 나머지 페이지는 개인 기록 공간 문구를 사용한다.
- 기존 CSS의 영어 페이지에 한국어로 나타나던 상세 펼침/접힘 장식은 영어일 때 Expand/Collapse로 표시한다. Portfolio 본문·상세 구조를 다시 디자인하지 않았다.
- UI 문구만 기존 `content.json`의 ko/en에 추가했다. 실제 글의 자동 번역은 구현하지 않았다.

## 3. 주요 변경 파일

| 영역 | 파일 |
|---|---|
| 라우팅·호환 | `apps/web/src/routes.ts`, `App.tsx`, `main.tsx` |
| 새 기본 화면 | `src/pages/HomePage.tsx`, `RecordListPage.tsx`, `NotFoundPage.tsx` |
| 공통 레이아웃·Notes | `src/components/SiteChrome.tsx`, `src/pages/NotesPage.tsx`, `src/styles.css` |
| UI·최소 metadata | `src/content.json`, `src/content.ts`, `index.html`, `public/sitemap.xml` |
| 검사 | 기존 `test/content.test.mjs`, `test/localization.test.mjs`, `scripts/check-deployment.mjs` |
| 문서 | root AGENTS/ARCHITECTURE/README, docs 01/02/04/09/README/active plan와 이 기록 |

## 4. Portfolio·운영 자산 보존 근거

기준 커밋과 ko/en JSON의 **ui 이외 모든 필드**를 deep-compare했다. profile·experiences·featuredImpacts·projects·skillGroups가 동일하다. 경력 3개, 프로젝트 3개, 대표 사례 4개가 유지된다.

`PortfolioPage.tsx`와 `notes.ts`는 SHA-256이 기준과 같다. 양언어 SSR 검사에서 기존 standalone Portfolio 전체 markup이 App의 `/portfolio/`에 포함되는지도 검사했다. 의존성 package/lock, Wrangler, `_headers`, 등록 해제 service worker, API·CI·content/labs 파일은 변경하지 않았다.

현재 migration branch에서 Phase 2 후속 로컬 커밋으로 기록한다. 기존 `main`/`develop`/origin·Phase 1 커밋을 보존한다. 기존 미커밋 파일은 없었고 이번 변경만 추가했다. 기존 이력을 rewrite·reset하거나 운영 branch에 병합하지 않는다.

## 5. 자동 검사

```bash
cd apps/web
npm run lint
npm run format:check
npm test
npm run typecheck
npm run build
```

모두 통과했다. `npm test`는 **12/12**다. 기존 11개 테스트를 삭제/비활성화하지 않고 페이지 구조에 맞게 기대값을 갱신했다. 양언어 전체 App 렌더링 18개 경로 사례와 단일 h1·기본 메뉴/현재 페이지·본문 focus 대상·빈 목록·Notes·Portfolio 전체 보존·metadata를 검사한다. 경로 helper는 기본 경로·없는 경로·legacy query/hash/저장된 이동을 별도로 검사한다.

기존 consent·theme·reduced-motion·R2/개인정보·service worker 검사도 유지한다. 영어 UI 검사에서 언어 선택 링크의 의도적인 한국어 접근 이름만 허용한다. Header icon의 접근 이름도 검사한다.

이번에는 새 의존성/lockfile 변경이 없어 추가 설치하지 않았다. 이전 단계의 fresh 설치 환경에서 검사했다. Backend는 내용 변경이 없어 이번 단계에서 테스트를 반복하지 않았다. Phase 1의 API Node 22 미검증을 완료로 바꾸지 않는다.

## 6. 실제 로컬 Chrome 검사

Vite production build를 `127.0.0.1:4173`에서 제공했다. 운영/Preview 도메인을 대상으로 새 버전 검증을 실행하지 않았다.

| 검사 | 확인 결과 |
|---|---|
| 1440×900 desktop | 네 기본 화면·해당 메뉴·단일 페이지 역할, Home/목록에 경력 중복 없음 |
| 390×844 / 320×844 viewport | 네 화면의 메뉴 노출·44px 높이·가로 넘침 없음, Portfolio 보조 메뉴 노출 |
| 언어·내비게이션 | Lab/Writing의 영문 소개·빈 상태, 내부 링크 `?lang=en` 유지 |
| 직접 접근·reload·history | 기본 화면/Notes/없는 경로와 slash 없는 Portfolio 직접 진입, reload, 뒤로·앞으로 정상 |
| Notes·옛 section URL | 안내와 양언어 링크, 없는 글 유지; old root query/hash가 Portfolio로 보존됨 |
| Portfolio | 3경력·3프로젝트, 경력 상세 펼침·영문 Collapse 표시, R2 이미지 3개 로딩 |
| 키보드·focus | Tab으로 skip button과 focus ring, Enter로 content focus, 다음 Tab으로 본문 링크 |
| 테마·동의 | light/dark 전환·reload 저장, analytics 설정 열기/거부 후 닫힘, 로컬 Clarity script 0개 |
| 브라우저 로그 | 관측한 warning/error 없음. viewport·테마를 테스트 전 상태로 복원하고 탭·서버 정리 |

실제 모바일 기기·Safari·screen reader 검증은 아니다. Reduced motion은 기존 CSS/코드 검사를 유지했으나 실제 시스템 환경을 전환해 검사하지 않았다.

## 7. metadata와 운영 한계

Home 셸의 기본 제목·설명을 개인 사이트로 바꾸고 ProfilePage JSON-LD의 URL을 `/portfolio/`로 정리했다. Sitemap은 네 기본 페이지를 포함한다. 브라우저에서는 경로·언어에 맞춰 title/description/canonical/OG를 적용한다.

**SSG/SSR·HTTP 404·글별 초기 HTML/공유 미리보기 생성은 구현하지 않았다.** 정적 HTML 셸은 한 파일이다. 배포 checker의 확인 주소는 네 페이지와 Notes로 넓혔지만 Cloudflare 헤더/보호/별칭 검사는 이번에 실행하지 않았다.

Phase 1의 실제 GitHub runner, Backend Node 22, 인증 Preview/Access 우회 경로, Cloudflare 관리 리소스·Secrets·배포 ID·D1/R2 데이터·전체 Git 역사 개인정보·Go 원본 미검증은 그대로 남는다. 기존 구조 이전 전체를 main에 반영하면 웹/API 동반 배포 위험도 그대로다.

## 8. Phase 3 준비와 중단 지점

`content/lab/`, `content/writing/`는 그대로 빈 디렉터리다. 목록 화면과 UI 언어/공통 레이아웃은 준비되었지만 frontmatter/slug/draft 계약, Markdown 도구·build-time 입력·draft dist 제외·실제 글 상세는 다음 승인에서 정한다. 한국어 단독 글을 영어 UI에서 표시하는 정책도 실제 콘텐츠와 함께 검증한다.

Phase 2 종료 후 추가 구현·글 작성·배포를 진행하지 않는다. 복구는 이번 Phase 2 후속 커밋을 되돌리는 변경으로 준비할 수 있으며 Phase 1 구조와 운영 branch를 유지한다. 원격 반영은 별도 승인이다.
