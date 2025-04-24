# AISEND Backend

여행 계획 앱 "AISEND"의 백엔드 서버입니다.

## 기술 스택

- Django 5.2+
- Django REST Framework
- PostgreSQL (또는 SQLite)
- JWT 인증
- Docker (선택적)

## 구성 요소

- 사용자 관리 (회원가입, 로그인, 프로필 관리)
- 여행 코스 관리 (조회, 생성, 수정, 삭제)
- 관광 명소 관리
- 리뷰 시스템
- 추천 시스템 (날씨 기반, 테마 기반, 사용자 선호도 기반)

## 설치 및 실행 방법

### 필수 조건

- Python 3.10+
- pip
- virtualenv (선택적)

### 설치 단계

1. 저장소 클론

```bash
git clone https://github.com/yourusername/aisend_backend.git
cd aisend_backend
```

2. 가상 환경 생성 및 활성화

```bash
python -m venv venv
# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate
```

3. 필요한 패키지 설치

```bash
pip install -r requirements.txt
```

4. 환경 변수 설정

`.env.example` 파일을 복사하여 `.env` 파일 생성 후 적절한 값으로 수정해주세요.

```bash
cp .env.example .env
```

5. 데이터베이스 마이그레이션

```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

6. 관리자 계정 생성

```bash
python manage.py createsuperuser
```

7. 서버 실행

```bash
python manage.py runserver
```

이제 `http://localhost:8000/api/`에서 API에 접근할 수 있습니다.

## API 엔드포인트

### API 문서

- Swagger UI: `/api/swagger/`
- ReDoc: `/api/redoc/`
- Django REST 문서: `/api/docs/`

### 주요 엔드포인트

- 인증: `/api/auth/`
  - 로그인: `/api/auth/login/`
  - 로그아웃: `/api/auth/logout/`
  - 회원가입: `/api/users/register/`

- 사용자: `/api/users/`
  - 현재 사용자 정보: `/api/users/me/`
  - 사용자 정보 업데이트: `/api/users/me/update/`

- 여행 코스: `/api/trips/`
  - 여행 코스 목록: `/api/trips/`
  - 여행 코스 상세: `/api/trips/{id}/`
  - 내 여행 코스: `/api/trips/my_trips/`
  - 날씨 기반 추천: `/api/trips/weather_recommendations/`
  - 테마 기반 추천: `/api/trips/theme_recommendations/`
  - 인기 여행 코스: `/api/trips/popular/`

- 관광 명소: `/api/attractions/`
  - 근처 관광 명소: `/api/attractions/nearby/`

- 리뷰: `/api/reviews/`
  - 여행 코스 리뷰: `/api/reviews/?trip_id={trip_id}`
  - 내 리뷰: `/api/reviews/my_reviews/`

- 추천: `/api/recommendations/`
  - 맞춤형 추천: `/api/recommendations/personalized/`
  - 날씨 기반 추천: `/api/recommendations/weather/`
  - 즐겨찾기: `/api/recommendations/favorites/`
  - 사용자 선호도: `/api/recommendations/preferences/`

## 개발 가이드

### 디렉토리 구조

```
aisend_backend/
├── backend/
│   ├── aisend_backend/    # 프로젝트 설정
│   ├── users/             # 사용자 관리 앱
│   ├── trips/             # 여행 코스 관리 앱
│   ├── attractions/       # 관광 명소 관리 앱
│   ├── reviews/           # 리뷰 앱
│   ├── recommendations/   # 추천 시스템 앱
│   └── manage.py
├── requirements.txt
├── .env.example
└── README.md
```

### 모델 설계

- **사용자**: 확장된 Django 사용자 모델
- **여행 코스**: 제목, 설명, 위치, 기간, 타입, 날씨/테마 태그 등
- **관광 명소**: 이름, 설명, 위치(위도, 경도), 주소, 연락처, 운영 시간 등
- **여행 코스 상세**: 여행 코스와 관광 명소 간의 관계
- **리뷰**: 여행 코스에 대한 평점 및 리뷰
- **즐겨찾기**: 사용자가 저장한 여행 코스
- **사용자 선호도**: 추천 시스템을 위한 사용자 선호도 정보

## 테스트

```bash
python manage.py test
```

## 배포

### Docker를 이용한 배포

```bash
# Docker 이미지 빌드
docker build -t aisend-backend .

# Docker 컨테이너 실행
docker run -p 8000:8000 aisend-backend
```

### 프로덕션 환경 배포 체크리스트

- [ ] DEBUG 모드 비활성화
- [ ] 보안 SECRET_KEY 설정
- [ ] ALLOWED_HOSTS 설정
- [ ] HTTPS 설정
- [ ] PostgreSQL 데이터베이스 설정
- [ ] 정적 파일 서빙 설정
- [ ] 로깅 설정

## 라이선스

이 프로젝트는 MIT 라이선스에 따라 배포됩니다.
