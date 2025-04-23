# aisend - 여행 코스 공유 앱

플러터로 개발된 여행 코스 공유 및 검색 애플리케이션입니다.

## 시작하기

### 환경 설정

1. 프로젝트를 클론합니다.
```
git clone https://github.com/yourusername/aisend_app.git
cd aisend_app
```

2. 의존성 패키지를 설치합니다.
```
flutter pub get
```

3. 환경 변수 설정하기
   - `.env.example` 파일을 `.env` 파일로 복사합니다.
   ```
   cp .env.example .env
   ```
   - `.env` 파일을 열고 필요한 API 키와 환경 변수를 설정합니다.
   ```
   # API URLs
   API_BASE_URL=https://your-api-url.com
   AUTH_BASE_URL=https://your-api-url.com/auth
   TRIPS_BASE_URL=https://your-api-url.com/trips

   # API Keys
   KAKAO_MAP_API_KEY=your_kakao_map_api_key_here
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

   # Default Login (for development only)
   DEFAULT_TEST_EMAIL=test@example.com
   DEFAULT_TEST_PASSWORD=password
   ```

4. 애플리케이션 실행하기
```
flutter run
```

## 주요 기능

- 여행 코스 검색 및 필터링
- 지도에서 여행지 확인
- 사용자 프로필 관리
- 여행 코스 상세 정보 보기

## 보안 설정

이 프로젝트에서는 API 키와 같은 민감한 정보를 `.env` 파일에 저장하고, 이를 `flutter_dotenv` 패키지를 통해 관리합니다. `.env` 파일은 버전 관리 시스템에 포함되지 않으므로, 프로젝트를 빌드하기 전에 해당 파일을 적절히 설정해야 합니다.

## 개발 참고사항

- Flutter 3.7.0 이상 버전을 사용합니다.
- 지도 기능을 위해서는 카카오맵 API 키가 필요합니다.
