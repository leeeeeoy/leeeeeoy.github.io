# Git 이력·실험 산출물 감사 — 2026-10-24

대상은 migration/phase1-monorepo의 fb147ac까지의 이력이다. 사용자가 결과 파일을 포함한 불필요한 추적 파일을 정리하도록 요청했고, 이후 **이 브랜치 과거 기록 재작성과 force push**를 선택했다. main/develop과 다른 브랜치·태그는 변경하지 않는다.

## 감사 범위와 결과

- 도달 가능한 커밋 127개, blob 1,259개를 열거했다. 그중 UTF-8 텍스트 1,156개에서 개인키·GitHub/AWS/Slack 토큰·실제 Slack webhook·JWT 형태·자격증명 리터럴·로컬 홈 경로를 검사했다. 전용 secret scanner가 아닌 패턴/소스 검토이며 유출이 없다는 완전한 증명은 아니다. 바이너리 103개는 텍스트/OCR 검사 대상이 아니다.
- GitHub/AWS/Slack 토큰·개인키 패턴은 발견하지 못했다. 과거 Flutter firebase_options.dart의 API key 형태는 Firebase 클라이언트 설정으로 분류했다. 실제 키의 사용 가능 여부·API 제한·Security Rules는 조회하지 않았다. 이 값은 일반 서버 비밀키와 다르며 제한 설정이 필요하다. [Firebase 공식 설명](https://firebase.google.com/docs/projects/api-keys)
- 과거 .claude/settings.local.json은 도구 허용 명령과 로컬 홈 경로, .wrangler/cache/wrangler-account.json은 계정 id/name 캐시였다. 조사한 값에 토큰 패턴은 없었으며 최신 트리에서는 이미 제거돼 있다. 이 브랜치 이력에서는 제외하되, 같은 기록이 main/develop에도 남으므로 저장소 전체에서 제거됐다고 주장하지 않는다.
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

검증한 독립 복제본에서 git-filter-repo v2.47.0으로 다음 경로만 제외한다.

```sh
python3 <temporary-tool>/git-filter-repo \
  --path-regex '^labs/.*/results/' \
  --path .claude/ --path .wrangler/ --invert-paths
```

재작성 전후의 최신 추적 트리가 같음을 확인한 뒤 원본 작업 디렉터리의 브랜치 ref만 연결한다. 로컬 결과를 지울 수 있는 hard reset/clean은 사용하지 않는다. 원격 갱신은 개인 계정 leeeeeoy와 원래 원격 HEAD를 지정한 force-with-lease로 이 브랜치에만 적용한다.

## 범위와 주의

이력 재작성은 커밋 해시·일부 커밋의 도달 관계를 바꾼다. main/develop의 공유 과거는 그대로이므로 이후 병합 때 단순 fast-forward를 가정하지 않는다. 다른 컴퓨터의 옛 브랜치를 그대로 push하면 제거한 기록이 되살아날 수 있다. 먼저 미반영 작업을 별도 보존하고 새 원격 이력을 기준으로 동기화해야 한다. [GitHub의 이력 재작성 설명](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

다른 브랜치·태그·PR 참조·GitHub 캐시·기존 clone/백업까지 소급 삭제하지 않는다. 과거 파일이 인터넷 전체에서 완전히 사라졌다는 의미가 아니다. 확인한 실제 인증 비밀은 없어 키 회전·운영 설정 변경은 수행하지 않는다.

## 검증 상태

독립 복제본에서 제거 경로의 전체 이력 부재·소스 보존·문서 경로·결과 없는 checkout의 검사/빌드를 확인한 후 최종 상태를 기록한다. 실험 재측정·배포·main/develop 병합은 범위 밖이다.
