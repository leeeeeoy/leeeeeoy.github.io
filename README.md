# leeeeeoy Portfolio

개인 포트폴리오 웹사이트 — Flutter Web으로 제작된 프론트엔드와 Cloudflare 인프라 기반의 백엔드로 구성되어 있습니다.

**URL:** https://portfolio.leeeeeoy.xyz

---

## 프로젝트 구조

```
leeeeeoy_portfolio/
├── frontend/          # Flutter Web 앱
├── backend/           # Cloudflare Workers API (Hono + TypeScript)
└── .github/workflows/ # CI/CD (GitHub Actions)
```

---

## Frontend

**Flutter Web** (`frontend/`)

| 항목 | 내용 |
|------|------|
| Framework | Flutter 3.41 / Dart SDK ^3.11 |
| 상태관리 | flutter_bloc |
| 라우팅 | go_router |
| DI | get_it + injectable |
| 네트워크 | dio + talker_dio_logger |
| 코드 생성 | freezed, json_serializable, flutter_gen |
| Firebase | Analytics, Crashlytics, Performance, Messaging |
| 로컬 저장소 | hive_flutter |
| 배포 | Cloudflare Pages |

### 주요 화면 구조

```
lib/
├── feature/
│   ├── home/      # 메인 홈 화면
│   ├── profile/   # 프로필 섹션
│   ├── main/      # 레이아웃 진입점
│   └── common/    # 공통 위젯 / BLoC
├── data/          # API 레이어 (dio)
├── di/            # 의존성 주입 설정
├── router/        # go_router 라우트 정의
├── config/        # 환경 설정
├── resource/      # 색상, 텍스트 스타일 등 리소스
└── util/          # 유틸리티
```

### 로컬 실행

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 빌드

```bash
flutter build web --release
```

---

## Backend

**Cloudflare Workers + Hono** (`backend/`)

| 항목 | 내용 |
|------|------|
| Runtime | Cloudflare Workers |
| Framework | Hono ^4.6 |
| 언어 | TypeScript 5.5 |
| DB | Cloudflare D1 (SQLite) |
| Storage | Cloudflare R2 (정적 에셋) |
| 배포 도구 | Wrangler 4 |

### API 엔드포인트

| Method | Path | 설명 |
|--------|------|------|
| GET | `/` | 헬스 체크 |
| GET | `/api/profile` | 프로필 정보 |
| GET | `/api/careers` | 경력 사항 |
| GET | `/api/projects` | 프로젝트 목록 |
| GET | `/api/skills` | 기술 스택 |

### 로컬 실행

```bash
cd backend
npm install
npm run dev
```

### 배포

```bash
npm run deploy
```

---

## CI/CD

GitHub Actions를 통해 `main` 브랜치 푸시 시 변경된 영역(frontend / backend)만 자동 배포됩니다.

| 워크플로우 | 트리거 조건 | 배포 대상 |
|-----------|-----------|----------|
| `frontend.yml` | `frontend/**` 변경 | Cloudflare Pages |
| `backend.yml` | `backend/**` 변경 | Cloudflare Workers |

### 필요한 GitHub Secrets

| Secret | 용도 |
|--------|------|
| `CLOUDFLARE_API_TOKEN` | Cloudflare 배포 인증 |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare 계정 식별 (Pages 배포) |

---

## 인프라 구성

```
                    ┌─────────────────────────────┐
                    │         Cloudflare           │
  사용자  ──────▶  │  Pages (Flutter Web)         │
                    │  Workers (Hono API)          │
                    │  D1 (Database)               │
                    │  R2 (Assets)                 │
                    └─────────────────────────────┘
                                  ▲
                    ┌─────────────┴────────────┐
                    │      GitHub Actions        │
                    │  frontend.yml / backend.yml│
                    └──────────────────────────┘
```

- **Cloudflare Pages** — Flutter Web 빌드 결과물 (`build/web`) 호스팅
- **Cloudflare Workers** — Edge에서 실행되는 서버리스 API
- **Cloudflare D1** — Workers와 연결된 서버리스 SQLite DB (`leeeeeoy-portfolio`)
- **Cloudflare R2** — 이미지 등 정적 에셋 저장소 (`leeeeeoy-portfolio-assets`, base URL: `https://assets.leeeeeoy.xyz`)
- **Firebase** — 분석(Analytics), 오류 추적(Crashlytics), 성능 모니터링(Performance)
