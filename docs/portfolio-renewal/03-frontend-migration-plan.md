# Frontend 전환 계획

## 선택지 비교

| 선택지 | Pages 유지 | 초기 HTML에 경력 포함 | 런타임 서버 | 복잡도 | 판단 |
|---|---|---:|---:|---:|---|
| Flutter Web 유지 | 가능 | 제한적 | 없음 | 현재 수준 | 콘텐츠만 고칠 때 |
| React + Vite SPA | 가능 | 아니오 | 없음 | 낮음 | 권장 |
| Next.js static export | 가능 | 예 | 없음 | 중간 | SEO가 우선일 때 |
| Next.js + OpenNext | Workers로 이동 | 예 | Workers | 높음 | 이번 범위 제외 |

Cloudflare는 full-stack Next.js를 OpenNext 기반 Workers로 배포하도록 안내한다.
반면 Next.js `output: "export"`는 `out/`에 정적 파일을 생성하며 일반 정적 호스팅에 배포할 수 있다.
두 방식 모두 현재 요구에는 사용하지 않는다.

## 권장안

React + Vite + TypeScript로 단일 페이지를 만든다.

### 최소 의존성

- React
- Vite
- TypeScript

처음부터 추가하지 않는 것:

- router
- 전역 상태관리
- Axios
- React Query
- UI component framework
- animation library
- carousel library
- CSS-in-JS

공개 콘텐츠는 정적 import한다. 브라우저 상태는 컴포넌트의 로컬 상태로 충분하며,
단순 메뉴·테마·스크롤 동작은 HTML/CSS와 브라우저 API를 우선한다.

### HTML·CSS 우선 기준

- `header`, `nav`, `main`, `section`, `article`, `footer`로 문서 구조를 만든다.
- 반응형은 CSS Grid, Flexbox, `clamp()`, media query로 해결한다.
- hover와 focus 전환은 CSS transition만 사용한다.
- 접기/펼치기는 가능한 경우 `details`/`summary`를 사용한다.
- 스크롤 이동은 anchor와 `scroll-behavior`를 사용한다.
- JS 애니메이션과 scroll listener는 실제 필요가 확인되기 전에는 넣지 않는다.

## 화면 구조

```text
/
├─ Hero
│  ├─ 역할 요약
│  ├─ 대표 성과 지표
│  └─ GitHub / Blog / Contact
├─ Experience
│  └─ 회사별 문제 → 행동 → 결과
├─ Selected Projects
│  └─ 2~3개 대표 프로젝트
├─ Skills
│  └─ 기술명 + 사용 맥락
├─ About this portfolio
└─ Footer
```

라우트는 우선 `/` 하나만 둔다. 상세 페이지는 콘텐츠가 카드에서 읽기 어려울 정도로 커진 뒤 추가한다.

## 표현 원칙

- 경력 회사 로고보다 성과와 역할을 먼저 보이게 한다.
- 긴 bullet 전체를 기본 노출하지 않고 회사별 3~5개 핵심 성과만 보여준다.
- 수치는 `Metric` 카드로 분리한다.
- 프로젝트 스크린샷은 CSS grid로 표시한다.
- 모바일에서는 한 열, 데스크톱에서는 본문 최대 폭을 제한한다.
- `prefers-color-scheme`과 `prefers-reduced-motion`을 기본 지원한다.
- 키보드 포커스와 heading 순서를 유지한다.

## 데이터 로딩

빌드 시 정적 데이터를 import하므로 로딩 spinner와 API 오류 UI가 필요 없다.

R2 이미지는 다음처럼 계속 사용한다.

```text
https://assets.leeeeeoy.xyz/{relative-path}
```

일반 `<img>`에 실제 `width`, `height`, `loading="lazy"`, `decoding="async"`를 지정한다.
대표 이미지만 즉시 로드하고 나머지는 지연 로드한다.

## SEO와 메타데이터

- title과 description을 실제 포트폴리오 설명으로 교체
- canonical URL을 `https://portfolio.leeeeeoy.xyz`로 통일
- Open Graph URL도 현재 도메인으로 수정
- 대표 이미지의 R2 또는 저장소 내 정적 위치 확정
- `sitemap.xml`, `robots.txt`, JSON-LD Person/ProfilePage 검토

JSON-LD에는 공개하기로 승인된 정보만 포함한다.
핵심 본문이 초기 HTML에 필요한 수준의 검색 요구가 확인되면 prerender를 별도 단계로 검토한다.

## Analytics

현재 Firebase 패키지를 그대로 옮기지 않는다.

- 실제로 보는 지표가 있으면 Firebase Analytics만 최소 연동
- 사용하지 않는 Messaging, Crashlytics, Performance는 웹 전환 대상에서 제외
- Cloudflare Web Analytics로 충분한지 먼저 확인

## 배포

현재 Pages 프로젝트와 custom domain을 유지한다.

```text
npm ci
npm test
npm run build
wrangler pages deploy dist --project-name=leeeeeoy-portfolio-frontend
```

구현 시 Vite 출력 디렉터리와 CI 명령을 한 번 검증한다.

## 참고

- Cloudflare Next.js Workers:
  https://developers.cloudflare.com/workers/framework-guides/web-apps/nextjs/
- Next.js static export:
  https://nextjs.org/docs/app/guides/static-exports
- Vite static deployment:
  https://vite.dev/guide/static-deploy.html
