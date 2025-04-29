import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/config.dart';

class AuthService {
  // 환경 변수에서 URL 가져오기
  final String baseUrl = Config.authBaseUrl;
  
  // 로그인
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Config.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,  // Django auth는 일반적으로 username 필드 사용
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 토큰 저장
        final token = data['key'] ?? data['access']; // dj-rest-auth는 'key' 필드를 사용
        await _saveToken(token);
        
        // 사용자 정보 가져오기
        final userInfo = await _getUserInfo(token);
        
        // 사용자 정보 저장
        await _saveUserData(userInfo);
        
        return userInfo;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['non_field_errors']?.first ?? 
                         errorData['detail'] ?? 
                         '로그인에 실패했습니다';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }
  
  // 사용자 정보 가져오기
  Future<User> _getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse(Config.userInfoEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',  // dj-rest-auth는 기본적으로 Token 인증 사용
        },
      );
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        
        // Django 사용자 모델과 Flutter 모델 간 필드 매핑
        return User(
          id: userData['id']?.toString() ?? '',
          name: userData['first_name'] ?? '',
          email: userData['email'] ?? '',
          profileImage: userData['profile_image'] ?? 'https://via.placeholder.com/150',
        );
      } else {
        throw Exception('사용자 정보를 가져오는데 실패했습니다');
      }
    } catch (e) {
      // 개발 중에는 가짜 사용자 데이터로 대체 (나중에 제거)
      print('사용자 정보 가져오기 실패: $e, 가짜 데이터 사용');
      return User(
        id: '1',
        name: '테스트 사용자',
        email: Config.defaultTestEmail,
        profileImage: 'https://via.placeholder.com/150',
      );
    }
  }
  
  // 회원가입
  Future<User> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Config.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'email': email,
          'password1': password,
          'password2': password,  // dj-rest-auth 회원가입은 비밀번호 확인 필드를 요구
          'first_name': name,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 토큰 저장
        final token = data['key'] ?? data['access'];
        await _saveToken(token);
        
        // 사용자 정보 가져오기
        final userInfo = await _getUserInfo(token);
        
        // 사용자 정보 저장
        await _saveUserData(userInfo);
        
        return userInfo;
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = '회원가입에 실패했습니다';
        
        // dj-rest-auth의 에러 메시지 형식에 맞춤
        if (errorData.containsKey('email')) {
          errorMsg = errorData['email'][0];
        } else if (errorData.containsKey('username')) {
          errorMsg = errorData['username'][0];
        } else if (errorData.containsKey('password1')) {
          errorMsg = errorData['password1'][0];
        } else if (errorData.containsKey('non_field_errors')) {
          errorMsg = errorData['non_field_errors'][0];
        }
        
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }
  
  // 로그아웃
  Future<void> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        await http.post(
          Uri.parse(Config.logoutEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );
      }
    } catch (e) {
      print('로그아웃 API 호출 실패: $e');
    } finally {
      // 로컬 저장소에서 토큰과 사용자 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    }
  }
  
  // 현재 로그인된 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    
    // 저장된 사용자 정보가 없지만 토큰이 있는 경우, API로 사용자 정보 가져오기 시도
    final token = await getToken();
    if (token != null) {
      try {
        return await _getUserInfo(token);
      } catch (e) {
        print('저장된 토큰으로 사용자 정보 가져오기 실패: $e');
        return null;
      }
    }
    
    return null;
  }
  
  // 토큰 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    // 토큰 유효성 검사 (선택적)
    try {
      final response = await http.get(
        Uri.parse(Config.userInfoEndpoint),
        headers: {
          'Authorization': 'Token $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('토큰 유효성 검사 실패: $e');
      return false;
    }
  }
  
  // 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // 사용자 정보 저장
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }
}