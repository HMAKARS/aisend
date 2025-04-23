import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String _error = '';
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _currentUser != null;
  
  // 로그인
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _currentUser = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 회원가입
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _currentUser = await _authService.signUp(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 로그아웃
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _authService.logout();
    _currentUser = null;
    
    _isLoading = false;
    notifyListeners();
  }
  
  // 현재 로그인 상태 확인
  Future<bool> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
      
      return isLoggedIn;
    } catch (error) {
      _error = error.toString();
      return false;
    }
  }
  
  // 에러 메시지 초기화
  void clearError() {
    _error = '';
    notifyListeners();
  }
}