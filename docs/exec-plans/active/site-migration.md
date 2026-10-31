# Execution Plan — Personal Space Migration

> 이 계획의 Phase별 체크박스와 아래 상태는 당시 실행 기록이다. 2026-10-25 모노레포 운영 반영·저장소 이름 변경의 후속 상태는 [이전 지침](../../guides/04-migration-plan.md)에 구분돼 있다. 현재 구조·작업 권한은 [AGENTS](../../../AGENTS.md)와 현재 사용자 요청을 따른다. 과거의 미검증·공개 보류 기록을 소급해 완료 처리하지 않는다.

- **상태:** Phase 4 완료(로컬·초안) / 릴리스 승인 대기 / push·PR·배포 금지
- **범위:** 기존 포트폴리오 + Lab + Writing 모노레포 정리
- **소스:** `leeeeeoy/leeeeeoy.github.io` main (실작업 시작 시 최신 커밋 확인)
- **목표 repo:** 기존 `leeeeeoy/leeeeeoy.github.io`와 origin 유지. 로컬 루트는 `<repo>`, 작업 브랜치는 `migration/phase1-monorepo`.
- **비목표:** 로그인, 댓글, 관리자, CMS, 새로운 API/DB, 기존 리소스 삭제
- **검증 원본:** `docs/guides/06-quality-and-safety.md`
- **중단/롤백:** `docs/guides/04-migration-plan.md`

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

**상태: 완료(로컬).** 소스/설정 동등성·QA·Git 보존·CI 정적 검사 및 로컬 Chrome 회귀 확인 완료. Preview/Production은 미검증으로 별도 기록한다. FAIL이면 Phase 2 금지. 검사 근거는 [Phase 1 기록](../../archive/work-records/10-phase1-migration-record-2026-10-14.md).

## Phase 2 — 사이트 정보 구조

- [x] Home과 Portfolio 라우트 분리; 기존 Portfolio 본문·경력 데이터 전체 유지
- [x] Lab/Writing 설명·빈 상태와 공통 메뉴·현재 페이지 표시
- [x] Notes 목록/상세 유지 + Lab 안내; 옛 root 섹션 주소도 연결
- [x] 언어/테마/동의/모바일/직접 접근·새로고침·뒤로/앞으로·키보드 로컬 회귀 검사

**상태: 완료(로컬).** 검증 근거는 [Phase 2 기록](../../archive/work-records/11-phase2-pages-record-2026-10-14.md). 운영/Preview 미검증은 그대로 유지한다.

## Phase 3 — 글 발행

- [x] Markdown frontmatter 계약 구현, 검증 실패 메시지 제공
- [x] 목록·상세·초안 필터·slug 중복 테스트
- [x] 코드 블록/표/이미지/링크 합성 fixture 미리보기 확인
- [x] 실제 글 없이 격리된 테스트 자료로 dev/build·목록/상세·초안 제외 검증

**상태: 완료(로컬).** 파일 추가와 build로 목록·상세에 반영 가능. 사용자 Phase 3 지시의 실제 글 금지가 종전 첫 글 검증 제안을 대체했다. 원격 발행·글 내용은 별도 승인 대상이며 이번에 글을 작성하지 않았다. 근거는 [Phase 3 기록](../../archive/work-records/12-phase3-content-record-2026-10-14.md).

## Phase 4 — 실험 자산 연결

- [x] 원본 미확보에 따라 사용자 승인으로 신규 Go HTTP 실험 설계·실행
- [x] `labs/go-load-test` 독립 실행 및 README/환경/42회 결과·그래프 기록
- [x] Go test/race/vet·도구 자체 검사 완료; 별도 CI는 현재 로컬 범위에 불필요해 미도입
- [x] Lab 초안(draft:true)에 구현·측정·재현 경로·출처/한계 기록 및 격리 로컬 렌더 검증

**상태: 완료(로컬·초안).** 기존 유효35회와 재개7회, 원본 보존·보조 검증·분석·초안의 근거는 [Phase 4 기록](../../archive/work-records/13-phase4-go-lab-record-2026-10-15.md). 기존 원본 확보 계획은 사용자 최신 지시가 대체했다. 실제 공개용 그래프/커밋 링크와 릴리스는 사용자 검토 이후 별도 승인 대상이다.

## Phase 5 — 릴리스

- [ ] 운영 이전 체크리스트 완료(`docs/guides/06-quality-and-safety.md`)
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
- 구현·검사 근거와 HTTP 404/초기 HTML·실기기·운영 미검증은 [Phase 2 기록](../../archive/work-records/11-phase2-pages-record-2026-10-14.md).
- Phase 3 Markdown/실제 글/실험/배포 미실행. 이번 단계 종료 후 다음 지시 대기.

## 2026-10-25 — API 재사용·Preview 및 운영 병합 준비

- 사용자 승인: 기존 D1 방문 집계, API 이름 `apps/api`, 운영 SQL/migrations
  로컬 보존·Git 제외, 프리뷰 적용. Lab SQL은 유지한다.
- 기존 Phase 기록의 `apps/legacy-api`는 당시 경로이며 현재 실행 경로는
  `apps/api`다. Worker·운영 D1 이름은 유지한다.
- `develop`은 Web/API Preview, `main`은 Production, PR은 검사만 수행한다.
  이전 경로 삭제도 CI에서 검사하도록 이전 API 경로 필터를 이행 기간 유지한다.
- Preview D1은 별도 리소스이며 웹은 GET만 사용한다. Preview 서버는 POST를
  거부한다. 운영 집계는 증가하지 않는다. Access 정책을 완화하지 않는다.
- 공개 CI는 배포 SQL·로컬 secret·기존 D1 상태 없이 합성 스키마로 검사한다.
  로컬 분리 사본에서 API 13개 검사 및 typecheck 통과. 웹 18개 검사,
  content:check/lint/format:check/typecheck/build, 두 Preview dry-run 통과.
- 브라우저 로컬 1440px·320px 한국어 다크, 390px 영어 라이트에서 하단
  줄바꿈과 가로 넘침을 확인했다. 집계 날짜/중복 설명은 UI에서 제거한다.
- main 병합/운영 배포는 아직 승인되지 않았다. Production secret 등록과
  최초 API Worker 준비가 필요한 상태이며 상세 릴리스/복구 경계는
  [API README](../../../apps/api/README.md)를 따른다.

### Preview 실제 검증 결과

- Web [CI 40154285924](https://github.com/leeeeeoy/leeeeeoy.github.io/actions/runs/40154285924): Node 26 QA·배포 성공.
- API [CI 40154285927](https://github.com/leeeeeoy/leeeeeoy.github.io/actions/runs/40154285927): Node 22 QA 성공, Worker 업로드 후 Zone route 접근 권한 오류로 배포 실패. 권한을 확인한 로컬 Wrangler로 **Preview만** 배포 완료. CI 실패를 통과로 처리하지 않는다.
- 인증 브라우저에서 실제 Preview의 320/390/1440px, 한·영·두 테마,
  방문 합계 0·0, 경력 키보드 펼치기·새로고침, Lab/Writing/Notes,
  기존 R2 이미지 3개 로딩 확인. 비인증 웹/API는 Access 차단 유지.
- 운영 웹 버전 `e13bde78-3ace-43dc-a36b-e6f74e29ac77` 유지.
  Preview와 운영 D1 모두 집계/식별 키 0건, 운영 쓰기 없음.
- 현재 계정에서 운영 API Worker 조회는 10007(없음)이다. 운영 병합 전
  API 토큰의 대상 Zone 접근·Workers Routes 편집 권한을 해결하고,
  최초 운영 Worker와 `VISIT_HASH_SECRET`를 별도 승인 범위에서 준비해야 한다.
  main은 변경하지 않았으며 운영 집계 실동작은 아직 미검증이다.

### 공용 토큰 Preview 검증 및 develop PR 준비

- Web·API가 기존 `CLOUDFLARE_FRONTEND_API_TOKEN` 하나를 참조한다.
  Secret 값/권한은 변경하지 않았다. 이전 API Zone route 권한 오류는
  공용 토큰으로 실제 CI 배포에 성공해 해결을 확인했다.
- 검증 커밋 `ee348ec`: [Web CI 40155988105](https://github.com/leeeeeoy/leeeeeoy.github.io/actions/runs/40155988105),
  [API CI 40155988100](https://github.com/leeeeeoy/leeeeeoy.github.io/actions/runs/40155988100)
  모두 QA·Preview 배포 성공. Web Node 26, API Node 22에서 검사했다.
- 구조도에 R2 직접 요청과 방문 집계 Worker API → D1 경로를 나눠 표시했다.
  배포 자산과 실제 구조도/방문 합계, 320px 가로 넘침 없음,
  비인증 웹/API Access 차단을 확인했다.
- develop을 변경하지 않고 작업 브랜치에 한정한 임시 Preview 트리거로
  검증했으며, PR 최종 변경에서는 이 트리거를 제거한다.
  main=Production / develop=Preview / PR=검사만 정책을 유지한다.
- 운영 배포·main/develop 병합·`VISIT_HASH_SECRET` 등록은 수행하지 않았다.
  운영 Secret은 사용자가 운영 배포 시 등록할 예정이며 운영 실동작은 미검증이다.

### 선형 이력 유지와 운영 릴리스 승인

- 2026-10-25 사용자 승인: PR #6을 develop에 squash merge한 뒤,
  검증된 origin/develop을 main에 fast-forward하고 운영 배포한다.
- 시작 시 main `0d549c8`, develop `44a09aa`는 22개 커밋 차이의 선형 관계다.
  이미 공개된 develop을 main 위치로 되감지 않으며 기존 이력을 보존한다.
  로컬·원격 main/develop은 최종 릴리스 커밋으로 일치시킨다.
- Git 전체 bundle과 refs를 비공개 경로에 백업하고 복구 가능성을 확인했다.
  D1 전체 export는 자동 승인 검토가 데이터 반출 목적지 승인 부족으로 거절해
  실행하지 않았다. 이번 릴리스는 D1 스키마·기존 데이터 변경이 없으며
  이전 비공개 백업은 보존한다.
- 독립 worktree의 npm ci·웹 18개/API 13개 검사와 타입·빌드가 통과했다.
  설치 audit에서 실제 CORS 경로에 관련된 Hono 취약점이 확인되어
  동일 4.x 수정 버전 4.13.13으로 최소 업데이트했다. API 13개 검사와
  typecheck 통과, Web/API 운영 의존성 audit는 0건이다. 개발 도구 의존성의
  audit 경고(Web 6건, API 20건)는 별도 정리가 필요하며 이번에 일괄 업데이트하지 않았다.
  [공식 CORS 보안 공지](https://github.com/honojs/hono/security/advisories/GHSA-8j4g-w8fx-2239).
- 운영 VISIT_HASH_SECRET은 사용자가 배포 후 직접 등록할 예정이다.
  별도 값을 임의 생성하거나 Preview/로컬 비밀키를 운영에 복사하지 않는다.
  미등록 시 방문 등록은 503으로 거부하며 운영 검증 결과와 구분한다.
