import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/trip.dart';

class TripProvider with ChangeNotifier {
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _tripPlan;

  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get tripPlan => _tripPlan;

  final String baseUrl = 'https://your-api-base-url.com'; // 실제 API 주소로 바꿔줘

  Future<void> fetchAllTrips() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/trip/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _trips = data.map((item) => Trip.fromJson(item)).toList();
      } else {
        _error = '여행 목록을 불러오지 못했습니다.';
      }
    } catch (e) {
      _error = '네트워크 오류: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTripDetail(String tripId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/trip/$tripId/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedTrip = Trip.fromJson(data);
      } else {
        _error = '여행 정보를 불러오지 못했습니다.';
      }
    } catch (e) {
      _error = '네트워크 오류: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTripPlan(String tripId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/trip/$tripId/plan/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tripPlan = data;
      } else {
        _error = '추천 코스 정보를 불러오지 못했습니다.';
      }
    } catch (e) {
      _error = '네트워크 오류: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearTripPlan() {
    _tripPlan = null;
    notifyListeners();
  }

  Future<bool> toggleFavorite(String tripId) async {
    final url = Uri.parse('$baseUrl/api/trip/$tripId/favorite/');
    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN'  // replace with real token management
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('즐겨찾기 실패: $e');
    }
    return false;
  }

  Future<void> fetchTripsByType(TripType type) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/recommend/?type=${type.name}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _trips = data.map((e) => Trip.fromJson(e)).toList();
      } else {
        _error = '여행 데이터를 불러올 수 없습니다.';
      }
    } catch (e) {
      _error = '네트워크 오류: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}