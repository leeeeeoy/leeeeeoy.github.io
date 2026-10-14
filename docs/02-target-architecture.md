# Target Architecture & Boundaries

상태: 디렉터리와 기본 라우트는 Phase 2 로컬 구현 완료 / Markdown·글 상세 계약은 제안. 기존 GitHub repo·이력을 유지하고 로컬 루트를 `leeeeeoy/`로 전환한다. 새 repo 생성·rename은 하지 않는다.

## 디렉터리 계약

```text
apps/web/                       # 기존 frontend/ 이전, React/Vite 정적 앱
apps/legacy-api/                # 기존 backend/ 보존, 웹 신규 의존 X
content/lab/*.md                # Lab 공개 기술 글
content/writing/*.md            # Writing 공개 글
labs/<experiment-name>/         # 언어·툴 무관 독립 실행 실험
docs/                           # 결정과 규칙의 원본
templates/                      # Markdown 작성 가이드
.github/workflows/              # 경로별 검사/배포
```

**권장:** 실험 코드마다 필요한 의존성만 자체 관리(`go.mod`, `requirements.txt` 등). root 통합 package manager, Go workspace, Nx/Turbo, Docker Compose는 필요가 증명되기 전 추가하지 않는다.

## 웹의 콘텐츠 원본

- Portfolio: `apps/web/src/content.json`을 우선 유지한다. 마이그레이션과 경력 데이터 개편을 하나의 단계로 섞지 않는다.
- Lab/Writing: **`content/`의 Markdown + frontmatter**를 Phase 3의 정적 콘텐츠 원본으로 제안한다. 현재는 디렉터리만 있고 빌드에 연결되지 않았다. 이후 빌드 시 읽어서 목록/상세에 반영한다.
- Lab과 Writing은 동일한 **렌더링 기반**(제목·문단·이미지·링크·코드 블록·표)을 공유할 수 있지만 **내용/템플릿 규칙**은 다르다.
- 저장소 루트 외부 파일·개인 로컬 디렉터리는 빌드 입력으로 만들지 않는다.
- 초기에는 한국어 글만 작성 가능하게 하고, 현재 `?lang=en` UI 전환과 무관하게 글의 언어를 명시한다. 영문 본문을 자동 생성하지 않는다.

## 최소 Frontmatter 계약(제안)

```yaml
---
title: "Go 동시성과 처리량"
date: "2026-10-14"
summary: "동시 요청에 따른 응답 시간과 처리량 관찰"
tags: [go, performance]
draft: false
---
```

- `slug`는 파일명(예: `go-concurrency.md`)으로 결정하거나 frontmatter로 지정하되 한 방식을 승인하고 유지한다. 추천: 파일명 기반.
- `date`는 ISO 날짜; `summary`는 목록에 표시; `tags`는 선택; `draft` 기본값은 `true`로 두는 게 게시 사고 예방에 유리하다.
- `draft: true`는 **사이트에서 숨김**일 뿐 GitHub 공개를 막지 못한다. 비공개 글은 이 저장소 밖에서 작성한다.
- 제목·요약·마크다운 내용은 렌더링 시 안전하게 처리한다. 임의 HTML 실행/MDX 평가를 기본 허용하지 않는다.
- 링크와 R2 이미지는 기존 도메인과 크기 지정 원칙을 유지한다.

## 라우팅 원칙

- `/` Home: 소개·세 영역 링크만 제공. 글이 없어 최근 글·가상 글을 표시하지 않는다. Portfolio 전체는 `/portfolio/`에서 제공한다.
- `/portfolio/` Portfolio 상세. 실제 페이지 개편 전 기존 `/` 콘텐츠의 누락 방지 테스트 작성.
- `/lab/`/`/lab/:slug/`: Lab 글 목록/상세, 관련 코드 저장소 링크.
- `/writing/`/`/writing/:slug/`: Writing 글 목록/상세.
- `/notes/`, `/notes/:slug/`: 원래 화면·주소를 유지하고 Lab 안내 링크를 추가했다. 일괄 redirect나 삭제를 하지 않는다.
- `routes.ts`에서 기본 경로와 Notes 상세를 명시적으로 구분한다. 일반 anchor를 유지하고 router 라이브러리는 추가하지 않았다. 옛 root section hash·저장된 이동은 Portfolio로 이어받는다.
- 실제 글 상세는 Phase 3까지 미구현. 없는 경로 안내는 UI이며 HTTP 404 보장은 아니다. [Phase 2 기록](11-phase2-pages-record-2026-10-14.md)을 따른다.

## 운영 경계

```text
Markdown / 정적 데이터 ──(web build)──> Workers Static Assets ──> 방문자
      Lab 결과 ──(링크)───────────────┘
Go/Python 실험 ──(별도 실행)──> 로컬 결과 저장/분석
Legacy Worker/D1/R2 ──(기존 용도 유지, 리소스 변경 없음)
```

- 실험은 기본적으로 로컬에서 수행한다. 특정 주제 때문에 배포가 필요하면 **그 실험의 문서와 별도 승인**을 거친다.
- DB, 인증, 개인 데이터 처리 없이 정적 웹으로 운영한다.
- 웹 CI는 `apps/web/**`, `content/**`, 관련 config·workflow를 커버한다. Lab 변경만으로 웹을 배포하지 않는다.

## 의사결정이 필요한 경우

1. 파일명 slug vs frontmatter slug: 하나로 결정 후 자동 검증.
2. Git 전략은 기존 repo·origin·이력 유지로 확정. 로컬 이전은 [Phase 1 기록](10-phase1-migration-record-2026-10-14.md)을 따른다.
3. Markdown 처리 의존성: 기술 선택 전에 실제 코드블록·표·이미지 사용을 검증하고 최소 패키지를 선택.
4. 새 개별 글의 검색 노출은 글별 메타데이터/sitemap/프리렌더가 필요할 수 있음. **SEO를 위해 전체 프레임워크 교체 금지**.

## 후속 구현의 확인 항목

Markdown 도구와 slug namespace/draft 기본값은 Phase 3 전에 확정한다. 초안은 화면뿐 아니라 dist 출력에서도 제외해야 한다. 현재 SPA fallback의 없는 글 안내가 HTTP 404를 보장하지 않으며, build-time 콘텐츠 공급도 글별 초기 HTML/OG 생성을 보장하지 않는다.
