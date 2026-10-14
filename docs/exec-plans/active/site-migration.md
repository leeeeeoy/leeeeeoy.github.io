# Execution Plan — Personal Space Migration

- **상태:** Phase 2 완료(로컬) / Phase 3 승인 대기 / push·PR·배포 금지
- **범위:** 기존 포트폴리오 + Lab + Writing 모노레포 정리
- **소스:** `leeeeeoy/leeeeeoy.github.io` main (실작업 시작 시 최신 커밋 확인)
- **목표 repo:** 기존 `leeeeeoy/leeeeeoy.github.io`와 origin 유지. 로컬 루트는 `/Users/leeeeeoy/leeeeeoy`, 작업 브랜치는 `migration/phase1-monorepo`.
- **비목표:** 로그인, 댓글, 관리자, CMS, 새로운 API/DB, 기존 리소스 삭제
- **검증 원본:** `docs/06-quality-and-safety.md`
- **중단/롤백:** `docs/04-migration-plan.md`

## Phase 0 — 사용자 결정 게이트

- [x] 로컬 HEAD/변경 내역·main/develop 차이 확인; 원격 관측은 Phase 0 감사에 기록
- [x] 기존 repo·origin·이력 유지, 로컬 루트 이전으로 사용자 승인
- [x] 새 repo 없이 migration branch의 로컬 작업만 수행; CI의 branch/path/event 조건 정적 확인
- [ ] 현재 운영/Preview 핵심 동작과 기준 커밋·롤백 경로 기록
- [x] 사용자 Phase 1 지시에서 로컬 구조·문서·CI 이전 승인

**상태: 보류(운영 릴리스 기준만).** 사용자가 로컬 Phase 1을 별도 승인했다. 배포 ID·인증 사용자 Preview는 릴리스 전 확인하며 이번 로컬 작업에 배포 게이트를 적용하지 않는다.

## Phase 1 — 무기능 구조 이전

- [x] 루트 agent/docs 통합; `docs/archive/portfolio-renewal/`에 역사 원문 보존
- [x] `frontend` → `apps/web`, `backend` → `apps/legacy-api` 위치 변경; source hash 동일
- [x] lockfile/앱 config 내용 유지; CI 경로와 root ignore 수정, main/develop 정책 유지
- [x] fresh 설치·최종 루트 QA·Git refs·CI 정적 검사 및 결과 기록
- [ ] Preview 인증 후 외형·Access 확인 (이번 배포 금지로 보류)

**상태: 완료(로컬).** 소스/설정 동등성·QA·Git 보존·CI 정적 검사 및 로컬 Chrome 회귀 확인 완료. Preview/Production은 미검증으로 별도 기록한다. FAIL이면 Phase 2 금지. 검사 근거는 [Phase 1 기록](../../10-phase1-migration-record-2026-10-14.md).

## Phase 2 — 사이트 정보 구조

- [x] Home과 Portfolio 라우트 분리; 기존 Portfolio 본문·경력 데이터 전체 유지
- [x] Lab/Writing 설명·빈 상태와 공통 메뉴·현재 페이지 표시
- [x] Notes 목록/상세 유지 + Lab 안내; 옛 root 섹션 주소도 연결
- [x] 언어/테마/동의/모바일/직접 접근·새로고침·뒤로/앞으로·키보드 로컬 회귀 검사

**상태: 완료(로컬).** 검증 근거는 [Phase 2 기록](../../11-phase2-pages-record-2026-10-14.md). 운영/Preview 미검증은 그대로 유지한다.

## Phase 3 — 글 발행

- [ ] Markdown frontmatter 계약 구현, 검증 실패 메시지 제공
- [ ] 목록·상세·초안 필터·slug 중복 테스트
- [ ] 코드 블록/표/이미지/링크 미리보기 확인
- [ ] 실제 첫 Lab 글 또는 Writing 글 1편으로 발행 경로 검증

**완료 조건:** Git의 파일 수정·커밋만으로 발행 가능. 사용자가 글 내용 승인.

## Phase 4 — 실험 자산 연결

- [ ] 기존 Go Load Lab 원본 소스 확보
- [ ] `labs/go-load-test` 독립 실행 및 README/환경/결과 기록
- [ ] 필요 시 해당 Lab만 검사하는 CI 구성(첫 실험에 필요할 때)
- [ ] Lab 글에서 코드와 재현 자료 연결

**완료 조건:** Lab 내용의 측정 조건과 출처·한계가 명확함.

## Phase 5 — 릴리스

- [ ] 운영 이전 체크리스트 완료(`docs/06-quality-and-safety.md`)
- [ ] Production 배포는 사용자 승인 후 실행
- [ ] 실제 URL·기존 포트폴리오·Cloudflare Access·redirect 검증
- [ ] 과거 문서 중 superseded 표기 및 README 운영 현황 반영

**완료 조건:** 운영 장애 없음, 기존 리소스 보존, 변경과 근거 기록.

## 세션 기록 (실행할 때 채울 항목)

```text
날짜 / 현재 Phase:
확인한 실제 커밋:
변경 파일:
실행한 검증 / 결과:
미검증 및 막힌 점:
사용자 승인이 필요한 사항:
다음 단일 작업:
```

에이전트는 모든 체크박스를 한 번에 처리하지 않는다. **단계 종료마다 검증과 승인 필요 여부를 보고하고 다음 Phase로 진행한다.**

## 2026-10-14 세션 결과

- 기준 main `dad0449`, develop `500e95d` 및 origin 유지; migration branch에서 로컬 커밋으로 기록.
- Web fresh npm ci 후 최종 루트 lint/format/test(11)/typecheck/build, API fresh npm ci 후 최종 루트 typecheck/test(1) 통과. API 실행 Node는 26, CI 22 재현은 미검증.
- 앱 43개 파일과 dist 10개 hash 동일, CI YAML·54 시나리오·문서 링크·Git 참조 검증.
- 로컬 Chrome에서 양언어/Notes/없는 글/새로고침/테마/본문 포커스/섹션 이동/R2 이미지 확인.
- push·배포·Cloudflare 변경 없음. Preview 인증·모바일 전체·실제 GitHub CI·관리 상태·Go 원본 미검증.
- Phase 2는 별도 사용자 지시 이후 로컬 구현으로 진행 가능. 이 세션은 여기서 종료.

## 2026-10-14 Phase 2 세션 결과

- Home/Portfolio/Lab/Writing 및 현재 메뉴·양언어 UI·모바일 Header 구현, 일반 anchor/pathname 유지.
- Portfolio 데이터·본문 보존. Notes 목록/상세 + Lab 안내, legacy root 섹션 주소 호환.
- Web lint/format:check/test(12)/typecheck/build, local Chrome desktop/390px/320px·언어·테마·동의·키보드·history·Notes·Portfolio 상세/R2 검증.
- 구현·검사 근거와 HTTP 404/초기 HTML·실기기·운영 미검증은 [Phase 2 기록](../../11-phase2-pages-record-2026-10-14.md).
- Phase 3 Markdown/실제 글/실험/배포 미실행. 이번 단계 종료 후 다음 지시 대기.
