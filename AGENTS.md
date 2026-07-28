# AGENTS.md

추측하지 말고 객관적으로 답할 것.

## 프로젝트

개인 포트폴리오 웹사이트다.

- Frontend: React + Vite + TypeScript
- Hosting: Cloudflare Pages
- Assets: Cloudflare R2
- Backend: Cloudflare Workers + Hono
- Database: Cloudflare D1
- CI/CD: GitHub Actions

Frontend의 공개 콘텐츠는 빌드에 포함된 정적 데이터를 최종 원본으로 사용한다.
기존 Worker와 D1은 새 Frontend 안정화 전까지 보존하고, 실제 사용처를 확인한 뒤 정리한다.

## 저장소 구조

- `frontend/`: React 정적 SPA
- `backend/`: 기존 Cloudflare Workers API
- `docs/portfolio-renewal/`: 개편 기준과 실행 기록

Frontend와 Backend는 서로 직접 참조하지 않는다.

## Frontend 규칙

- React, Vite, TypeScript를 사용한다.
- 우선 `/` 단일 페이지로 유지한다.
- 의미 구조는 HTML, 레이아웃·반응형·전환은 CSS를 우선한다.
- 접근성 기본 요소와 `prefers-reduced-motion`을 생략하지 않는다.
- 공개 콘텐츠는 TypeScript 또는 JSON 한 곳에서 관리한다.
- 이미지에는 크기를 명시하고 R2 URL을 사용한다.
- 전역 상태관리, router, Axios, React Query, UI framework, CSS-in-JS,
  animation library는 실제 요구가 확인되기 전까지 추가하지 않는다.
- API 호출이 필요해지면 브라우저 `fetch`를 우선한다.
- 불필요한 컴포넌트 분리와 범용 abstraction을 만들지 않는다.

## Backend 규칙

- Backend가 필요한 경우 Cloudflare Workers와 Hono만 사용한다.
- API는 stateless하게 유지하고 `/api/*`에서 JSON만 반환한다.
- Node.js 전용 API 대신 Web Standard API를 사용한다.
- D1 쿼리는 단순 SQL로 유지하며 ORM을 추가하지 않는다.
- R2 파일은 CDN URL로 접근한다.
- 복잡한 Domain/Service/Repository 계층을 추가하지 않는다.

## CI/CD

- Frontend 변경은 Pages만 배포한다.
- Backend 변경은 Workers만 배포한다.
- 테스트, 타입 검사, build, SonarQube Cloud Quality Gate가 성공해야 배포한다.
- deploy job은 검사 job을 `needs`로 의존한다.
- main만 Production에 배포한다.

## 개인정보

- `resume/`, 원본 이력서, 추출 텍스트, 전화번호, 개인 이메일, 상세 주소,
  생년월일, 지원 기업별 문장은 Git에 저장하지 않는다.
- 공개가 승인된 경력·기술·성과·링크만 Frontend 데이터에 포함한다.
- 비공개 분석은 ignore된 `docs/**/private/`, `docs/**/raw/` 또는 임시 디렉터리에서 처리한다.

## 변경 원칙

- 기존 구현을 확인한 뒤 가장 작은 동작하는 변경을 선택한다.
- 필요가 확인되지 않은 기능과 확장 지점을 만들지 않는다.
- 운영 Worker, D1, R2, Pages 삭제는 백업과 사용자 승인 없이 실행하지 않는다.
- 관련 검사를 실행한 뒤 적절한 단위로 커밋한다.
