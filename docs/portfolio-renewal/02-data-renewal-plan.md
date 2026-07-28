# 데이터 개편 계획

## 데이터 원칙

1. 지원 기업별 문장보다 여러 이력서에 공통으로 존재하는 사실을 우선한다.
2. 수치는 측정 기준과 시점을 확인할 수 있을 때만 사용한다.
3. 한 bullet은 `문제 → 행동 → 결과` 중 최소 두 요소를 포함한다.
4. 기술 이름만 나열하지 않고 어디에 사용했는지 연결한다.
5. 공개할 필요가 없는 개인정보와 내부 운영 정보는 넣지 않는다.

## 권장 콘텐츠 구조

정적 전환 시 아래 정도면 충분하다. CMS용 범용 스키마는 만들지 않는다.

```ts
type Metric = {
  label: string
  value: string
}

type Experience = {
  company: string
  role: string
  period: string
  summary: string
  metrics: Metric[]
  highlights: string[]
  skills: string[]
}

type Project = {
  title: string
  summary: string
  metrics: Metric[]
  highlights: string[]
  skills: string[]
  images: string[]
  links?: {
    github?: string
    store?: string
  }
}
```

현재 D1의 모든 컬럼을 그대로 복제하지 않는다. UI가 실제 사용하는 공개 정보만 옮긴다.

## 소개 영역

### 메시지 순서

1. Flutter 기반 모바일 서비스를 운영해 온 엔지니어
2. 레거시 분석과 팀 규모에 맞는 구조 개선
3. 운영 지표 기반 성능·안정성 개선
4. 모바일 경계를 넘어 웹·백엔드·배포까지 해결

### 첫 화면 지표 후보

- 경력: 4년 7개월 또는 표시 시점에 계산된 값
- 최대 운영 서비스: 다운로드 100,000+
- 메모리 사용량: 약 20% 감소
- OOM 발생: 약 90% 감소

경력 연차는 하드코딩된 “5년 차”보다 시작일에서 계산하거나 연도 중심으로 표현한다.

## 경력 정리

### 현재 회사

한 개의 Experience로 통합한다.

- 1인 모바일 개발 환경에서 아키텍처, 기능, 배포, 운영 담당
- 예약 데이터의 Source of Truth 재정의와 다중 채널 통합
- 테스트·Quality Gate·E2E 구축
- Android·iOS 빌드와 코드사이닝 자동화
- Native/WebView 기반 카메라·인증·결제 연동
- 공개가 허용된다면 React 예약 웹과 백엔드 API 기여

서로 다른 구현 단계인 HRV 항목은 최종 흐름을 확인한 후 하나의 문제 해결 사례로 합친다.

### 비상장 주식 서비스

- 인수인계 없는 코드베이스 분석
- GetX 전역 생명주기 문제 정의
- Bloc 기반 점진적 전환
- 메모리 약 20% 감소
- WebSocket 재연결과 앱 생명주기 복귀 처리
- Native SDK와 WebView 비동기 결과 연동

### 아파트 관리 서비스

- 모바일 앱 초기 구조와 주요 인증·결제·투표 흐름
- 시니어 퇴사 후 모바일·웹 기술 의사결정
- Flutter Web 백오피스와 모바일 웹
- Firebase 모니터링 및 Slack 운영 알림

## 프로젝트 정리

### Featured

1. 반려견 숏폼 서비스
   - 실제 운영 규모
   - OOM 약 90%, 메모리 약 30% 개선
   - 모바일 영상 전처리

2. Tickie
   - Swift Live Activity 라이브러리
   - MethodChannel 인터페이스
   - Flutter에서 시작·갱신·종료 제어

3. Cafein
   - 등록 카페 2,500+
   - 누적 사용자 1,000+
   - 지도 위치 추적과 debounce

### Archive

- BPP는 최신 이력서에서 핵심 사례로 사용되지 않는다.
- 삭제할 필요가 있다면 DB 백업 후 메인 화면에서만 제외한다.

## 스킬 정리

퍼센트 대신 근거가 있는 그룹으로 표현한다.

### Core

- Flutter, Dart
- Bloc
- Android, iOS

### Platform integration

- Kotlin, Swift
- MethodChannel, WebView
- WebSocket

### Quality and operations

- GitHub Actions, SonarQube
- Patrol, Fastlane
- Firebase, Datadog, Sentry

### Adjacent

- React, TypeScript
- Java/Spring, Node.js
- GraphQL, Supabase

Adjacent 항목은 실제 공개 가능한 작업과 연결할 수 있을 때만 추가한다.

## 데이터 적용 전략

새 FE의 공개 콘텐츠는 TypeScript 또는 JSON 한 곳을 최종 원본으로 사용한다.
첫 화면에서 Worker API를 다시 요청하지 않아 로딩 상태와 네트워크 실패 지점을 없앤다.

단계별 적용:

1. 운영 D1은 건드리지 않고 새 정적 데이터로 콘텐츠를 확정한다.
2. React Preview에서 기존 API 데이터와 누락 여부를 비교한다.
3. Production 안정화 후 D1을 export해 보관한다.
4. Worker/D1에 남은 실제 사용처가 없을 때만 제거한다.

관리 화면, 외부 소비 API, 빈번한 콘텐츠 갱신 중 하나가 실제 요구가 되면 D1을 유지하거나
새 스키마로 다시 만든다. 현재는 DB 스키마를 먼저 고치는 작업을 하지 않는다.
