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
