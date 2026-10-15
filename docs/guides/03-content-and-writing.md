# Content & Publishing Guide

상태: Phase 3 콘텐츠 시스템 구현 후 Phase 4의 Go 실험 초안 1개를로컬에서 draft:true로 보존한다. 결과와 해당 초안은 사용자 결정으로 커밋을 보류하며 ignore한다. 공개 글은 0개이며 운영에는 배포하지 않았다. [검사 기록](../archive/work-records/12-phase3-content-record-2026-10-14.md)을 따른다.

## 파일과 메타데이터 계약

`content/lab/{slug}.md`, `content/writing/{slug}.md`에 평면 파일로 작성한다. slug는 소문자 영문·숫자를 하이픈으로 연결한다(`go-concurrency`). section과 slug 필드는 저장하지 않는다. 같은 영역의 slug 중복은 실패하며 Lab과 Writing에서 같은 slug는 허용한다. 하위 폴더·심볼릭 링크·Markdown 이외 파일은 거부하고 `.gitkeep`만 무시한다. 디렉터리 안에 README를 넣지 않는다.

```yaml
---
title: "글 제목"
date: "2026-10-14"
summary: "짧은 소개"
tags: [go, learning]
draft: true
updated: "2026-10-15"
---
```

| 필드 | 규칙 |
|---|---|
| title / summary | 필수, 비어 있지 않은 문자열 |
| date | 필수, 실제 존재하는 YYYY-MM-DD 날짜(0001–9999년) |
| tags | 선택, 비어 있지 않은 문자열 배열. 생략 시 빈 배열 |
| draft | 선택, boolean. 생략 시 **true**; 명시적 false만 공개 |
| updated | 선택, YYYY-MM-DD 날짜, date보다 이전일 수 없음 |

알 수 없는 필드·잘못된 YAML·중복 YAML key·필수 필드 누락·타입·달력 날짜·slug 오류는 파일 경로와 이유를 포함한 오류로 검사/빌드를 중단한다. 초안도 같은 검증을 받는다. 본문의 `---`는 frontmatter를 닫은 뒤 일반 Markdown 구분선으로 처리한다. UTF-8 BOM·CRLF도 지원한다.

초안 기본값 true는 종전 02의 권장안을 확정한 선택이다. 실수로 draft 필드를 빼도 발행되지 않는다. `draft: true`는 사이트 목록·상세·번들에서 제외되지만 **Public Git 파일/이력을 비공개로 만들지 않는다.** 비공개 내용은 이 저장소 밖에서 작성한다.

## 수집·개발·빌드

- `apps/web/scripts/content.ts`가 YAML을 읽어 검증하고 date 내림차순(동일 날짜는 slug 순)으로 정렬한다.
- `vite.config.ts`가 `virtual:posts`에 공개 글만 직렬화한다. root content를 Node에서 읽으므로 Vite root 밖 Markdown도 dev/build에서 동작하며 runtime API나 원본 파일 glob을 브라우저에 전달하지 않는다.
- `src/posts.ts`는 공개 배열과 section/slug 조회를 제공하고 목록·상세·브라우저 metadata에서 공유한다. Lab과 Writing 목록을 섞지 않는다.
- `npm run dev`는 Markdown 추가/수정/삭제 때 모듈을 무효화하고 페이지를 새로 불러온다. `npm run preview`는 dist를 제공하므로 변경 후 rebuild해야 한다.
- `npm run content:check`로 검증만 실행할 수 있다. `npm run build`도 같은 수집기를 실행하므로 CI에 별도 명령을 추가할 필요는 없다.
- 목록·UI는 ko/en, 본문은 원문 그대로다. 영어 UI에서 한국어 글도 표시한다. 자동 번역·별도 번역 파일 계약은 없다.

## 표시와 안전한 Markdown

react-markdown + remark-gfm으로 제목·문단·굵게·기울임·취소선·목록·인용·링크·inline code·fenced code·표·구분선·이미지를 표시한다. 문법 강조 도구를 추가하지 않았으며 fenced language class는 유지한다.

- 페이지 title이 h1이므로 본문은 `##`부터 작성하는 것을 권장한다. 본문의 `#`는 h2로 표시해 페이지 h1을 중복 생성하지 않는다.
- raw HTML은 skipHtml로 무시한다. MDX·HTML 실행·rehype-raw·dangerouslySetInnerHTML은 사용하지 않는다. 기본 URL 안전 처리를 유지하며 차단된 링크/이미지는 텍스트만 표시한다.
- 외부 HTTP(S)/protocol-relative 링크는 새 탭과 `noopener noreferrer`. 내부 root/상대 링크는 UI 언어 쿼리를 유지하고 anchor는 현재 주소의 query를 유지한다.
- 긴 코드와 표는 독립 가로 스크롤 영역이며 키보드 포커스·이름·focus ring을 갖는다. 페이지 자체는 좁은 화면 밖으로 넘치지 않는다.
- 표준 Markdown 이미지와 alt를 사용한다: `![설명](/images/name.webp)` 또는 `![설명](https://assets.leeeeeoy.xyz/...)`. 정적 파일은 `apps/web/public/images/` 등 public 하위에 둔다. 렌더러는 lazy/async·최대 본문 폭·높이 auto를 적용한다. 표준 Markdown에는 width/height 필드가 없으므로 별도 크기 문법/이미지 파이프라인은 이번에 도입하지 않았다. 로딩 전 높이 확보는 향후 실제 글에서 필요할 때 보완한다.
- 실험 코드와 결과는 일반 GitHub 파일/커밋 링크를 제공한다. 웹 빌드가 실험 코드를 실행하지 않는다.

`/lab/:slug/`, `/writing/:slug/` 직접 진입과 새로고침을 지원한다. 없는 글·초안은 같은 없는 글 안내와 영역 목록 복귀를 제공한다. Notes는 기존 렌더러/주소를 보존한다. SPA의 HTTP 404와 글별 초기 HTML/OG 생성은 구현하지 않았다. sitemap은 현재 네 기본 페이지만 포함한다.

## Lab — 탐구·이론·실험

- 실험 글: 질문 → 가설 → 환경·절차 → 실측 결과 → 공식 설명과 비교/해석 → 한계 → 다음 검증.
- 이론/학습 노트: 궁금했던 개념, 공식·1차 문서와 예제, 아직 이해하지 못한 점. 실험 코드가 없어도 작성할 수 있다.
- 예상과 실측을 구분하며 생성한 예시 수치를 실측으로 쓰지 않는다. 정확도가 중요한 주장은 자료/결과/커밋으로 연결한다.
- 실험 재현 설명은 `labs/<name>/README.md`에 둔다. 블로그와 실험의 1:1 대응은 강제하지 않는다. 첫 Go 실험은 labs/go-load-test에 독립 실행 코드와 원본 결과를 보존했다.

## Writing — 생활·회고·생각

일상·경험·감정·취향 등 주제/목차/분량을 강제하지 않는다. 기본 메타데이터와 자유 본문이면 충분하다. 기술적 주장의 근거, 사생활·타인·직장 정보의 공개 범위만 작성자가 검토한다. categories·필터 UI·가상 글은 없다.

## 첫 글의 로컬 확인 순서

1. [실험](../../templates/experiment.md), [학습 노트](../../templates/lab-note.md), [Writing](../../templates/writing.md) 중 필요한 템플릿을 해당 content 영역으로 복사하고 slug를 정한다.
2. 제목·요약·실제 날짜·본문을 작성하고 개인정보/비공개 업무 자료/Secrets·근거를 검토한다. 템플릿의 `YYYY-MM-DD`는 반드시 바꾼다.
3. `draft: true`로 두고 `apps/web`에서 아래 검사를 실행한다. 초안은 개발 서버에서도 제외되므로 화면 확인은 공개 필터를 바꾸지 않는 격리 복사본을 사용한다([Phase 4 검증 방식](../archive/work-records/13-phase4-go-lab-record-2026-10-15.md)). `draft: false` 전환은 사용자 공개 승인 후에만 한다. 비공개 초안은 public repo에 두지 않는다.
4. 목록→상세, 직접 URL/reload, 한·영 UI, 모바일 코드/표, 이미지 alt와 외부 링크를 확인한다. 아직 배포하지 않는다.
5. 원격 반영·PR·운영/Preview 발행은 별도 사용자 승인 후 진행한다. 실제 URL·검색 노출은 릴리스 단계에서 확인한다.

```bash
cd apps/web
npm run content:check
npm run lint
npm run format:check
npm test
npm run typecheck
npm run build
npm run dev
# 또는 build 후 npm run preview
```

Phase 3에는 실제 글을 만들지 않았다. Phase 4의 첫 Lab 글은 draft:true이며 공개되지 않는다. `apps/web/test/fixtures/markdown.md`와 격리된 임시 복사본으로 검증했고 해당 자료를 공개 content나 production dist에 넣지 않는다. 문장/경험/주장은 작성자의 원문을 존중한다.

Lab 연구 계획·근거 분류·초안 작성 승인 절차는 [Lab Workflow](14-engineering-lab-workflow.md)를 따른다. 이 문서는 파일 스키마·렌더링·공개 계약만 관리한다.
