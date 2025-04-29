import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import '../config/config.dart';

class PlaceService {
  final String baseUrl = Config.apiBaseUrl;

  // 테스트용 모의 데이터를 생성하는 메서드
  List<Place> _getMockPlaces({String? userType, String? keyword, List<String>? categories}) {
    // 기본 장소 데이터
    List<Place> mockPlaces = [
      Place(
        id: '1',
        name: '제주 올레길',
        description: '제주도의 아름다운 해안가를 따라 걷는 트레킹 코스입니다.',
        imageUrl: 'https://via.placeholder.com/400x300?text=제주+올레길',
        latitude: 33.450701,
        longitude: 126.570667,
        address: '제주특별자치도 제주시',
        categories: ['관광지', '자연'],
        rating: 4.5,
        reviewCount: 120,
        travelTime: 25,
      ),
      Place(
        id: '2',
        name: '성산일출봉',
        description: '유네스코 세계자연유산으로 등재된 제주의 대표적인 명소입니다.',
        imageUrl: 'https://via.placeholder.com/400x300?text=성산일출봉',
        latitude: 33.458031,
        longitude: 126.942465,
        address: '제주특별자치도 서귀포시 성산읍',
        categories: ['관광지', '자연'],
        rating: 4.8,
        reviewCount: 230,
        travelTime: 45,
      ),
      Place(
        id: '3',
        name: '이호테우 해변',
        description: '하얀 모래사장과 붉은 등대가 인상적인 해변입니다.',
        imageUrl: 'https://via.placeholder.com/400x300?text=이호테우+해변',
        latitude: 33.499621,
        longitude: 126.451219,
        address: '제주특별자치도 제주시 이호일동',
        categories: ['관광지', '자연', '해변'],
        rating: 4.3,
        reviewCount: 98,
        travelTime: 15,
        isKidsZone: true,
      ),
      Place(
        id: '4',
        name: '카페더콘테나',
        description: '바다가 보이는 컨테이너 카페입니다.',
        imageUrl: 'https://via.placeholder.com/400x300?text=카페더콘테나',
        latitude: 33.535538,
        longitude: 126.668669,
        address: '제주특별자치도 제주시 조천읍',
        categories: ['카페'],
        rating: 4.6,
        reviewCount: 87,
        travelTime: 35,
        isPetZone: true,
      ),
      Place(
        id: '5',
        name: '치킨집',
        description: '맛있는 치킨을 판매하는 레스토랑입니다.',
        imageUrl: 'https://via.placeholder.com/400x300?text=치킨집',
        latitude: 33.500000,
        longitude: 126.500000,
        address: '제주특별자치도 제주시 이도이동',
        categories: ['맛집'],
        rating: 4.2,
        reviewCount: 65,
        travelTime: 10,
        isNoKidsZone: true,
      ),
      Place(
        id: '6',
        name: '드라이브 코스',
        description: '제주 해안도로를 따라 드라이브하기 좋은 코스입니다.',
        imageUrl: 'https://via.placeholder.com/400x300?text=드라이브+코스',
        latitude: 33.300000,
        longitude: 126.600000,
        address: '제주특별자치도 서귀포시',
        categories: ['관광지', '드라이브'],
        rating: 4.7,
        reviewCount: 112,
        travelTime: 60,
        isDriveCourse: true,
      ),
    ];
    
    // 사용자 유형에 따른 필터링
    if (userType != null) {
      // 각 사용자 유형에 맞는 장소만 필터링 (예시 로직)
      switch(userType) {
        case 'alone': 
          mockPlaces = mockPlaces.where((p) => p.isNoKidsZone || p.categories.contains('카페')).toList();
          break;
        case 'couple':
          mockPlaces = mockPlaces.where((p) => p.categories.contains('카페') || p.categories.contains('드라이브')).toList();
          break;
        case 'family':
          mockPlaces = mockPlaces.where((p) => p.isKidsZone || !p.isNoKidsZone).toList();
          break;
        case 'friends':
          mockPlaces = mockPlaces.where((p) => p.categories.contains('맛집') || p.categories.contains('관광지')).toList();
          break;
      }
    }
    
    // 키워드 검색
    if (keyword != null && keyword.isNotEmpty) {
      mockPlaces = mockPlaces.where((p) => 
        p.name.toLowerCase().contains(keyword.toLowerCase()) || 
        p.description.toLowerCase().contains(keyword.toLowerCase()) ||
        p.address.toLowerCase().contains(keyword.toLowerCase())
      ).toList();
    }
    
    // 카테고리 필터링
    if (categories != null && categories.isNotEmpty) {
      mockPlaces = mockPlaces.where((p) => 
        categories.any((c) => p.categories.contains(c))
      ).toList();
    }
    
    print('모의 데이터 생성 완료: ${mockPlaces.length}개 항목');
    return mockPlaces;
  }

  Future<List<Place>> searchPlaces({
    required String userType, // 혼자/연인/가족/친구
    String? keyword,
    bool? isDriveCourse,
    bool? isNoKidsZone,
    bool? isKidsZone,
    bool? isPetZone,
    String? timeFilter, // 30분 이내, 1시간 이내, 2시간 이내
    List<String>? categories,
    String? sortBy,
  }) async {
    print('검색 요청: userType=$userType, keyword=$keyword, categories=$categories');
    
    try {
      // 항상 모의 데이터 사용
      if (Config.useMockData) {
        print('모의 데이터 모드 활성화됨');
        List<Place> mockResults = _getMockPlaces(
          userType: userType,
          keyword: keyword,
          categories: categories
        );
        
        // 드라이브 코스 필터
        if (isDriveCourse == true) {
          mockResults = mockResults.where((p) => p.isDriveCourse).toList();
        }
        
        // 노키즈존 필터
        if (isNoKidsZone == true) {
          mockResults = mockResults.where((p) => p.isNoKidsZone).toList();
        }
        
        // 키즈존 필터
        if (isKidsZone == true) {
          mockResults = mockResults.where((p) => p.isKidsZone).toList();
        }
        
        // 펫존 필터
        if (isPetZone == true) {
          mockResults = mockResults.where((p) => p.isPetZone).toList();
        }
        
        // 시간 필터
        if (timeFilter != null) {
          int maxTime = int.parse(_parseTimeFilter(timeFilter));
          mockResults = mockResults.where((p) => p.travelTime <= maxTime).toList();
        }
        
        // 정렬
        if (sortBy != null) {
          String sortOption = _convertSortOption(sortBy);
          switch (sortOption) {
            case 'rating':
              mockResults.sort((a, b) => b.rating.compareTo(a.rating));
              break;
            case 'review_count':
              mockResults.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
              break;
            case 'distance':
              mockResults.sort((a, b) => a.travelTime.compareTo(b.travelTime));
              break;
            case 'popularity':
            default:
              // 기본 인기순은 리뷰 수와 평점의 조합으로 정렬
              mockResults.sort((a, b) => (b.reviewCount * b.rating).compareTo(a.reviewCount * a.rating));
              break;
          }
        }
        
        print('모의 검색 결과: ${mockResults.length}개 항목');
        return mockResults;
      }
      
      // 원래 API 호출 코드
      print('실제 API 모드 활성화됨');
      // 쿼리 파라미터 구성
      Map<String, String> queryParams = {
        'user_type': userType,
      };

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
        // 시간 필터 변환 (30분 이내 -> 30 등)
        queryParams['max_travel_time'] = _parseTimeFilter(timeFilter);
      }
      
      // 카테고리 필터 추가
      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories.join(',');
      }
      
      // 정렬 옵션 추가
      if (sortBy != null) {
        queryParams['sort_by'] = _convertSortOption(sortBy);
      }

      // API 호출
      final uri = Uri.parse('${baseUrl}/places/search')
          .replace(queryParameters: queryParams);
          
      // 디버깅을 위한 API 요청 로깅
      print('검색 API 요청 URL: $uri');
      print('검색 파라미터: $queryParams');
      
      final response = await http.get(uri);
      
      // 디버깅을 위한 API 응답 로깅
      print('검색 API 응답 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('검색 API 응답 본문: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
        final data = json.decode(response.body) as List;
        return data.map((item) => Place.fromJson(item)).toList();
      } else {
        print('검색 API 오류 응답: ${response.body}');
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('검색 처리 오류: $e');
      throw Exception('Error searching places: $e');
    }
  }
  
  // 정렬 옵션 변환 메서드
  String _convertSortOption(String sortOption) {
    switch (sortOption) {
      case '평점 높은순':
        return 'rating';
      case '리뷰 많은순':
        return 'review_count';
      case '거리순':
        return 'distance';
      case '인기순':
      default:
        return 'popularity';
    }
  }

  // 장소 상세 정보 가져오기
  Future<Place> getPlaceDetails(String placeId) async {
    print('장소 상세정보 요청: id=$placeId');
    
    try {
      // 항상 모의 데이터 사용
      if (Config.useMockData) {
        print('모의 데이터 모드 활성화됨 (상세정보)');
        // 먼저 모의 검색 결과에서 해당 ID의 장소를 찾음
        final mockPlaces = _getMockPlaces();
        final place = mockPlaces.firstWhere(
          (p) => p.id == placeId,
          orElse: () => throw Exception('Place not found with ID: $placeId')
        );
        
        // 실제 API에서는 더 많은 상세 정보를 가져올 수 있으므로 모의 데이터에 일부 정보 추가
        return Place(
          id: place.id,
          name: place.name,
          description: place.description,
          imageUrl: place.imageUrl,
          latitude: place.latitude,
          longitude: place.longitude,
          address: place.address,
          categories: place.categories,
          rating: place.rating,
          reviewCount: place.reviewCount,
          isDriveCourse: place.isDriveCourse,
          isKidsZone: place.isKidsZone,
          isNoKidsZone: place.isNoKidsZone,
          isPetZone: place.isPetZone,
          travelTime: place.travelTime,
          // 추가 상세 정보
          openingHours: {
            'monday': '09:00-18:00',
            'tuesday': '09:00-18:00',
            'wednesday': '09:00-18:00',
            'thursday': '09:00-18:00',
            'friday': '09:00-18:00',
            'saturday': '10:00-17:00',
            'sunday': '10:00-17:00',
          },
          facilities: ['주차장', '화장실', '편의점', 'Wi-Fi'],
        );
      }
      
      // 원래 API 호출 코드
      print('실제 API 모드 활성화됨 (상세정보)');
      final uri = Uri.parse('${baseUrl}/places/${placeId}');
      
      // 디버깅을 위한 API 요청 로깅
      print('상세정보 API 요청 URL: $uri');
      
      final response = await http.get(uri);
      
      // 디버깅을 위한 API 응답 로깅
      print('상세정보 API 응답 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('상세정보 API 응답 본문: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
        final data = json.decode(response.body);
        return Place.fromJson(data);
      } else {
        print('상세정보 API 오류 응답: ${response.body}');
        throw Exception('Failed to load place details: ${response.statusCode}');
      }
    } catch (e) {
      print('장소 상세정보 처리 오류: $e');
      throw Exception('Error getting place details: $e');
    }
  }

  // 시간 필터 문자열을 분으로 변환
  String _parseTimeFilter(String timeFilter) {
    switch (timeFilter) {
      case '30분 이내':
        return '30';
      case '1시간 이내':
        return '60';
      case '2시간 이내':
        return '120';
      default:
        return '30'; // 기본값
    }
  }
}