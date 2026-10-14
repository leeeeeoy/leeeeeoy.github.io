> ARCHIVE / superseded — 최초 제안 문서 패키지 안내입니다. 현재 시작점은 [루트 README](../../../README.md)입니다.

# 개인 웹사이트 모노레포 전환 — 검토용 문서 패키지

- **상태:** 제안안(PROPOSAL). 기존 GitHub 저장소와 Cloudflare 리소스를 수정하지 않았다.
- **기준일:** 2026-10-14
- **기존 저장소:** https://github.com/leeeeeoy/leeeeeoy.github.io (`main` 기준 파일 열람)
- **운영 도메인:** https://leeeeeoy.xyz
- **목표:** 개인 웹사이트 안에 Portfolio, Lab, Writing을 두고 Lab 실험 코드를 같은 모노레포에서 관리한다.

## 어떻게 사용하나

1. `docs/01-current-state.md`와 `docs/02-target-architecture.md`로 **실제 상태와 목표 구조를 분리**해 읽는다.
2. `docs/04-migration-plan.md`와 `docs/exec-plans/active/site-migration.md`를 검토해 이전 전략(새 저장소 또는 기존 저장소 개편)을 먼저 결정한다.
3. 선택한 **목표 저장소 루트**에 이 패키지의 `AGENTS.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `docs/`, `templates/`를 넣는다. 기존 소스 이관은 Phase 1 이후 에이전트가 수행한다.
4. `AGENTS.md`와 `CLAUDE.md`는 기존 저장소의 동명 파일을 **그대로 덮어쓰는 즉시 실행용 패치가 아니다**. 마이그레이션 계획 승인 및 루트 경로 확정 뒤 적용한다.
5. Claude Code에 `CLAUDE.md`를 읽고 실행 계획의 **한 단계만** 수행하게 한다. 테스트/검증과 변경 요약 후 다음 단계로 간다.

## 문서 목록

- `AGENTS.md`: 에이전트 공통 진입점·보호 규칙·문서 맵
- `CLAUDE.md`: Claude Code용 진입점(중복 규칙 최소화)
- `ARCHITECTURE.md`: 단일 페이지 아키텍처 맵
- `docs/README.md`: 상세 문서 인덱스
- `docs/00-vision-and-scope.md`: 목적·제품 범위·비목표
- `docs/01-current-state.md`: 원본 저장소 점검과 역사적 문서의 차이
- `docs/02-target-architecture.md`: 디렉터리·계층·배포·콘텐츠 계약
- `docs/03-content-and-writing.md`: Lab·Writing 작성·발행 정책
- `docs/04-migration-plan.md`: 무손실 이전·검증·롤백·결정 게이트
- `docs/05-lab-practices.md`: 실험·학습 루프와 증거 정책
- `docs/06-quality-and-safety.md`: CI, 테스트, 보안 및 개인정보
- `docs/07-future-considerations.md`: 현재 제외한 기능들
- `docs/exec-plans/active/site-migration.md`: 에이전트의 단계별 실행 체크리스트
- `templates/experiment.md`, `templates/lab-note.md`, `templates/writing.md`: 내용 템플릿

## 원본 파일은 포함하지 않음

이 ZIP은 **새 구조의 지침과 설계 문서만** 담는다. 기존 `frontend/`, `backend/`, `.github/workflows/`, `docs/portfolio-renewal/`의 실제 파일은 원본 GitHub 저장소에 그대로 있으며, 패키지에 복제하지 않았다. 따라서 원본 `docs/portfolio-renewal/...` 참조 경로는 이 ZIP 안에서 열리지 않는 것이 정상이다. 이전 에이전트가 해당 파일을 실제 저장소에서 확인한 뒤 보존해야 한다.

## 해석 우선순위

1. 실제 현재 코드·배포·CI 설정(직접 검사)
2. 이번에 승인된 VISION·ARCHITECTURE·마이그레이션 문서
3. 기존 `README.md`, `AGENTS.md`, `docs/portfolio-renewal/`은 과거 설계 이유를 설명하는 참고 자료
4. 상충 시 추측으로 합치지 말고 근거와 영향 범위를 기록하고 사용자에게 확인

> 아직 결정되지 않은 것: GitHub 최종 저장소 이름, **새 저장소로 복사 vs 기존 저장소 이름 변경** 방식. 본 문서의 `personal-space/` 경로는 제안용으로, 저장소 이름·도메인 변경을 강제하지 않는다.
