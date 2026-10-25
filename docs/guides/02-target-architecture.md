# Target Architecture & Boundaries

상태: Phase 4 독립 실험·첫 Lab 초안 구현 완료 / 공개 글·배포 없음. 기존 GitHub repo·이력을 유지하고 로컬 루트를 `leeeeeoy/`로 전환한다. 새 repo 생성·rename은 하지 않는다.

## 디렉터리 계약

```text
apps/web/                       # 기존 frontend/ 이전, React/Vite 정적 앱
apps/api/                # 방문 집계 API · 경력/글 콘텐츠는 정적
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
- Lab/Writing: **`content/`의 Markdown + frontmatter**를 빌드 시 읽어 목록/상세에 반영한다. 첫 Go 실험 글은 draft:true이며 공개 글은 0개다.
- Lab과 Writing은 동일한 **렌더링 기반**(제목·문단·이미지·링크·코드 블록·표)을 공유할 수 있지만 **내용/템플릿 규칙**은 다르다.
- 저장소 루트 외부 파일·개인 로컬 디렉터리는 빌드 입력으로 만들지 않는다.
- 한국어 단독 글도 `?lang=en` UI에서 원문 그대로 표시한다. 영문 본문을 자동 생성하지 않는다.

## 최소 Frontmatter 계약(확정)

```yaml
---
title: "Go 동시성과 처리량"
date: "2026-10-14"
summary: "동시 요청에 따른 응답 시간과 처리량 관찰"
tags: [go, performance]
draft: false
---
```

- `slug`는 파일명에서 결정하고 section은 lab/writing 디렉터리로 결정한다. 같은 영역 내 slug는 중복 불가, 서로 다른 영역은 같은 slug를 허용한다. 필드·타입·날짜 규칙은 [03 계약](03-content-and-writing.md)을 따른다.
- `date`는 실제 YYYY-MM-DD 날짜; title/date/summary는 필수다. tags/draft/updated는 선택이며 draft 기본값은 true로 확정했다. 명시적 false만 공개한다.
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
- Markdown 글 상세는 Phase 3에서 구현했다. 없는 경로 안내는 UI이며 HTTP 404 보장은 아니다. [Phase 3 기록](../archive/work-records/12-phase3-content-record-2026-10-14.md)을 따른다.

## 운영 경계

```text
Markdown / 정적 데이터 ──(web build)──> Workers Static Assets ──> 방문자
      Lab 결과 ──(링크)───────────────┘
Go/Python 실험 ──(별도 실행)──> 로컬 결과 저장/분석
API Worker/D1 ──(동의 기반 방문 집계; 기존 콘텐츠 표/R2 보존)
```

- 실험은 기본적으로 로컬에서 수행한다. 특정 주제 때문에 배포가 필요하면 **그 실험의 문서와 별도 승인**을 거친다.
- DB, 인증, 개인 데이터 처리 없이 정적 웹으로 운영한다.
- 웹 CI는 `apps/web/**`, `content/**`, 관련 config·workflow를 커버한다. Lab 변경만으로 웹을 배포하지 않는다.

## 의사결정이 필요한 경우

1. slug/frontmatter/draft 계약은 03에 확정. 새 메타데이터 필드가 필요하면 먼저 계약을 갱신한다.
2. Git 전략은 기존 repo·origin·이력 유지로 확정. 로컬 이전은 [Phase 1 기록](../archive/work-records/10-phase1-migration-record-2026-10-14.md)을 따른다.
3. 렌더러는 react-markdown + remark-gfm, YAML은 빌드 전용 yaml. raw HTML을 허용하는 플러그인은 추가하지 않는다.
4. 새 개별 글의 검색 노출은 글별 메타데이터/sitemap/프리렌더가 필요할 수 있음. **SEO를 위해 전체 프레임워크 교체 금지**.

## 후속 구현의 확인 항목

Vite plugin이 build/dev에서 모든 파일을 검증하고 공개 글만 virtual module로 공급한다. 초안은 dist 번들에서도 제외하며 dev에서는 추가/수정/삭제를 감시한다. sitemap은 아직 네 기본 경로만 포함한다. 현재 SPA fallback의 없는 글 안내가 HTTP 404를 보장하지 않으며, build-time 콘텐츠 공급도 글별 초기 HTML/OG 생성을 보장하지 않는다.

## 방문 집계 예외 (2026-10-25)

사용자 승인으로 기존 Worker/D1을 `/api/visits`에 재사용한다. 경력·글 콘텐츠는 정적이며 방문 합계만 API로 읽고, 새 분석 동의가 있을 때만 등록한다. 이 예외는 CMS·인증·댓글 API 도입이 아니다. [집계 계약](../../apps/api/README.md)에 동시성·중복·개인정보·개발·배포 경계를 정리한다. 위 본문의 Backend 미사용 설명은 방문 집계를 제외한 콘텐츠 경계로 해석한다.

2026-10-25 추가 승인: 앱 경로는 `apps/api`로 변경하며 Cloudflare 운영 리소스 이름은 유지한다. `develop` API Preview는 별도 D1을 사용하고 합계만 읽는다. 운영 SQL/migrations는 로컬 보존·Git 제외하며, 공개 CI의 합성 테스트 스키마와 분리한다. Lab 재현용 SQL은 유지한다.
