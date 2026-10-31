# 보안 개선 릴리스 — 2026-10-31

사용자의 “배포까지 고고” 승인으로 [20번 개선 기록](20-security-improvements-2026-10-31.md)의 코드 `e876eddaa7d4b546886411dd667a653e458dfff8`를 main에 정상 push하고 Production Web/API를 기존 CI로 배포했다. 먼저 같은 코드의 기존 Preview Worker 두 개를 Wrangler로 배포했다. Secret·원격 SQL/스키마·GitHub 보호 규칙·Access 정책은 변경하지 않았다. 초안·실험 원본의 공개 보류를 유지했다.

## 활성 버전과 롤백 기준

| 대상 | 이번 활성 버전 (100%) | 직전 활성 버전 |
| --- | --- | --- |
| Production API | `13c12a7e-fc30-417f-8594-833cc7ba7835` | `26e88d55-3aee-4857-ad9f-3ac4dfd2faf2` |
| Production Web | `09a758d4-eba4-48fe-9079-8c994cfd891c` | `6a1841ff-6b2b-4a1e-9078-3f00f23a8146` |
| Preview API | `d5f9d6e8-0dd2-4717-bc2a-c0471281edda` | `19f587f3-da30-4dc7-9b66-ca16d62c094b` |
| Preview Web | `73ed9307-1c74-4b69-ac50-6d6555ed1a7f` | `9cece971-5161-42a1-a212-e5eb5b9071d8` |

배포 전후 버전·바인딩은 설치된 Wrangler 4.152.0으로 읽었다. API의 기존 D1/R2와 production `VISIT_HASH_SECRET`의 `secret_text` binding을 유지했다. Secret 값 자체는 조회하지 않았다. Worker 코드 rollback은 D1 데이터 rollback과 다르다. 이번 릴리스에 SQL migration은 없다.

## 배포 전 확인

- Wrangler가 인증한 기존 계정과 현재 운영/Preview 버전·런타임·binding을 확인했다. 원격 설정과 로컬 ENVIRONMENT·assets URL·DB·R2 구성을 대조했다.
- Wrangler에 account 전체 rate namespace 조회 명령이 없어 그 검사만 연결된 읽기 전용 API로 보완했다. 현재 계정 Worker 7개의 설정에서 새 `2026103101`/`2026103102` 사용이 없음을 확인했다. 이후 production/Preview API에 별도 namespace로 각각 배포됐다.
- Preview 웹과 `/api/visits`가 인증 없이 Cloudflare Access로 거절/리다이렉트되는 것을 HTTP로 확인했다. 보호를 해제하거나 bypass token을 만들지 않았다. 인증된 실제 Preview UI 검증은 미완료다.
- 최초 push는 현재 Git 인증 계정의 권한 부족으로 거절됐다. 기존 저장소 소유자 인증을 해당 명령의 credential helper에만 적용해 정상 push했다. 전역 활성 계정과 저장된 인증 정보는 변경하지 않았고 token을 출력/파일 저장하지 않았다.

## CI와 운영 검증

- [Backend CI](https://github.com/leeeeeoy/personal-space/actions/runs/41157998544): quality와 deploy 성공. Node **22.23.4**에서 테스트 **17/17** 및 typecheck 통과. 이전 Node 22 미검증은 이번 실행으로 보완됐다.
- [Frontend CI](https://github.com/leeeeeoy/personal-space/actions/runs/41157998512): quality와 deploy 성공. Node **26.13.0**에서 테스트 **18/18**, lint·format·build 통과.
- [Harness CI](https://github.com/leeeeeoy/personal-space/actions/runs/41157998514): 15개 maintained 문서 링크·6개 검사 테스트 통과.
- CI 로그의 Production Version ID가 배포 후 Wrangler 조회의 활성 ID와 일치한다. 공유 배포 token으로 Web/API가 실제 배포됐다는 증거이며 최소 권한 정책을 확인했다는 뜻은 아니다.
- `https://leeeeeoy.xyz`의 12개 페이지 응답에서 새 CSP·보안 헤더·cache, 현재 빌드 자산 2개의 SHA-256을 확인했다. 기존 portfolio/www 도메인은 각각 3개 경로·query의 canonical 301을 유지한다.
- 운영 API GET 200·정상 JSON·no-store·no-cookie, 동의 없는 POST/외부 Origin POST 403, DELETE 204·Secure/HttpOnly/SameSite=Lax/Max-Age=0, 공개 R2 OG 이미지 HEAD 200을 확인했다. 집계를 늘리는 등록 POST와 원격 SQL 쓰기는 실행하지 않았다.

## 남은 관측 경계

브라우저 연결 host가 없어 실제 browser CSP 차단·구조 dialog·Clarity 로딩과 인증된 Preview UI는 확인하지 못했다. 단위/HTTP/배포 메타데이터 검증으로 구분해 기록한다. 성공한 방문 등록의 실제 cookie·중복 집계 경로와 rate exhaustion은 운영에서 실험하지 않았다. 기존 로컬 D1 회귀 검증은 [20번 기록](20-security-improvements-2026-10-31.md)을 따른다.

지역별 근사 rate limit의 전역 비용 상한·실제 공격 차단 효과·정상 방문자 429 영향은 이번 smoke 결과로 보증하지 않는다. 최소 token scope·required checks 전체 확인, 배포 이후 D1 비용/거절률 관측, 전체 Lab DB integration은 후속 과제다. 기존 API observability 설정은 이번 릴리스에서 확대하지 않았다.
