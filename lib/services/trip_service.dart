import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip.dart';
import '../config/config.dart';

class TripService {
  // 환경 변수에서 URL 가져오기
  final String baseUrl = AppConfig.tripsBaseUrl;
  
  // 여행 타입별 목록 가져오기
  Future<List<Trip>> getTripsByType(TripType type) async {
    // 실제 API 연동 시 활성화
    // final response = await http.get(Uri.parse('$baseUrl?type=${type.toString().split('.').last}'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> data = json.decode(response.body);
    //   return data.map((json) => Trip.fromJson(json)).toList();
    // } else {
    //   throw Exception('Failed to load trips');
    // }
    
    // 임시 데이터 반환 (API 연동 전)
    await Future.delayed(Duration(milliseconds: 800)); // 네트워크 지연 시뮬레이션
    return _getMockTrips().where((trip) => trip.type == type).toList();
  }
  
  // 여행 상세 정보 가져오기
  Future<Trip> getTripById(String id) async {
    // 실제 API 연동 시 활성화
    // final response = await http.get(Uri.parse('$baseUrl/$id'));
    // if (response.statusCode == 200) {
    //   return Trip.fromJson(json.decode(response.body));
    // } else {
    //   throw Exception('Failed to load trip detail');
    // }
    
    // 임시 데이터 반환 (API 연동 전)
    await Future.delayed(Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션
    final trip = _getMockTrips().firstWhere((trip) => trip.id == id, 
        orElse: () => throw Exception('Trip not found'));
    return trip;
  }
  
  // 모든 여행 코스 가져오기
  Future<List<Trip>> getAllTrips() async {
    // 실제 API 연동 시 활성화
    // final response = await http.get(Uri.parse(baseUrl));
    // if (response.statusCode == 200) {
    //   final List<dynamic> data = json.decode(response.body);
    //   return data.map((json) => Trip.fromJson(json)).toList();
    // } else {
    //   throw Exception('Failed to load trips');
    // }
    
    // 임시 데이터 반환 (API 연동 전)
    await Future.delayed(Duration(milliseconds: 800)); // 네트워크 지연 시뮬레이션
    return _getMockTrips();
  }
  
  // 임시 데이터 (나중에 실제 API로 대체될 예정)
  List<Trip> _getMockTrips() {
    return [
      Trip(
        id: '1',
        title: '서울 한강 자전거 여행',
        description: '아름다운 한강을 따라 자전거를 타며 즐기는 여행 코스입니다. 여의도 공원, 반포 대교, 뚝섬 유원지를 지나는 코스로 약 4시간이 소요됩니다.',
        imageUrl: 'https://via.placeholder.com/600x400?text=Seoul+Hangang',
        location: '서울 한강',
        duration: 240, // 4시간
        rating: 4.5,
        type: TripType.solo,
        attractions: [
          Attraction(
            id: '101',
            name: '여의도 한강공원',
            description: '서울 시내에서 가장 넓은 한강공원',
            imageUrl: 'https://via.placeholder.com/300x200?text=Yeouido+Park',
            latitude: 37.5287,
            longitude: 126.9343,
            visitDuration: 60,
            rating: 4.7,
          ),
          Attraction(
            id: '102',
            name: '반포대교 달빛무지개분수',
            description: '세계에서 가장 긴 교량분수',
            imageUrl: 'https://via.placeholder.com/300x200?text=Banpo+Bridge',
            latitude: 37.5125,
            longitude: 126.9973,
            visitDuration: 30,
            rating: 4.8,
          ),
          Attraction(
            id: '103',
            name: '뚝섬한강공원',
            description: '야외 수영장과 다양한 레포츠를 즐길 수 있는 공간',
            imageUrl: 'https://via.placeholder.com/300x200?text=Ttukseom+Park',
            latitude: 37.5303,
            longitude: 127.0667,
            visitDuration: 90,
            rating: 4.5,
          ),
        ],
      ),
      Trip(
        id: '2',
        title: '경복궁 데이트',
        description: '서울 도심에서 역사와 문화를 느낄 수 있는 경복궁 데이트 코스. 경복궁 관람 후 인근 삼청동과 북촌한옥마을을 둘러보는 코스입니다.',
        imageUrl: 'https://via.placeholder.com/600x400?text=Gyeongbokgung',
        location: '서울 종로구',
        duration: 300, // 5시간
        rating: 4.7,
        type: TripType.couple,
        attractions: [
          Attraction(
            id: '201',
            name: '경복궁',
            description: '조선시대 대표적인 궁궐',
            imageUrl: 'https://via.placeholder.com/300x200?text=Gyeongbokgung+Palace',
            latitude: 37.5796,
            longitude: 126.9768,
            visitDuration: 120,
            rating: 4.9,
          ),
          Attraction(
            id: '202',
            name: '삼청동 거리',
            description: '갤러리와 카페가 많은 예술 거리',
            imageUrl: 'https://via.placeholder.com/300x200?text=Samcheong+Street',
            latitude: 37.5824,
            longitude: 126.9811,
            visitDuration: 90,
            rating: 4.6,
          ),
          Attraction(
            id: '203',
            name: '북촌한옥마을',
            description: '전통 한옥을 볼 수 있는 마을',
            imageUrl: 'https://via.placeholder.com/300x200?text=Bukchon+Hanok+Village',
            latitude: 37.5824,
            longitude: 126.9861,
            visitDuration: 60,
            rating: 4.8,
          ),
        ],
      ),
      Trip(
        id: '3',
        title: '에버랜드 가족 나들이',
        description: '온 가족이 함께 즐길 수 있는 에버랜드 테마파크 여행 코스입니다. 다양한 놀이기구와 동물원을 관람할 수 있습니다.',
        imageUrl: 'https://via.placeholder.com/600x400?text=Everland',
        location: '경기도 용인시',
        duration: 480, // 8시간
        rating: 4.6,
        type: TripType.family,
        attractions: [
          Attraction(
            id: '301',
            name: '에버랜드 어트랙션',
            description: '티익스프레스 등 다양한 놀이기구',
            imageUrl: 'https://via.placeholder.com/300x200?text=Everland+Attractions',
            latitude: 37.2935,
            longitude: 127.2020,
            visitDuration: 240,
            rating: 4.7,
          ),
          Attraction(
            id: '302',
            name: '주토피아',
            description: '다양한 동물들을 만날 수 있는 동물원',
            imageUrl: 'https://via.placeholder.com/300x200?text=Zootopia',
            latitude: 37.2918,
            longitude: 127.2030,
            visitDuration: 120,
            rating: 4.5,
          ),
          Attraction(
            id: '303',
            name: '유러피안 가든',
            description: '아름다운 꽃과 조경을 볼 수 있는 정원',
            imageUrl: 'https://via.placeholder.com/300x200?text=European+Garden',
            latitude: 37.2943,
            longitude: 127.2018,
            visitDuration: 60,
            rating: 4.4,
          ),
        ],
      ),
      Trip(
        id: '4',
        title: '홍대 친구들과 문화 투어',
        description: '홍대 거리에서 친구들과 함께 즐길 수 있는 다양한 문화 체험 코스입니다. 거리 공연, 맛집, 전시회 등을 포함합니다.',
        imageUrl: 'https://via.placeholder.com/600x400?text=Hongdae',
        location: '서울 마포구',
        duration: 360, // 6시간
        rating: 4.4,
        type: TripType.friends,
        attractions: [
          Attraction(
            id: '401',
            name: '홍대 걷고싶은거리',
            description: '다양한 거리 공연을 볼 수 있는 거리',
            imageUrl: 'https://via.placeholder.com/300x200?text=Hongdae+Street',
            latitude: 37.5558,
            longitude: 126.9241,
            visitDuration: 90,
            rating: 4.3,
          ),
          Attraction(
            id: '402',
            name: '트릭아이 뮤지엄',
            description: '착시 효과를 이용한 재미있는 사진을 찍을 수 있는 박물관',
            imageUrl: 'https://via.placeholder.com/300x200?text=Trick+Eye+Museum',
            latitude: 37.5546,
            longitude: 126.9231,
            visitDuration: 90,
            rating: 4.5,
          ),
          Attraction(
            id: '403',
            name: '연남동 경의선 숲길',
            description: '옛 철길을 따라 조성된 공원',
            imageUrl: 'https://via.placeholder.com/300x200?text=Gyeongui+Line+Forest+Park',
            latitude: 37.5608,
            longitude: 126.9227,
            visitDuration: 60,
            rating: 4.4,
          ),
        ],
      ),
    ];
  }
}