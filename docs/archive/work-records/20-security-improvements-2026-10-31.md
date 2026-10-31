# 보안 점검 후 개선과 검증 — 2026-10-31

사용자는 이전 문서·하네스 변경의 커밋과, 점검 결과의 개선 우선순위별 수정·검증·커밋을 승인했다. 기준은 [19번 부분 소스 감사](19-harness-security-review-2026-10-31.md)다. 공개 경력 문구·초안·실험 원본은 수정하지 않았다. push·Production/Preview 배포·원격 SQL·Worker/GitHub Secret·원격 보호 규칙 변경은 실행하지 않았다.

## 적용한 변경

| 순서 | 변경 | 커밋 |
| --- | --- | --- |
| 준비 | 문서 진입·작업별 검증·문서 검사 및 CI | `f779819` |
| 1 | 방문 API의 DB 이전 요청 제한, HMAC key 1회 import, 만료 정리 최대 128행 | `13f9667` |
| 2 | Web 개발 도구 minimatch 11.0.1 제한 override | `50c38cc` |
| 3 | Actions 12곳 SHA 고정, checkout 인증 정보 저장 해제 | `364857a` |
| 3 | base/form/inline event 속성 CSP 제한과 HTTP 검사 | `cfccc9f` |
| 4 | 독립 Lab 기본 loopback·명시적 container bind·HTTP proxy 우회 | `c4c9dc6` |

API의 요청 제한은 GET/POST가 공유하는 600회/60초/Cloudflare location의 초기값이다. 식별자를 rate key로 사용하지 않고 DELETE 동의 철회는 제한을 우회한다. 오류 시 503, 초과 시 429/Retry-After를 반환하며 먼저 D1·암호화·쿠키 작업을 실행하지 않는다. 전역 비용 상한은 아니며 합계 SQL은 daily table을 계속 읽는다. [API 계약과 릴리스 전 확인](../../../apps/api/README.md)을 따른다.

현재 npm 조회는 Web의 개발 도구 경로에서 [GHSA-g3hv-75wg-m249](https://github.com/advisories/GHSA-g3hv-75wg-m249) 1건이 12개 moderate dependency 항목으로 전파된 것을 확인했다. 공격자가 제공하는 특정 glob 최적화 경로의 실제 도달이나 배포된 브라우저 코드의 악용은 입증하지 않았다. 최소 override는 상위 선언 범위를 넘으므로 실제 lint 호환성을 검사했다. 상세 유지 기준은 [품질 문서](../../guides/06-quality-and-safety.md)에 있다.

## 실행한 검증

- API: 실제 로컬 D1 포함 17개 테스트와 typecheck 통과. 커밋된 추적 파일만 복사한 별도 사본에서도 `.dev.vars` 없이 17개 테스트가 통과했다. 새 4개 회귀 검사는 수정 전 4개 실패, 수정 후 통과했다. 제한 시 DB 무접근·쿠키 부재, 삭제 허용, 독립 HMAC 고정값, 만료 300행 중 128행 정리, 기존 동시성·롤백·시간/동의 경계를 확인했다.
- API Wrangler: production/Preview dry-run과 types 생성으로 두 환경의 native rate-limit binding 구성을 확인했다. Preview R2 누락 경고는 기존 read-only/미공개 R2 정책이며 binding을 추가하지 않았다. dry-run은 원격 설정 적용·namespace 충돌 부재를 증명하지 않는다.
- Web: 새 lockfile로 `npm ci`, content check, lint, format, 18개 테스트, typecheck/build 통과. 패치 후 공개 npm audit 0건. API lockfile도 조회 당시 0건이다. 권고 조회는 소스 감사나 취약점 부재 보증이 아니다.
- CI: YAML parser로 3개 workflow, Action 12곳의 40자리 SHA, `contents: read`, checkout credential 저장 해제, deploy-only Secret 및 push 조건을 확인했다. 호스팅 Actions 실행 결과는 없다.
- CSP: 로컬 Wrangler Static Assets에서 12개 페이지 응답, 보안 헤더·캐시 및 2개 자산 해시 검사를 통과했다. 브라우저 연결 host 부재와 native Chrome 도구 timeout으로 실제 browser CSP 차단/dialog·Clarity 검사는 완료하지 못했다.
- Lab: 두 Go module의 `go test -race -count=1 ./...`와 `go vet ./...` 통과. booking은 24개, schedule은 23개 pass event(하위 case 포함), booking의 명시적 DB integration 1개 skip이다. Python 더블 테스트 5개 통과. 프록시를 실제로 타는 positive control, 직접 요청·redirect 거절을 확인했다.
- Lab 회귀 주입: 별도 사본의 proxy 차단 제거와 wildcard 기본값 복원 모두 새 테스트에서 실패했다. 원본 소스에 mutation을 적용하지 않았다.
- Lab 컨테이너: 새 Compose project·새 합성 볼륨·임의 host loopback 포트·내부 네트워크로 두 API와 PG/Slack 더블 4개 health가 통과했다. 원래 이미지 tag가 유지됐고 임시 컨테이너·볼륨·이미지는 정리했다. Compose의 host publish 6개는 loopback을 유지한다. 기존 실험 DB·결과를 재사용하거나 재현 성능 수치를 갱신하지 않았다.

## 원격 읽기에서 확인한 범위

Wrangler 로그인은 로컬 OAuth이며 CI 배포 Secret의 인증과 다르다. D1 info는 기존 production DB 메타데이터 조회만 수행했다. GitHub의 active main ruleset은 삭제·비선형 이력·강제 갱신을 제한한다. 별도 branch-protection 조회는 연결 앱의 권한 부족으로 403이었다. 이 ruleset만으로 required checks의 유무나 CI token scope를 단정하지 않는다.

## 남은 우선순위와 릴리스 경계

1. 승인된 다음 릴리스 전에 production/Preview rate namespace의 account 내 충돌 여부, CI 배포 토큰의 account/zone·최소 권한과 required checks를 확인한다. 공유 토큰을 유지한 기존 결정을 임의로 바꾸지 않았다.
2. 별도 Preview에서 실제 browser CSP·구조 dialog·동의/Clarity·CF cookie/header/Access 동작을 확인한다. 이번 로컬 Node는 26.9.0이며 API CI Node 22 실행은 미검증이다.
3. 배포 이후 D1 rows read/write·storage·429·정상 사용자 영향을 관측해 초기 threshold를 조정한다. 전역 비용 차단이 필요하면 scoped edge rule과 집계 전략을 검토한다.
4. 전체 예약 실험·DB storage integration·외부 서비스·운영 부하·복구 검증은 이번 네트워크 하드닝 결과에 포함하지 않는다. Web의 전체 script allowlist도 아직 적용하지 않았다.

이전 감사의 coverage ledger는 당시 부분 소스 검사의 기록으로 유지한다. 이번 수정과 회귀 검증을 근거로 전체 보안 coverage를 완료로 변경하지 않는다.
