// lib/services/tourism_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/tourism_spot.dart'; // 필요한 모델 정의

class TourismService {
  // HTTPS로 변경
  final String baseUrl = 'https://api.visitkorea.or.kr/openapi/service/rest/KorService';

  // 관광지 기본 정보 조회
  Future<List<TourismSpot>> searchTourismSpots({
    required String keyword,
    String contentTypeId = '12', // 12: 관광지, 14: 문화시설, 15: 축제/행사, 25: 여행코스, 32: 숙박, 38: 쇼핑, 39: 음식점
    int pageNo = 1,
    int numOfRows = 10,
  }) async {
    try {
      final queryParams = {
        'ServiceKey': Config.publicDataApiKey, // Decoding된 키 사용
        'MobileOS': 'ETC',
        'MobileApp': 'AISEND',
        'keyword': keyword,
        'contentTypeId': contentTypeId,
        'pageNo': pageNo.toString(),
        'numOfRows': numOfRows.toString(),
        '_type': 'json',
      };

      final uri = Uri.parse('$baseUrl/searchKeyword1')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 응답 구조에 따라 파싱 로직 구현
        final items = data['response']['body']['items']['item'] as List;
        return items.map((item) => TourismSpot.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tourism spots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching tourism spots: $e');
    }
  }

  // 관광지 상세 정보 조회 (오류 수정: 반환 타입 명시)
  Future<TourismSpotDetail?> getTourismSpotDetail(String contentId) async {
    try {
      final queryParams = {
        'ServiceKey': Config.publicDataApiKey,
        'MobileOS': 'ETC',
        'MobileApp': 'AISEND',
        'contentId': contentId,
        'defaultYN': 'Y',
        'firstImageYN': 'Y',
        'areacodeYN': 'Y',
        'addrinfoYN': 'Y',
        'mapinfoYN': 'Y',
        'overviewYN': 'Y',
        '_type': 'json',
      };

      final uri = Uri.parse('$baseUrl/detailCommon1')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final item = data['response']['body']['items']['item'][0];
        return TourismSpotDetail.fromJson(item);
      } else {
        throw Exception('Failed to load tourism spot detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting tourism spot detail: $e');
    }
    
    // 명시적으로 null 반환을 추가하지 않아도 됨 (타입이 TourismSpotDetail?로 변경됨)
  }

  // 위치 기반 주변 관광지 검색 (오류 수정: 반환 타입 명시)
  Future<List<TourismSpot>> searchNearbySpots(double lat, double lng, int radius) async {
    try {
      final queryParams = {
        'ServiceKey': Config.publicDataApiKey,
        'MobileOS': 'ETC',
        'MobileApp': 'AISEND',
        'mapX': lng.toString(),
        'mapY': lat.toString(),
        'radius': radius.toString(),
        '_type': 'json',
      };

      final uri = Uri.parse('$baseUrl/locationBasedList1')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['response']['body']['items'] == '') {
          // 결과가 없는 경우 빈 리스트 반환
          return [];
        }
        
        final items = data['response']['body']['items']['item'] as List;
        return items.map((item) => TourismSpot.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load nearby spots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching nearby spots: $e');
    }
  }
}