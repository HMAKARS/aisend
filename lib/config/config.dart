import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱의 환경 설정과 민감한 정보를 관리하는 클래스
class AppConfig {
  /// API 기본 URL
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  /// 인증 관련 API URL
  static String get authBaseUrl => dotenv.env['AUTH_BASE_URL'] ?? 'http://10.0.2.2:8000/api/auth';

  /// 여행 코스 관련 API URL
  static String get tripsBaseUrl => dotenv.env['TRIPS_BASE_URL'] ?? 'http://10.0.2.2:8000/api/trips';

  /// 카카오맵 API 키
  static String get kakaoMapApiKey => dotenv.env['KAKAO_MAP_API_KEY'] ?? '';

  /// 구글맵 API 키
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// 기본 테스트 계정 이메일 (개발용)
  static String get defaultTestEmail => dotenv.env['DEFAULT_TEST_EMAIL'] ?? 'admin@example.com';

  /// 기본 테스트 계정 비밀번호 (개발용)
  static String get defaultTestPassword => dotenv.env['DEFAULT_TEST_PASSWORD'] ?? 'password';
  
  /// 로그인 엔드포인트
  static String get loginEndpoint => '$authBaseUrl/login/';
  
  /// 회원가입 엔드포인트
  static String get registerEndpoint => '$authBaseUrl/registration/';
  
  /// 로그아웃 엔드포인트
  static String get logoutEndpoint => '$authBaseUrl/logout/';
  
  /// 사용자 정보 엔드포인트
  static String get userInfoEndpoint => '$authBaseUrl/user/';
}
