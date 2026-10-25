# 운영 후 공개 이력·설정 감사 — 2026-10-25

## 확인과 승인

사용자는 병합된 작업 브랜치 정리, origin과 로컬 동기화, 운영 토큰/환경 설정 검증,
공개 적합성 감사를 요청했다. 감사에서 과거 연락처와 관리자 화면의 개인정보 후보를
확인한 뒤, 백업 후 main/develop 이력 재작성·force push를 명시적으로 승인했다.
구형 GitHub Pages는 더 이상 사용하지 않으므로 해제하고 저장소를 personal-space로
변경하는 것도 승인했다. 운영 Cloudflare 도메인과 리소스 이름은 유지한다.

## 범위와 보존

- 원격 브랜치와 GitHub가 제공하는 PR refs를 별도 mirror로 복제하고 비공개 bundle을 검증했다.
- 과거 연락처 리터럴과 로컬 홈 경로를 치환하고, 개인정보 후보가 있는 관리자 화면 이미지와 로컬 도구 메타데이터를 과거 이력에서 제외했다.
- 이력 정리 직후 최신 tracked tree hash가 원본과 정확히 같음을 확인했다. 이후 변경은 저장소 URL/Go module 참조와 현행 문서 정리다.
- 정리된 mirror의 146개 커밋, 1,054개 blob(텍스트 958, 바이너리 96)을 다시 검사했다. 대상 전화번호·로컬 홈 경로·제외 경로는 발견되지 않았다.
- 초기 텍스트 검사와 별도로 과거 화면 이미지 34개를 로컬 OCR로 검사했다. 같은 이미지의 GPS/작성자/사용자 주석 메타데이터 후보도 없었다. 이미지 전체에 대한 완전한 개인정보 부재 증명은 아니다.
- 현재 운영 해시 키도 메모리에서 Git blob과 대조해 발견되지 않음을 확인했다. 실제 키·연락처·이미지 인식 원문은 이 문서에 기록하지 않는다.
- API migrations/운영 SQL, 원본 실험 결과, 개인 자료, 비밀 설정은 Git 제외 상태를 유지한다. 합성 Lab SQL과 공개 설정 예시는 보존한다.

## 운영 설정 검증

- 공용 GitHub 배포 토큰의 권한 수정 후 운영 API CI가 성공했다.
- 최초 해시 값은 일반 텍스트 변수였고 CI 재배포에서 제거됐다. 사용자 승인으로 같은 값을 암호화된 Worker Secret으로 전환했다.
- 전환 후 CI 재배포에서도 Secret이 유지되며, 실제 등록 요청 200과 같은 클라이언트의 반복 등록에서 합계 유지, Secure/HttpOnly/SameSite=Lax를 확인했다. QA 방문은 실제 집계에 포함된다.
- Pages 해제와 repository rename은 Cloudflare Worker/D1/R2 변경이 아니다. 기존 운영 URL, Preview Access, 이미지 URL을 보존한다.

## 남은 한계

이력 재작성과 force push만으로 GitHub의 과거 PR refs·캐시·외부 fork/clone까지
삭제됐다고 주장하지 않는다. GitHub 관리 refs와 캐시의 삭제는 소유자가
[GitHub Support 절차](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)를 진행해야 할 수 있다.
이전 clone에서 pull/push해 정리 전 이력을 다시 합치지 않는다.

과거 Firebase 클라이언트 설정의 API key는 일반 서버 비밀키와 구분했다.
실제 API 제한·Security Rules는 이 감사에서 조회하지 않았으며,
[Firebase 공식 기준](https://firebase.google.com/docs/projects/api-keys)에 따른 제한 확인이 필요하다.
개발 도구 의존성 audit 경고와 실제 모바일 기기 검증은 이번 이력 정리로 해결된 항목이 아니다.

## 검증한 명령

독립 사본에서 Web content:check/lint/format:check/test(18)/typecheck/build와
API test(13)/typecheck가 통과했다. 저장소 주소를 바꾼 Go Load Lab은
`go test ./...`, `go test -race ./...`, `go vet ./...`가 통과했다.
측정 원본을 재실행하거나 수정하지 않았으며 공개 글은 0개다.
문서의 로컬 상대 링크도 확인했다.

## 같은 날 후속 정리

사용자는 PR·캐시 및 불필요한 설정 정리를 요청했고, 과거 Actions 실행 기록
94개도 로그 백업 후 삭제하도록 별도로 승인했다. 다운로드 가능한 로그는
비공개에 보존한 뒤 실행 기록 94개를 삭제했다(64개 백업, 30개는 이미 HTTP 410으로
만료). 현재 배포 검증 5개는 유지했고 CI 캐시 10개는 비웠다. 공개 Actions
산출물은 없었다. 구형 SONAR_TOKEN과 사용하지 않는 CLOUDFLARE_API_TOKEN은
GitHub Secrets에서 제거하고 현행 공용 토큰과 계정 ID는 유지했다.

과거 PR 참조·캐시·서버 객체 제거는 GitHub Support에 접수했다.
접수는 삭제 완료를 뜻하지 않으며 처리 결과를 기다린다. 상세 식별자·백업·
티켓 증거는 Git에서 제외된 비공개 기록에만 둔다. Pages는 꺼져 있지만
GitHub 자동 생성 workflow의 개별 disable 요청은 HTTP 422로 거부됐다.
직접 관리하는 Pages 설정·environment·소스 workflow는 없다.

의존성 정리는 별도 로컬 브랜치에서 진행한다. Web은 Vite 7 패치와 Wrangler,
API는 공식 후속 Workers Vitest 플러그인·Vitest 4·타입 패키지를 갱신했다.
일부 전이 의존성에는 같은 major의 보안 패치 override를 적용했다.
실행 코드는 변경하지 않았고, 새 플러그인의 파일별 D1 격리에 맞춰 테스트별
합성 테이블·실패 trigger 정리를 명시했다. 검증을 삭제하거나 비활성화하지 않았다.
이 변경의 push·배포는 이번 정리에 포함하지 않는다.

후속 검증에서는 양쪽 `npm ci`와 전체 `npm audit`가 경고 없이 통과했고
취약점 집계는 각각 0개다. Web content/lint/format/18 tests/typecheck/build,
API Node 26 및 비밀 설정 없는 독립 사본의 Node 22에서 13 tests/typecheck,
양쪽 Wrangler 4.152.0 dry-run이 통과했다. 운영 앱 자산 hash는 변경 전과 같고
운영 경로·보안 헤더·캐시와 Preview 웹/API Access 검사를 다시 통과했다.
로컬에 보존한 원본 결과·초안·비밀 설정 1,017개 파일의 hash도 같았다.
GitHub Support 처리 완료, 원격의 새 의존성 CI, 실제 기기 검증은 아직 아니다.
