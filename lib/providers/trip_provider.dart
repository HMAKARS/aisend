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

  final String baseUrl = 'http://localhost:8000'; // 개발 환경 API 주소

  Future<void> searchTrips({
    TripType? type,
    String? keyword,
    bool? isDriveCourse,
    bool? isNoKidsZone,
    bool? isKidsZone,
    bool? isPetZone,
    String? timeFilter,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // 쿼리 파라미터 구성
      Map<String, String> queryParams = {};

      if (type != null) {
        queryParams['type'] = type.toString().split('.').last;
      }

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      if (isDriveCourse == true) {
        queryParams['is_drive_course'] = 'true';
      }

      if (isNoKidsZone == true) {
        queryParams['is_no_kids_zone'] = 'true';
      }

      if (isKidsZone == true) {
        queryParams['is_kids_zone'] = 'true';
      }

      if (isPetZone == true) {
        queryParams['is_pet_zone'] = 'true';
      }

      if (timeFilter != null) {
        queryParams['time_filter'] = timeFilter;
      }

      // API 호출
      final uri = Uri.parse('$baseUrl/api/trips/search/')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _trips = data.map((item) => Trip.fromJson(item)).toList();
      } else {
        _error = '검색 결과를 불러오지 못했습니다.';
      }
    } catch (e) {
      _error = '네트워크 오류: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllTrips() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/trips/'));
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
      final response = await http.get(Uri.parse('$baseUrl/api/trips/$tripId/'));
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

    final url = Uri.parse('$baseUrl/api/trips/$tripId/attractions/');
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
    final url = Uri.parse('$baseUrl/api/recommendations/favorites/');
    try {
      final response = await http.post(
        url, 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token YOUR_ACCESS_TOKEN'  // 실제 토큰 관리로 교체
        },
        body: json.encode({'trip': tripId})
      );
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
      // type 값 변환 (enum 이름에서 문자열로)
      final typeStr = type.toString().split('.').last;
      
      final url = Uri.parse('$baseUrl/api/trips/search/?type=$typeStr');
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

