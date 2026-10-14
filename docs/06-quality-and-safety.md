# Quality, CI & Safety

## 기본 검증 범위

### Web (`apps/web/`)

```bash
cd apps/web
npm ci
npm run lint
npm run format:check
npm test
npm run typecheck
npm run build
```

Node 버전은 `apps/web/.nvmrc`(26)과 일치시킨다. 명령의 원본은 `apps/web/package.json`이다. root 통합 npm 명령은 없다.

### Legacy API (`apps/legacy-api/`, CI Node 22)

```bash
cd apps/legacy-api
npm ci
npm test
npm run typecheck
```

API는 웹의 Node 버전을 강제하지 않는다. 다른 Node에서 검사하면 해당 결과와 CI Node 22 미검증 여부를 분리해 보고한다. 현재 API 테스트 1개는 DB 경로·운영 D1/R2를 검증하지 않는다.

### Go Lab (실제 소스 확보 후 해당 실험만)

```bash
cd labs/go-load-test
go test ./...
go test -race ./...  # race 분석이 가능한 플랫폼/설정에서
```

Go 소스가 실제 이관되기 전에는 위 명령을 실행할 수 없다. 수행하지 않은 검사에 '통과'를 표기하지 않는다.

## 최소 자동 검사(구현 단계에서 추가)

- Markdown frontmatter 필수 필드, 날짜 형식, 중복 slug, 초안 제외 확인
- 웹 라우트: `/`, `/portfolio/`, `/lab/`, `/writing/`, 글 상세 및 404/호환 route
- Portfolio 기존 경력/프로젝트 자료 회귀 검사
- 개인정보·토큰 커밋 방지(`.gitignore` + git diff 검토; 향후 필요 시 secret scan)
- 변경 경로별 CI 트리거: `apps/web/**` + `content/**` → Web QA/배포, `apps/legacy-api/**` → Backend QA/배포, `labs/**` → 대상 프로젝트 검증(웹 배포 없음)
- GitHub Actions에서는 PR에 배포하지 않는다. 기존 main=Production, develop=Preview 의미 유지.

## 수동 품질 점검

- 모바일/데스크톱, 라이트/다크, reduced motion, keyboard 접근성과 heading 순서
- Markdown의 코드 블록/긴 표/이미지 대체 텍스트/외부 링크
- 새 글 deep link 직접 접근과 브라우저 새로고침
- `?lang=en` UI에서 한국어 글만 있는 경우 언어 표시/폴백
- 기존 Cloudflare Access Preview 보호, `workers.dev`/preview URL 공개 범위
- Clarity 동의(동의 전 미로딩), R2 이미지, 리다이렉션/SEO 경로
- `apps/web/scripts/check-deployment.mjs` 사용 시 경로와 검사 주소를 실제 구성에 맞게 확인

## 콘텐츠 보안/개인정보

- [기존 공개 승인 원칙](archive/portfolio-renewal/05-privacy-and-content-policy.md)을 계승한다. 역사 문서의 이메일 전면 금지와 달리 이번 기능 보존 범위는 기존 공개 연락처를 그대로 유지한다. 새 주소 공개·원본 이력서 수입은 승인하지 않는다.
- 원본 이력서·전화번호·상세주소·생년월일·사내 비공개 자료·API 키·OAuth 토큰을 커밋하지 않는다.
- 개인 이메일은 기존 공개 포트폴리오와 테스트에 허용된 값은 보존하지만, **새 파일에 무심코 복제하지 않는다**.
- Public repo의 Markdown 초안과 커밋 이력은 사이트의 `draft` 설정과 무관하게 공개된다.
- Markdown 렌더러에서 raw HTML/스크립트 실행을 기본 차단하고 사용자 입력·URL을 안전하게 처리한다.
- Lab 실험 데이터가 사용자/회사 내부 정보를 포함하면 완전히 합성한 데이터로 재현한다.
- 댓글·회원 기능이 들어오기 전에는 신뢰되지 않은 방문자 데이터 저장 경로를 만들지 않는다.

## 에이전트 작업 계약

각 단계 완료 보고에 다음 네 항목이 반드시 있어야 한다.

```text
1. 변경: 파일 및 요약
2. 검증: 실행 명령과 결과(실행하지 못한 항목 포함)
3. 위험: 남은 문제, 운영 영향, 개인정보/비밀정보 점검
4. 다음: 다음 승인 게이트 또는 작업
```

검증 실패 시 성공이라고 요약하지 않고 원인과 복구 방법을 먼저 제시한다. CI 또는 문서 검증이 반복적으로 깨지는 규칙만 실행 가능한 검사로 승격한다.

## Phase 1의 배포 경계

이번 단계는 로컬 검증만 승인되었다. migration branch는 main/develop workflow push 대상이 아니고 PR은 배포하지 않는다. docs/templates/labs-only 변경은 앱 workflow 대상이 아니다. 구조 이전 전체를 main에 반영하면 두 앱과 두 workflow가 바뀌어 웹·API deploy가 모두 대상이 되므로, 실제 main 반영 전에 별도 배포 승인을 받는다. 배포 조건을 임의로 바꾸거나 테스트를 비활성화하지 않는다.
