# Migration Plan — 기존 운영 환경을 보호하는 점진적 전환

2026-10-25 후속 상태: 모노레포는 운영에 반영됐으며 저장소는 `leeeeeoy/personal-space`로 변경했다. 구형 GitHub Pages는 해제했다. 아래 Phase 0~4의 repo 이름 고정·로컬 작업 제한은 당시 승인 범위이며, 이후 운영·이름 변경·개인정보 이력 정리는 별도 사용자 승인을 받았다. 현재 릴리스 절차는 [프로젝트 README](../../README.md), 집계 계약은 [API README](../../apps/api/README.md)를 따른다.

## 전제

- **원본:** `leeeeeoy/leeeeeoy.github.io` (React SPA + Workers Static Assets), 운영 도메인 `leeeeeoy.xyz`.
- **확정:** 기존 GitHub repo·origin·이력을 유지하고 로컬 루트를 `leeeeeoy/`로 전환. `migration/phase1-monorepo` 브랜치에서 수행하며 main/develop은 변경하지 않는다.
- **현재 승인 범위:** Phase 4·Harness 구현 이후 문서 정리·공개 위험 점검·검증·로컬 커밋. 실험 결과와 첫 초안은 사용자 결정으로 커밋을 보류한다. Phase 1 구조와 기존 경력 데이터·Portfolio 인터랙션·Notes 주소를 보존한다. push·PR·main/develop 병합·배포·원격 이름/URL·리소스 변경은 금지.

## 합의한 Git 이전 전략

기존 모든 refs의 bundle과 작업 트리·비공개 자산/상위 문서 백업을 저장소 밖 소유자 전용 경로에 만든다. bundle 복원 작업본에서 refs·fsck·파일 hash를 검증한 뒤 새 migration branch에 경로 이전을 기록한다. 검증한 작업본을 최종 루트에 적용하고 원본 중첩 저장소는 비공개 backup 위치에 보존한다. 원본 `.git`만 승격하거나 상위 `git init` 후 중첩 repo를 add하지 않는다.

`develop`을 병합하거나 main에 맞춰 변경하지 않는다. GitHub repo 이름·origin은 그대로다. 다른 전략의 비교와 당시 제안은 [09 실행안](../archive/work-records/09-migration-execution-plan-2026-10-14.md), 실제 위치·복구 절차는 [Phase 1 기록](../archive/work-records/10-phase1-migration-record-2026-10-14.md)을 따른다.

## Phase 1에서 달라진 승인 게이트

운영 배포 ID·Access 인증 사용자 확인은 실제 릴리스 전에 필요하지만, 사용자가 별도 승인한 로컬 Phase 1을 막는 조건으로 사용하지 않는다. 이번 단계의 완료 조건은 로컬 Git/파일/QA/CI 경로 확인이며 Preview 배포는 수행하지 않는다.

구조 이전 커밋을 main에 반영하면 웹과 API가 모두 workflow 대상이 된다. 기존 정책을 임의로 바꾸지 않으며, 향후 main 반영 시 동반 API 배포 승인 또는 별도 제한을 먼저 결정한다.

## 단계별 변경 — 각각 별도 검증 후 진행

### Phase 0. 소스 현황 고정·전략 결정

- 최신 브랜치/커밋, `git status`, 현재 운영 URL의 핵심 화면과 미리보기 Access 동작을 확인.
- 기존 repo·origin 유지와 로컬 루트 이전은 승인 완료. GitHub 이름 변경은 하지 않는다.
- 현재 Secrets 존재 여부와 배포 권한·Custom Domain 연계 구조를 **값을 노출하지 않고** 확인.
- 백업/롤백 가능한 기준 커밋과 Cloudflare 이전 배포 ID를 기록.
- **Gate:** 승인 없이 repo·DNS·Secrets·Cloudflare 리소스를 변경하지 않는다.

### Phase 1. 문서·디렉터리·CI 경로 준비

- 목표 구조에 `AGENTS.md`, `CLAUDE.md`, docs 및 template 넣기.
- `frontend/` → `apps/web/`, `backend/` → `apps/api/`는 **파일 위치만 우선** 변경.
- npm scripts / lockfile / Node .nvmrc / Vitest / .gitignore / Wrangler workingDirectory / 경로 기반 Actions 업데이트.
- 기존 정적 콘텐츠, 서드파티 동의, 접근성, 리다이렉션 설정을 변경하지 않는다.
- **Gate:** 기존 테스트/타입 검사/빌드 및 CI 정적 검사 통과. Preview 배포·인증 사용자 확인은 금지 범위이므로 별도 승인된 릴리스 단계까지 미검증으로 남긴다.

### Phase 2. 개인 웹사이트 내비게이션

- 기존 `/`의 경력 콘텐츠를 `/portfolio/`에서 접근 가능하게 하되 정보 손실 없이 이전.
- `/` Home은 자기소개/사이트 소개/세 영역 링크로 변경. 실제 글이 없으므로 최근 글·예시 글은 표시하지 않음.
- `/lab/`, `/writing/`는 첫 글이 없어도 빈 상태를 정상 표시.
- `/notes/` 목록·상세 주소와 화면을 유지하고 Lab 안내를 제공. 옛 root 섹션 링크는 Portfolio로 연결.
- **Gate:** 포트폴리오 경력·프로젝트 전체 유지, 새 경로·뒤로/앞으로·새로고침·양언어·반응형·키보드 검증. 로컬 결과는 [Phase 2 기록](../archive/work-records/11-phase2-pages-record-2026-10-14.md); 배포 검증은 별도.

### Phase 3. Markdown 콘텐츠 파이프라인

- `content/lab/`, `content/writing/` 빌드 통합, 목록·상세 표시, frontmatter 검증.
- 코드 블록·표·이미지·링크를 가진 합성 테스트 fixture로 렌더링 확인. 공개 content에 샘플/실제 글을 넣지 않는다.
- 초안 제외, 중복 slug 차단, 공개 링크/정적 사이트 fallback 확인.
- **Gate:** 새 글 파일만 추가해 목록·상세에 표시 가능. 실제 글·게시 없이 테스트 fixture로 검증한다. 사용자 Phase 3 지시가 종전 샘플 발행 제안을 대체한다. [검사 기록](../archive/work-records/12-phase3-content-record-2026-10-14.md).

### Phase 4. Lab 실험 도입

- 원본이 없으므로 사용자 지시에 따라 `labs/go-load-test/`에 새 표준 라이브러리 실험을 작성하고 과거 결과와 분리한다.
- `go test ./...`와 실행 명령, 결과의 측정 환경을 문서화.
- 실험 변경으로 웹 배포가 발생하지 않도록 워크플로 검증.
- **Gate:** 타인이 README만으로 실험을 재현할 최소 요건 충족. 재현 실패는 한계를 기록. 이번 로컬 결과와 초안 상태는 [Phase 4 기록](../archive/work-records/13-phase4-go-lab-record-2026-10-15.md)을 따른다.

### Phase 5. 운영 전환·검증

- main에 병합하기 전 Preview에서 도메인·Access·이미지·Clarity 동의·콘텐츠 검증.
- 실제 운영 배포는 사용자 별도 승인 후 진행. 기존 URL의 동작과 301 리다이렉션 유지.
- Sitemap/메타데이터/내부 링크 확인. 운영 결과 확인 후 이전 문서 상태 기록.
- `apps/api`와 D1/R2는 삭제하지 않는다. 별도 사용처·백업·승인 프로젝트에서 정리한다.

## 작업 중 중단 조건

- 기존 Production/Preview 라우팅이 달라지거나 공개 범위가 확장되는 경우
- `.env`, 토큰, 개인정보 등 민감 파일이 Git diff에 나타나는 경우
- 원래 테스트가 실패하거나 통합 후 경력 내용이 누락되는 경우
- 새 레포와 기존 레포가 둘 다 자동 Production 배포하게 될 위험이 있는 경우

## 롤백

- 저장소 이전 이전: 작업 브랜치를 버리거나 기준 커밋으로 복귀.
- Preview 실패: Preview 배포 이전 버전 재적용.
- 운영 이전 실패: 검증된 Workers 배포 버전을 재배포/롤백하고 커스텀 도메인·Access 설정이 유지되었는지 확인.
- 삭제형 작업은 이번 프로젝트에 없다. GitHub repo 원본, D1, R2, 기존 Worker는 유지.
