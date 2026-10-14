# 문서 인덱스 — 필요한 것만 읽기

이 폴더를 설계·운영 지식의 원본으로 삼는다. 루트 `AGENTS.md`는 길게 설명하지 않고 이 문서로 안내한다.

| 하려는 작업 | 먼저 읽을 파일 |
|---|---|
| 사이트의 목적·범위 판단 | `00-vision-and-scope.md` |
| 현재 코드·옛 문서 정합성 파악 | [01-current-state.md](01-current-state.md), [Phase 0 감사](08-migration-audit-2026-10-14.md) |
| 경로·의존 관계·콘텐츠 구조 변경 | `02-target-architecture.md` |
| Lab·Writing 글 추가 또는 Markdown 파서 변경 | `03-content-and-writing.md` |
| 저장소 이전/리네임/CI 변경 | [04-migration-plan.md](04-migration-plan.md), [active plan](exec-plans/active/site-migration.md), [상세 실행 계획](09-migration-execution-plan-2026-10-14.md), [Phase 1 기록](10-phase1-migration-record-2026-10-14.md) |
| 기술 실험 코드·결과 | `05-lab-practices.md` |
| 테스트·프리뷰·보안·개인정보 | `06-quality-and-safety.md` |
| 이번에 구현할지 여부 논의 | `07-future-considerations.md` |

## 문서 유지 규칙

- **현재 코드가 기술적 사실의 원본**이다. 이전 상태 기술은 관측 시점과 경로를 표시한다.
- 변경된 의사결정은 이 파일의 대응 문서를 갱신하고 이전 문서에는 `superseded`를 표기한다.
- 실행 계획의 각 단계는 `완료 / 미완료 / 보류` 중 하나만 명시하고 검사 근거를 남긴다.
- 모든 작은 작업에 새 문서를 생성하지 않는다. 기존 문서 수정이 우선이다.
- [archive/portfolio-renewal](archive/portfolio-renewal/README.md)은 역사적 참고로 보존한다. 당시 Cloudflare **Pages** 계획은 현재 배포 기준이 아니다.

## 문서 상태

- 현행 경로·실행 명령: 루트 README/AGENTS/ARCHITECTURE와 01/04/06.
- Phase 0 감사 08은 당시 관측 기록이며 원문을 유지한다. 09는 실행안과 이후 승인 기록을 구분한다.
- 02/03의 신규 라우트·Markdown 계약, 07의 기능은 향후 제안으로 실제 구현과 구분한다.
- 최초 패키지 안내는 [archive/migration-proposal](archive/migration-proposal/00-READ-ME-FIRST.md)에 보존한다.

### 참고 외부 글

- OpenAI, *Harness engineering: leveraging Codex in an agent-first world*: https://openai.com/index/harness-engineering/

여기서 채택한 원칙은 작은 에이전트 진입점, 탐색 가능한 문서, 검증 가능한 변경, 정해진 중단 기준이다. 원문의 규모·자동화 수준을 무조건 복제하지 않는다.
