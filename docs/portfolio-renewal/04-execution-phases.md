# 실행 페이즈

## Phase 0. 사실 확정과 아키텍처 승인

목표: 구현 전에 바뀌지 않아야 할 기준을 확정한다.

- 이력서 간 수치·기간 불일치 확인
- 공개 가능한 회사·프로젝트 범위 확인
- React + Vite 승인
- 정적 데이터를 최종 원본으로 사용할지 승인
- 기존 AGENTS 규칙 변경 승인

완료 조건:

- 확인 대기 항목이 모두 확정 또는 보수적 표현으로 결정됨
- FE와 데이터 원본 결정이 문서에 반영됨

## Phase 1. 콘텐츠 확정

목표: UI보다 먼저 읽을 만한 포트폴리오 내용을 만든다.

- 소개 문장
- 대표 지표 3~4개
- 회사별 summary, metrics, highlights
- 대표 프로젝트 2~3개
- 근거 기반 스킬 그룹
- 공개 링크 목록

완료 조건:

- 개인정보 검사 통과
- 동일 수치가 문서마다 다르게 표현되지 않음
- 각 대표 사례에 문제·행동·결과가 드러남

## Phase 2. React 정적 FE 교체

목표: 기존 Pages 배포 경계를 유지하면서 Flutter Web을 교체한다.

- feature branch에서 `frontend/`를 교체
- 단일 `/` 페이지 구현
- 정적 콘텐츠 연결
- R2 이미지 연결
- HTML·CSS 중심의 반응형·접근성·메타데이터 적용
- 단위 테스트는 데이터 검증과 핵심 렌더링에 한정

기존 Flutter와 새 FE를 같은 브랜치에 장기간 중복 유지하지 않는다.
Git 브랜치와 Pages Preview가 롤백 수단이다.

완료 조건:

- production build 성공
- Pages Preview에서 모바일·데스크톱 확인
- 외부 링크와 이미지 확인
- JavaScript 오류 없음
- 별도 Worker API 요청 없이 핵심 콘텐츠 표시
- 기존 production보다 필요한 콘텐츠가 빠지지 않음

## Phase 3. CI/CD 전환

목표: Flutter 전용 단계를 Node 기반 정적 빌드로 교체한다.

- `flutter test` 제거
- `npm ci`, test, typecheck, build 적용
- deploy가 test/build에 `needs`로 의존
- main만 Production, develop은 Preview 유지

완료 조건:

- 테스트 또는 build 실패 시 배포되지 않음
- frontend 변경은 Pages만 배포
- backend 변경은 Workers만 배포

## Phase 4. Production 전환

목표: 기존 custom domain에서 새 FE를 서비스한다.

- Pages Preview 최종 확인
- main 병합 및 Production 배포
- R2 이미지와 정적 자산 오류 모니터링
- OG, canonical, robots 확인
- 이전 Flutter build로 롤백 가능한 배포 ID 보관

완료 조건:

- `portfolio.leeeeeoy.xyz` 정상 응답
- 주요 화면과 외부 링크 정상
- 모바일 성능과 접근성 기본 검사 통과

## Phase 5. Backend 정리 결정

새 FE 안정화 후에만 진행한다.

### 정적 데이터를 최종 원본으로 선택한 경우

- 새 FE가 Worker API를 호출하지 않는지 확인
- D1 export 백업
- Worker와 D1 제거 여부 승인
- R2는 이미지 저장소로 유지
- backend CI와 문서를 실제 구성에 맞게 정리

### D1을 유지하는 경우

- 기존 Worker API 유지
- 데이터 수정 절차 또는 migration 추가
- 정적 export 갱신을 위한 명시적 frontend 재배포 절차 추가

관리 화면 요구가 없다면 첫 번째가 더 단순하다.

## 롤백

- FE: 이전 Pages deployment로 롤백
- 데이터: D1 변경 전 export 또는 정적 데이터 Git 이력
- 인프라: Worker/D1 제거는 새 FE 안정화 전 실행하지 않음
