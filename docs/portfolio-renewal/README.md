# 포트폴리오 개편 계획

## 목적

최근 작성한 이력서 4종과 현재 운영 중인 포트폴리오의 D1 데이터, Flutter Web 화면,
Cloudflare 인프라를 비교해 다음 개편의 기준을 정한다.

이 문서는 공개 가능한 경력·기술 정보만 다룬다. 이름, 전화번호, 이메일, 상세 거주지,
지원 기업별 자기소개, 원본 이력서 문장은 기록하지 않는다.

## 결론

권장 목표는 다음과 같다.

```text
React + Vite
        │
        ├─ 정적 경력 데이터(TypeScript 또는 JSON)
        ├─ R2 공개 이미지
        └─ Cloudflare Pages
```

- 포트폴리오는 공개 읽기 전용 데이터이며 업데이트 빈도가 낮다.
- 단일 페이지에 서버 렌더링, 서버 컴포넌트, 파일 기반 라우팅이 필요하지 않다.
- Vite는 작은 정적 번들을 만들고 현재 Pages 배포 경계를 그대로 유지한다.
- 콘텐츠는 FE 빌드에 포함해 첫 화면에서 별도 API 요청과 loading UI를 없앤다.
- 의미 구조는 HTML, 레이아웃과 전환은 CSS, 메뉴·필터 등 필요한 동작만 React로 구현한다.
- 새 관리 화면이나 실시간 데이터 갱신 요구가 생기기 전까지 D1과 BFF는 필수 인프라가 아니다.

React SPA는 초기 HTML에 본문이 직접 포함되지 않는 한 정적 HTML보다 검색 노출에 불리할 수 있다.
현재 사이트는 개인 포트폴리오 단일 페이지이고, 우선순위는 작은 번들·빠른 인터랙션·단순한
운영이다. 검색 유입이 실제 요구로 확인되면 그때 prerender 또는 정적 사이트 도구를 검토한다.

## 구현 전 결정 게이트

현재 `AGENTS.md`는 Flutter, flutter_bloc, Dio, go_router를 강제한다.
React 전환을 시작하려면 먼저 이 규칙을 새 구조에 맞게 변경해야 한다.

승인할 결정:

1. Frontend를 React + Vite로 교체한다.
2. 공개 포트폴리오 데이터의 최종 원본을 저장소의 정적 데이터로 둔다.
3. 기존 Worker/D1은 새 사이트 검증 완료 후 유지 또는 제거를 결정한다.
4. R2는 기존 이미지 저장소로 유지한다.

## 문서

- [현재 상태와 이력서 차이](./01-current-state-and-resume-gap.md)
- [데이터 개편 계획](./02-data-renewal-plan.md)
- [Frontend 전환 계획](./03-frontend-migration-plan.md)
- [실행 페이즈](./04-execution-phases.md)
- [개인정보 처리 기준](./05-privacy-and-content-policy.md)

## 범위 밖

- 이력서 원문 자동 동기화
- 포트폴리오 CMS 또는 관리자 페이지
- SSR, ISR, Server Actions
- 초기 단계의 prerender/SSG
- 새 상태관리 라이브러리
- UI 컴포넌트 프레임워크
- 기존 Worker API의 재구현

필요가 확인되기 전에는 추가하지 않는다.
