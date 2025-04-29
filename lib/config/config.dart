import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱의 환경 설정과 민감한 정보를 관리하는 클래스
class Config {
  /// API 기본 URL
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000'; // '/api' 제거

  /// 테스트 모드 (모의 데이터 사용)
  static bool get useMockData => true; // 모의 데이터 강제 사용

  /// 인증 관련 API URL
  static String get authBaseUrl => dotenv.env['AUTH_BASE_URL'] ?? 'http://10.0.2.2:8000/api/auth';

  /// 여행 코스 관련 API URL
  static String get tripsBaseUrl => dotenv.env['TRIPS_BASE_URL'] ?? 'http://10.0.2.2:8000/api/trips';
  
  /// 장소 관련 API URL
  static String get placesBaseUrl => dotenv.env['PLACES_BASE_URL'] ?? 'http://10.0.2.2:8000/api/places';

  /// 카카오맵 API 키
  static String get kakaoMapApiKey => dotenv.env['KAKAO_MAP_API_KEY'] ?? '';

  /// 카카오 REST API 키
  static String get kakaoRestApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  /// 카카오 NATIVE API 키
  static String get kakaoNativeApiKey => dotenv.env['KAKAO_NATIVE_API_KEY'] ?? '';


  ///  공공데이터 REST API 키
  static String get publicDataApiKey => dotenv.env['PUBLIC_DATA_API_KEY'] ?? '';

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
  
  /// 장소 검색 엔드포인트
  static String get placeSearchEndpoint => '$placesBaseUrl/search/';


}