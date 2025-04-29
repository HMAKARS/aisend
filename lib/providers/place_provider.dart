import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/place_service.dart';

enum UserType { alone, couple, family, friends }

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.alone:
        return '혼자';
      case UserType.couple:
        return '연인';
      case UserType.family:
        return '가족';
      case UserType.friends:
        return '친구';
    }
  }

  String get apiValue {
    switch (this) {
      case UserType.alone:
        return 'alone';
      case UserType.couple:
        return 'couple';
      case UserType.family:
        return 'family';
      case UserType.friends:
        return 'friends';
    }
  }

  static UserType fromString(String type) {
    switch (type) {
      case 'alone':
        return UserType.alone;
      case 'couple':
        return UserType.couple;
      case 'family':
        return UserType.family;
      case 'friends':
        return UserType.friends;
      default:
        return UserType.alone;
    }
  }
}

class PlaceProvider with ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  
  List<Place> _places = [];
  Place? _selectedPlace;
  bool _isLoading = false;
  String _error = '';
  
  List<Place> get places => _places;
  Place? get selectedPlace => _selectedPlace;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // 장소 검색
  Future<void> searchPlaces({
    required UserType userType,
    String? keyword,
    bool? isDriveCourse,
    bool? isNoKidsZone,
    bool? isKidsZone,
    bool? isPetZone,
    String? timeFilter,
    List<String>? categories,
    String? sortBy,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    print('-------------- 검색 시작 --------------');
    print('사용자 유형: ${userType.apiValue}');
    print('검색어: $keyword');
    print('필터 - 드라이브 코스: $isDriveCourse');
    print('필터 - 노키즈존: $isNoKidsZone');
    print('필터 - 키즈존: $isKidsZone');
    print('필터 - 반려동물존: $isPetZone');
    print('필터 - 시간: $timeFilter');
    print('필터 - 카테고리: $categories');
    print('정렬: $sortBy');
    
    try {
      _places = await _placeService.searchPlaces(
        userType: userType.apiValue,
        keyword: keyword,
        isDriveCourse: isDriveCourse,
        isNoKidsZone: isNoKidsZone,
        isKidsZone: isKidsZone,
        isPetZone: isPetZone,
        timeFilter: timeFilter,
        categories: categories,
        sortBy: sortBy,
      );
      
      print('검색 결과 수: ${_places.length}');
      
      // 클라이언트 측에서 정렬 (백엔드에서 처리되지 않은 경우)
      if (sortBy != null && _places.isNotEmpty) {
        _sortPlaces(sortBy);
        print('로컬에서 정렬 완료: $sortBy');
      }
    } catch (e) {
      _error = e.toString();
      _places = [];
      print('검색 오류 발생: $e');
    } finally {
      _isLoading = false;
      print('-------------- 검색 완료 --------------');
      notifyListeners();
    }
  }
  
  // 장소 정렬 메서드
  void _sortPlaces(String sortOption) {
    switch (sortOption) {
      case '평점 높은순':
        _places.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '리뷰 많은순':
        _places.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case '거리순':
        _places.sort((a, b) => a.travelTime.compareTo(b.travelTime));
        break;
      case '인기순':
      default:
        // 기본 정렬은 백엔드에서 처리되었다고 가정
        break;
    }
  }
  
  // 장소 상세 정보 가져오기
  Future<void> getPlaceDetails(String placeId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _selectedPlace = await _placeService.getPlaceDetails(placeId);
    } catch (e) {
      _error = e.toString();
      _selectedPlace = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 선택된 장소 초기화
  void clearSelectedPlace() {
    _selectedPlace = null;
    notifyListeners();
  }
  
  // 검색 결과 초기화
  void clearSearchResults() {
    _places = [];
    notifyListeners();
  }
}