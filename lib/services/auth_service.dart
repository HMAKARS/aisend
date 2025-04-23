import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/config.dart';

class AuthService {
  // 환경 변수에서 URL 가져오기
  final String baseUrl = AppConfig.authBaseUrl;
  
  // 로그인
  Future<User> login(String email, String password) async {
    // 실제 API 연동 시 활성화
    // final response = await http.post(
    //   Uri.parse('$baseUrl/login'),
    //   body: {'email': email, 'password': password},
    // );
    // 
    // if (response.statusCode == 200) {
    //   final userData = json.decode(response.body);
    //   final user = User.fromJson(userData);
    //   
    //   // 로그인 정보 저장
    //   await _saveUserData(user);
    //   
    //   return user;
    // } else {
    //   throw Exception('로그인에 실패했습니다');
    // }
    
    // 임시 로그인 로직 (API 연동 전)
    await Future.delayed(Duration(milliseconds: 1000)); // 네트워크 지연 시뮬레이션
    
    if (email == AppConfig.defaultTestEmail && password == AppConfig.defaultTestPassword) {
      final user = User(
        id: '1',
        name: '테스트 사용자',
        email: email,
        profileImage: 'https://via.placeholder.com/150',
      );
      
      // 로그인 정보 저장
      await _saveUserData(user);
      
      return user;
    } else {
      throw Exception('이메일 또는 비밀번호가 올바르지 않습니다');
    }
  }
  
  // 회원가입
  Future<User> signUp(String name, String email, String password) async {
    // 실제 API 연동 시 활성화
    // final response = await http.post(
    //   Uri.parse('$baseUrl/signup'),
    //   body: {
    //     'name': name,
    //     'email': email,
    //     'password': password,
    //   },
    // );
    // 
    // if (response.statusCode == 201) {
    //   final userData = json.decode(response.body);
    //   final user = User.fromJson(userData);
    //   
    //   // 로그인 정보 저장
    //   await _saveUserData(user);
    //   
    //   return user;
    // } else {
    //   throw Exception('회원가입에 실패했습니다');
    // }
    
    // 임시 회원가입 로직 (API 연동 전)
    await Future.delayed(Duration(milliseconds: 1500)); // 네트워크 지연 시뮬레이션
    
    // 이메일 중복 검사 시뮬레이션
    if (email == AppConfig.defaultTestEmail) {
      throw Exception('이미 등록된 이메일입니다');
    }
    
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      profileImage: 'https://via.placeholder.com/150',
    );
    
    // 로그인 정보 저장
    await _saveUserData(user);
    
    return user;
  }
  
  // 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_data');
  }
  
  // 현재 로그인된 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    
    return null;
  }
  
  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  // 사용자 정보 및 토큰 저장
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
    await prefs.setString('user_token', 'dummy_token_${user.id}'); // 실제 토큰으로 대체 필요
  }
}