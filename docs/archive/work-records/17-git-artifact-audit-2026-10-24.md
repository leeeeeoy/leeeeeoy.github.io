# Git 이력·실험 산출물 감사 — 2026-10-24

대상은 migration/phase1-monorepo의 fb147ac까지의 이력이다. 사용자가 결과 파일을 포함한 불필요한 추적 파일을 정리하도록 요청했고, 이후 **이 브랜치 과거 기록 재작성과 force push**를 선택했다. main/develop과 다른 브랜치·태그는 변경하지 않는다.

## 감사 범위와 결과

- 도달 가능한 커밋 127개, blob 1,259개를 열거했다. 그중 UTF-8 텍스트 1,156개에서 개인키·GitHub/AWS/Slack 토큰·실제 Slack webhook·JWT 형태·자격증명 리터럴·로컬 홈 경로를 검사했다. 전용 secret scanner가 아닌 패턴/소스 검토이며 유출이 없다는 완전한 증명은 아니다. 바이너리 103개는 텍스트/OCR 검사 대상이 아니다.
- GitHub/AWS/Slack 토큰·개인키 패턴은 발견하지 못했다. 과거 Flutter firebase_options.dart의 API key 형태는 Firebase 클라이언트 설정으로 분류했다. 실제 키의 사용 가능 여부·API 제한·Security Rules는 조회하지 않았다. 이 값은 일반 서버 비밀키와 다르며 제한 설정이 필요하다. [Firebase 공식 설명](https://firebase.google.com/docs/projects/api-keys)
- 과거 .claude/settings.local.json은 도구 허용 명령과 로컬 홈 경로, .wrangler/cache/wrangler-account.json은 계정 id/name 캐시였다. 조사한 값에 토큰 패턴은 없었으며 최신 트리에서는 이미 제거돼 있다. 이 브랜치 이력에서는 제외하되, 같은 기록이 main/develop에도 남으므로 저장소 전체에서 제거됐다고 주장하지 않는다.
- 과거 Flutter 소스와 이전 작업 문서에도 로컬 절대 경로가 있었다. 최신 추적 파일에서는 해당 홈 경로가 없음을 확인했다. 과거 소스 본문까지 광범위하게 치환하지 않았으므로 이력을 완전히 비식별화했다는 의미는 아니다.
- 현재 추적된 results는 아래 706개/5,647,002 bytes(약 5.39MiB)다. 실행 로그·원본 JSON/JSONL·DB dump·중복 소스 사본·정리 상태 등이 포함된다. 재현 코드/README/계획/분석·연구 기록은 유지한다.

| 경로 | 현재 추적 파일 | 처리 |
|---|---:|---|
| labs/booking-compensation/results/ | 698 | 로컬 보존, 최신 트리 및 이 브랜치 과거 이력에서 제외 |
| labs/concurrency-integrity/results/ | 8 | 동일 |
| labs/go-load-test/results/ | 0 | 기존 보류 상태 유지, 모든 향후 결과까지 root ignore 적용 |
| .claude/, .wrangler/ | 최신 0 | 이 브랜치 과거의 로컬 설정/캐시만 제외 |
| .env.example·lockfile·SQL schema/fixture | 정상 소스/예시 | 유지 |
| 과거 Flutter 폰트·스크린샷 | 역사적 사이트 자산 | 유지. 불필요한 현재 실행 결과와 구분 |

기록 blob 총 비압축 크기는 약 56.24MiB였다. 큰 파일은 과거 Flutter 폰트(각 약 5.9MiB)와 스크린샷이었다. results 제거가 전체 저장소 크기를 크게 줄이거나 다른 브랜치의 옛 자산까지 지운다는 뜻은 아니다.

## 보존과 정리 방법

정리 전 이 브랜치의 완전한 복구용 Git bundle과 추적 결과의 tar 백업을 저장소 밖에 만들고 검증했다. 결과 파일 1,014개(기존 비추적 Go Load Lab 자료 포함)의 내용 hash를 보존했다. 파일은 원래 로컬 위치에 그대로 두며 측정 원본을 재실행값으로 대체하거나 수정하지 않는다. 백업의 실제 위치와 commit-map은 로컬 작업 기록에만 둔다.

루트 ignore는 모든 labs/**/results/를 제외한다. 예전 특정 날짜 ignore와 로그 재포함 예외는 정리했다. results를 가리키던 Markdown 링크는 원격 파일처럼 보이지 않도록 명시적 로컬 경로로 바꿨다. 기존 분석·실패·검증 사실은 유지하고, 이전 기록의 커밋 ID는 재작성 전 식별자로 해석한다.

검증한 독립 복제본에서 git-filter-repo v2.47.0으로 다음 경로만 제외했다.

```sh
python3 <temporary-tool>/git-filter-repo \
  --path-regex '^labs/.*/results/' \
  --path .claude/ --path .wrangler/ --invert-paths
```

재작성 전후의 최신 추적 트리가 같음을 확인한 뒤 원본 작업 디렉터리의 브랜치 ref만 연결했다. 로컬 결과를 지울 수 있는 hard reset/clean은 사용하지 않았다. 원격 갱신은 개인 계정 leeeeeoy와 원래 원격 HEAD를 지정한 force-with-lease로 이 브랜치에만 적용한다.

## 범위와 주의

이력 재작성은 커밋 해시·일부 커밋의 도달 관계를 바꾼다. main/develop의 공유 과거는 그대로이므로 이후 병합 때 단순 fast-forward를 가정하지 않는다. 다른 컴퓨터의 옛 브랜치를 그대로 push하면 제거한 기록이 되살아날 수 있다. 먼저 미반영 작업을 별도 보존하고 새 원격 이력을 기준으로 동기화해야 한다. [GitHub의 이력 재작성 설명](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

다른 브랜치·태그·PR 참조·GitHub 캐시·기존 clone/백업까지 소급 삭제하지 않는다. 과거 파일이 인터넷 전체에서 완전히 사라졌다는 의미가 아니다. 확인한 실제 인증 비밀은 없어 키 회전·운영 설정 변경은 수행하지 않는다.

## 검증 상태

- 기존 127개 커밋과 정리 커밋 1개를 재작성했다. 128개 모두 대응하며 빈 커밋 제거는 없었다. 각 대응 커밋의 전체 트리를 비교해, 제외 경로 외의 파일 경로·mode·blob이 모두 같음을 확인했다. 역사적으로 제거한 고유 파일 경로는 results 706개와 로컬 메타데이터 2개로 총 708개다. 이후 이 검증 기록만 별도 문서 커밋으로 남긴다.
- 재작성 직전·직후 최신 트리 hash가 일치했다. 원본 디렉터리의 결과 1,014개도 SHA-256이 모두 같고, main/develop 및 나머지 브랜치·태그는 유지했다. 복구 bundle·결과 tar·commit-map·검사 로그는 Git에서 제외하는 로컬 비공개 백업에 보관했다.
- results 폴더가 전혀 없는 독립 복제본에서 검사했다. npm 의존성은 기존 로컬 설치본을 재사용했으며 새 npm ci는 실행하지 않았다. 수정 문서의 상대 파일 링크 68개가 존재함을 확인했다. 로컬 결과 참조는 링크가 아닌 설명으로 남겼다.

| 검사 | 실제 결과 |
|---|---|
| Web Node 26.9.0 | content:check, lint, format:check, test 15개, typecheck, build 통과. 공개 글 0개 |
| Legacy API | test 1개, typecheck 통과. 로컬 Node 26이며 CI Node 22는 이번에 실행하지 않음 |
| booking-api | go test / race / vet 통과. 전용 로컬 DB의 격리 schema에서 트랜잭션 경계 3개 하위 검사도 실행 |
| schedule-api | go test / race / vet 통과 |
| Go Load Lab·concurrency-integrity | 각 go test / race 통과. concurrency-integrity의 integration build tag는 실행하지 않음 |
| Python | Go Load Lab 집계 스크립트 3개, 외부 의존성 stub 4개 테스트 통과 |
| CI 정적 검토 | 앱 workflow는 main/develop push 대상이며 migration 브랜치는 대상이 아님. workflow 내용 변경 없음 |

브라우저·운영 사이트·Cloudflare Access·새 의존성 설치·전체 Docker 시나리오·P0 DB 실험은 이번에 재검증하지 않았다. 기존 부하 측정·실패 결과를 재실행하거나 검증 범위를 확대하지 않았다. 배포·PR 생성·main/develop 병합은 하지 않는다.

## 같은 날 후속 정리 — main 기준 rebase

사용자가 브랜치 정렬을 요청해 최신 origin/main(0d549c8)을 공통 기반으로 삼았다. migration 추가 커밋 18개 중 이미 main에 반영된 포트폴리오 수정 1개는 파일 내용 일치를 확인해 제외하고 17개를 다시 적용했다. 첫 구조 이전 커밋에는 main에서 상속한 로컬 도구 메타데이터 2개의 추적 해제를 포함했다. 이 기록 보완 전 최종 트리는 rebase 전과 정확히 같았다.

**앞선 전체 이력 필터링의 범위와 구분한다.** main 이력을 변경하지 않고 그 위로 rebase했으므로, main의 공통 과거에 있는 .claude/.wrangler 메타데이터는 migration에서도 다시 도달 가능하다. 최신 트리에서는 제외하며 results는 여전히 migration 전체 이력에서 제외한다. main까지 정리했다거나 저장소 전체에서 삭제됐다는 의미가 아니다.

main에 모두 반영된 로컬 feat/bilingual-portfolio와 release/portfolio-copy-20261020을 삭제하고 로컬 main을 원격 main까지 fast-forward했다. release 작업 폴더는 삭제하지 않고 detached HEAD로 보존했다. develop은 main의 조상이며 Preview용 상시 브랜치로 유지했다. 새 백업 bundle과 range-diff는 로컬 비공개 경로에 보관했다.

동일한 파일 트리의 독립 복제본에서 Web의 content/lint/format/test 15개/typecheck/build, Legacy API test 1개/typecheck, 네 Go 모듈의 test/race/vet를 다시 실행해 통과했다. booking-api의 전용 로컬 DB 트랜잭션 검사도 실행했다. 기존의 브라우저·CI Node 22·운영·실험 재측정 미검증 범위는 유지한다. 원격 갱신 대상은 migration만이며 main/develop push나 배포를 포함하지 않는다.
