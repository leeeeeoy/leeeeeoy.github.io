# Phase 1 — 로컬 모노레포 구조 전환 기록

- 날짜: 2026-10-14
- 상태: 완료(로컬) / Phase 2 승인 대기
- 승인: 기존 GitHub repo·이력·origin 유지, 로컬 `leeeeeoy/` 루트 전환, 구조·문서·CI 경로만 수정.
- 금지: push, main/develop 변경, Production/Preview 배포, Cloudflare/GitHub 리소스 변경, 새 UI/Markdown/Lab 구현.

## 1. 변경 범위

```text
leeeeeoy/
├── .git/                       # 기존 이력에서 복원한 Git, migration branch
├── .github/workflows/          # 기존 두 workflow, 경로 수정
├── apps/web/                   # 기존 frontend 전체
├── apps/legacy-api/            # 기존 backend 전체
├── content/lab/.gitkeep
├── content/writing/.gitkeep
├── labs/.gitkeep
├── docs/
│   ├── archive/portfolio-renewal/ # 기존 6개 문서 + agent/readme 역사 기록
│   ├── archive/migration-proposal/00-READ-ME-FIRST.md
│   ├── exec-plans/active/site-migration.md
│   └── 00–10 상세 설계·감사·계획·현재 기록
├── templates/                  # 기존 3개 템플릿 그대로
├── .gitignore
├── AGENTS.md / CLAUDE.md / ARCHITECTURE.md
└── README.md
```

## 2. Git 전략과 보존 기준

원본의 전체 refs bundle을 만든 뒤 별도 작업본의 `.git`에 mirror 복원했다. 원본 `.git`을 승격하거나 새 이력을 init하지 않았다. 기존 로컬 Git config와 origin fetch 규칙을 유지하고 `origin/HEAD` symbolic ref를 복원했다. 일반 작업본에 `migration/phase1-monorepo`를 main에서 분기했다.

| 보존 대상 | 작업 전 값·검증 기준 |
|---|---|
| main | `dad0449c6350c4ba8f618cb4d03a52bcee42af6b` |
| develop | `500e95d1f79a17185e9af4d18c0bfdde4c47c707` |
| 기타 refs | feature branch, origin의 main/develop/gh-pages/HEAD, 기존 checkpoint 등 최초 8개 모두 SHA 대조 |
| main/develop 차이 | main만 1 commit, develop만 0 commit. 병합·재배치 없이 보존 |
| origin | `https://github.com/leeeeeoy/leeeeeoy.github.io.git`, 변경 없음 |
| 앱 파일 | 43개 추적 파일의 SHA-256이 이전 전과 일치 |

구조 이전은 로컬 `7405fd6` 커밋으로 기록했고 문서 통합을 별도 후속 커밋으로 기록한다. migration 커밋은 기존 main의 후속 로컬 이력으로만 추가한다. 기존 commit object·branch/ref를 삭제하거나 force push하지 않는다. 코드 파일·lockfile·테스트·Wrangler·public 자산 내용은 그대로다.

## 3. 백업과 복구

백업은 공개 저장소 밖 소유자 전용 디렉터리에 두었다.

`<local-home>/.local/share/leeeeeoy-migration-backups/phase1-20261014-202546`

- `original-all-refs.bundle`: 모든 refs가 도달하는 Git 객체. bundle verify 및 복원 fsck 검증.
- `original-checkout.tar`: Git metadata와 tracked/ignored/private 원본. 재생성 가능한 앱 node_modules/dist/일부 runtime cache는 archive에서 제외.
- `outer-documents.tar`: 이전 전 상위 지침·docs/templates 원문.
- `refs-before.txt`, `tracked-sha256.json`: 참조·파일 대조 기준.
- 최종 적용 뒤 `original-repository/`: 원래 중첩 repo 전체를 보존하는 위치. resume·DESIGN·SQL/query·로컬 설정은 이 원본에만 있고 새 공개 트리에 가져오지 않는다.

복구 순서: 모든 로컬 검증 프로세스를 종료하고 현재 모노레포를 다른 보존 경로에 둔다. 원래 `leeeeeoy/` 경로에 outer 문서 archive를 복원하고 `original-repository/`를 `leeeeeoy_portfolio/`로 복사한다. 기존 HEAD/refs/status와 bundle을 대조한다. 복구 중 원본·새 작업본을 삭제하거나 원격을 변경하지 않는다. 백업은 별도 확인 전 삭제하지 않는다.

## 4. 문서 통합과 판단

- 루트 AGENTS를 현행 공통 지침으로 사용하고 CLAUDE는 원문 그대로 추적한다. 현재 구조와 미래 UI를 분리한다.
- 기존 최소 구현·접근성·정적 Portfolio 데이터·Web Standard/Hono/SQL 원칙을 루트 AGENTS와 02/06에 계승한다.
- 당시 renewal 문서 6개는 본문을 유지하고 ARCHIVE/superseded 안내를 추가했다. legacy AGENTS는 `legacy-agents.md`로 두어 두 번째 활성 지침이 되지 않게 했다.
- 기존 README도 역사 자료로 보존했다. 그 안의 문서 링크 1개만 archive 상대 위치에 맞췄다. 전체 원본은 비공개 백업에도 있다.
- 00 패키지 안내는 archive로 이동하고 현재 탐색은 root README → docs 인덱스로 통합했다.
- 08 감사는 당시 관측 원문 그대로 유지했다. 09에는 이후 Phase 1 승인 기록을 추가했다. 01/04/06/active plan은 현재 경로·승인 범위로 갱신했다.
- 기존 공개 연락처 유지 요구를 개인정보 원칙의 좁은 예외로 명시했다. 주소를 새 문서에 복제하거나 새 연락처를 공개하지 않았다.
- Markdown 계약·새 라우트·Go 실험은 향후 제안이다. content/labs에는 placeholder만 있다.

## 5. CI 경로와 배포 조건

| 변경 종류 | 웹 workflow | API workflow |
|---|---|---|
| apps/web 또는 content/lab·writing | 대상 | 제외 |
| apps/legacy-api | 제외 | 대상 |
| 해당 앱 workflow | 해당 앱만 | 해당 앱만 |
| docs/templates/labs 또는 root 지침만 | 제외 | 제외 |
| 구조 이전 전체를 main에 반영 | 대상·Production 배포 | 대상·Production 배포 |
| 위 변경을 develop에 반영 | 대상·Preview 배포 | 검사만 |
| main/develop 대상 PR | 해당 검사만 | 해당 검사만 |
| migration branch에 push | 기존 branch 필터에서 제외 | 제외 |

`paths`, `working-directory`, Node 파일/lockfile 경로, Wrangler action의 workingDirectory만 새 위치로 변경했다. 웹 content 필터는 두 영역을 추가했다. 명령·Secrets 참조·Node 버전·needs/if·권한·Wrangler 버전은 유지했다.

기존 정책을 임의로 변경하지 않았다. 이번에는 push가 없으므로 실제 자동 배포도 없다. **향후 구조 이전의 main 반영은 웹/API 동반 배포를 유발할 수 있으므로 별도 승인 또는 제한 방침이 필요하다.** 이를 문서-only나 웹-only 변경과 혼동하지 않는다.

## 6. 수행한 검사

| 검사 | 결과·범위 |
|---|---|
| bundle verify, 복원 git fsck, refs/symref/origin | 통과; 기존 refs 8개 보존 |
| 앱 파일 hash 대조 | 43개 모두 동일; 불필요한 앱 내용 변경 없음 |
| Web fresh npm ci | 전환 작업본 apps/web에서 통과; 기존 package/lock 그대로, 최종 루트에서 QA 재실행 |
| Web lint / format:check | 통과 |
| Web npm test | 11/11 통과, 양언어 렌더·Notes·동의·테마·접근성 관련 기존 검사 유지 |
| Web typecheck / build | 최종 루트 통과; dist 10개 파일 hash가 기존 산출물과 일치 |
| API fresh npm ci / typecheck / npm test | 전환 작업본 설치 및 최종 루트 검사 통과, 1/1 테스트. 실행 Node 26.9.0; CI Node 22 재현은 미검증 |
| workflow YAML·전체 구조 비교 | 경로/웹 content 필터 외 변경 없음; 경로의 실제 존재 확인 |
| CI event/branch/path 시나리오 | 54 조합 통과. PR/migration branch 배포 없음, docs/Lab-only 앱 트리거 없음 |
| 문서 links/fences, git diff --check, 최종 루트 | 통과; 실제 Git 루트가 `<local-home>/leeeeeoy` |
| 로컬 Chrome | 한국어/영어·Notes·없는 글·새로고침·light/dark 및 저장·본문 focus·Notes→프로젝트 이동·R2 이미지 3개 로딩 확인, 관측한 console warn/error 없음 |
| Production/Preview | 이번에 배포·인증 검증하지 않음. Phase 0 HTTP 관측과 이번 로컬 결과를 구분 |

설치 시 기존 transitive package의 deprecation 및 npm install-script 경고가 있었다. 의존성을 바꾸거나 scripts 승인 정책을 변경하지 않았고 QA는 통과했다. 전체 공급망 감사로 해석하지 않는다.

## 7. 미검증 및 다음 단계

CI의 실제 GitHub runner 실행, Node 22 API 검사, 인증한 Preview/Access 정책·우회 경로, Cloudflare 관리 상태·배포 ID/Secrets/D1/R2, 전체 Git 역사 개인정보, Go 원본은 미검증이다. API 테스트는 root 정보 응답만 검사한다.

앱 소스·산출물·Git/CI·기존 브라우저 동작의 로컬 검증이 완료되어 Phase 2는 사용자 승인 후 로컬 구현으로 진입 가능하다. 운영 릴리스는 별도 승인·Preview 검증이 필요하다. 이번 Phase 1 종료 후 추가 기능이나 배포를 진행하지 않는다.

## 8. 남은 운영 위험

main/develop을 이 새 작업 폴더에서 checkout하면 그 브랜치가 가진 과거 frontend/backend 경로와 지침이 복원된다. 현재 migration branch를 유지하고 운영 branch 검토는 별도 worktree를 권장한다. 추적 제외한 로컬 metadata는 과거 Git 이력에는 남아 있다. 비공개 파일 공개 범위를 바꾸거나 이력을 정화하지 않았다. 실제 모바일·reduced-motion 상호작용 전체·생산 hostname에서의 Clarity 동의와 Access는 별도 검사 대상이다.
