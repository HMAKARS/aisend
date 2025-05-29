import requests
import json
import math
import logging
import uuid
import random
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Attraction, Food, PetTour
from .serializers import AttractionSerializer, TripPlanSerializer, PlaceSerializer
from django.db import transaction

logger = logging.getLogger(__name__)


class AttractionListView(generics.ListCreateAPIView):
    """관광 명소 목록 및 생성 API"""
    queryset = Attraction.objects.all().order_by('id')
    serializer_class = AttractionSerializer
    permission_classes = [AllowAny]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        
        # 필터링 파라미터
        location = self.request.query_params.get('location')
        
        if location:
            queryset = queryset.filter(addr1__icontains=location)
            
        return queryset


class AttractionDetailView(generics.RetrieveUpdateDestroyAPIView):
    """관광 명소 상세 정보 API"""
    queryset = Attraction.objects.all()
    serializer_class = AttractionSerializer
    permission_classes = [AllowAny]


class KakaoApiService:
    """카카오맵 API 서비스"""
    
    def __init__(self):
        self.api_key = settings.KAKAO_REST_API_KEY
        self.headers = {
            'Authorization': f'KakaoAK {self.api_key}'
        }
        
    def search_places(self, query, x=None, y=None, radius=20000, page=1, size=15):
        """
        키워드로 장소 검색
        """
        url = 'https://dapi.kakao.com/v2/local/search/keyword.json'
        
        params = {
            'query': query,
            'page': page,
            'size': size
        }
        
        if x is not None and y is not None:
            params.update({
                'x': x,
                'y': y,
                'radius': radius
            })
            
        response = requests.get(url, headers=self.headers, params=params)
        
        if response.status_code == 200:
            return response.json()
        else:
            logger.error(f"검색 실패: {response.status_code}, {response.text}")
            return {'documents': []}

    def calculate_distance(self, origin_x, origin_y, destination_x, destination_y):
        """
        두 지점 간의 거리 계산 (Haversine 공식)
        """
        # 지구 반지름 (km)
        R = 6371.0
        
        # 좌표를 라디안으로 변환
        lat1 = math.radians(float(origin_y))
        lon1 = math.radians(float(origin_x))
        lat2 = math.radians(float(destination_y))
        lon2 = math.radians(float(destination_x))
        
        # Haversine 공식
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        distance = R * c
        
        # 예상 시간 (차량 평균 속도 60km/h 가정)
        time_minutes = (distance / 60) * 60
        
        return {
            'distance': round(distance, 2),  # km
            'time': round(time_minutes)      # minutes
        }


class PlaceSearchView(APIView):
    """
    카카오맵 API를 활용한 별점 높은 장소 검색 API
    GET 및 POST 메서드 지원
    """
    permission_classes = [AllowAny]
    
    def get(self, request):
        """
        GET 메서드로 장소 검색
        """
        location = request.query_params.get('location', '')
        category = request.query_params.get('category', '')
        min_rating = float(request.query_params.get('min_rating', 3.0))
        
        if not location:
            return Response({'error': '검색할 지역을 입력해주세요'}, status=status.HTTP_400_BAD_REQUEST)
        
        # 카카오 API 서비스 초기화
        kakao_service = KakaoApiService()
        
        # 검색 쿼리 생성
        query = f"{location}"
        if category:
            query += f" {category}"
        
        # 카카오맵 API 호출
        search_result = kakao_service.search_places(query=query, size=30)
        documents = search_result.get('documents', [])
        
        # 결과 필터링 및 가공
        results = []
        for place in documents:
            # 여기서는 모든 장소의 별점을 4.0으로 고정 (카카오 API는 별점 X)
            # 실제 서비스에서는 크롤링 등으로 별점 정보를 얻어야 함
            place_with_rating = {
                'id': place.get('id', ''),
                'name': place.get('place_name', ''),
                'category': place.get('category_name', ''),
                'address': place.get('address_name', ''),
                'road_address': place.get('road_address_name', ''),
                'phone': place.get('phone', ''),
                'place_url': place.get('place_url', ''),
                'latitude': float(place.get('y', 0)),
                'longitude': float(place.get('x', 0)),
                'rating': 4.0,  # 임시 별점 (모든 장소 4.0 고정)
                'image_url': '',  # 임시 이미지 URL
            }
            
            # 최소 별점 필터링 (여기서는 의미 없으나 구조 유지)
            if place_with_rating['rating'] >= min_rating:
                results.append(place_with_rating)
        
        return Response({
            'location': location,
            'count': len(results),
            'results': results
        })
    
    def post(self, request):
        """
        POST 메서드로 장소 검색
        """
        location = request.data.get('location', '')
        category = request.data.get('category', '')
        min_rating = float(request.data.get('min_rating', 3.0))
        
        if not location:
            return Response({'error': '검색할 지역을 입력해주세요'}, status=status.HTTP_400_BAD_REQUEST)
        
        # 카카오 API 서비스 초기화
        kakao_service = KakaoApiService()
        
        # 검색 쿼리 생성
        query = f"{location}"
        if category:
            query += f" {category}"
        
        # 카카오맵 API 호출
        search_result = kakao_service.search_places(query=query, size=30)
        documents = search_result.get('documents', [])
        
        # 결과 필터링 및 가공
        results = []
        for place in documents:
            # 여기서는 모든 장소의 별점을 4.0으로 고정 (카카오 API는 별점 X)
            # 실제 서비스에서는 크롤링 등으로 별점 정보를 얻어야 함
            place_with_rating = {
                'id': place.get('id', ''),
                'name': place.get('place_name', ''),
                'category': place.get('category_name', ''),
                'address': place.get('address_name', ''),
                'road_address': place.get('road_address_name', ''),
                'phone': place.get('phone', ''),
                'place_url': place.get('place_url', ''),
                'latitude': float(place.get('y', 0)),
                'longitude': float(place.get('x', 0)),
                'rating': 4.0,  # 임시 별점 (모든 장소 4.0 고정)
                'image_url': '',  # 임시 이미지 URL
            }
            
            # 최소 별점 필터링 (여기서는 의미 없으나 구조 유지)
            if place_with_rating['rating'] >= min_rating:
                results.append(place_with_rating)
        
        return Response({
            'location': location,
            'count': len(results),
            'results': results
        })
    

class LocationBasedTripView(APIView):
    """
    별점 높은 장소 데이터를 활용한 위치 기반 여행 계획 생성 API
    """
    permission_classes = [AllowAny]
    
    def post(self, request):
        location = request.data.get('location', '')
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        duration_hours = float(request.data.get('duration_hours', 2.0))
        transport = request.data.get('transport', '자동차')
        min_rating = float(request.data.get('min_rating', 3.0))
        
        if not location and not (latitude and longitude):
            return Response({'error': '위치 정보(장소명 또는 좌표)가 필요합니다'}, 
                            status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # 1. 장소 데이터 수집
            kakao_service = KakaoApiService()
            
            # 쿼리 구성
            queries = [
                f"{location} 관광지",
                f"{location} 맛집",
                f"{location} 카페"
            ]
            
            places = []
            for query in queries:
                search_result = kakao_service.search_places(
                    query=query,
                    x=longitude,
                    y=latitude,
                    radius=self._get_radius_from_duration(duration_hours),
                    size=10
                )
                
                documents = search_result.get('documents', [])
                for place in documents:
                    # 임시 별점 설정 (4.0~4.7 사이 랜덤값)
                    import random
                    rating = round(4.0 + random.random() * 0.7, 1)
                    
                    place_data = {
                        'id': place.get('id', ''),
                        'name': place.get('place_name', ''),
                        'category': place.get('category_name', ''),
                        'address': place.get('address_name', ''),
                        'phone': place.get('phone', ''),
                        'place_url': place.get('place_url', ''),
                        'latitude': float(place.get('y', 0)),
                        'longitude': float(place.get('x', 0)),
                        'rating': rating,
                        'image_url': '',
                        'visit_duration': self._estimate_visit_duration(place.get('category_name', '')),
                        'source': 'kakao',
                        'source_id': place.get('id', ''),
                    }
                    
                    # 최소 별점 필터링
                    if place_data['rating'] >= min_rating:
                        # 중복 제거 (ID 기준)
                        if not any(p['id'] == place_data['id'] for p in places):
                            places.append(place_data)
            
            # 2. 별점 기준 정렬
            places.sort(key=lambda x: x['rating'], reverse=True)
            
            # 3. 장소 간 이동 시간 계산
            travel_times = self._calculate_travel_times(places, kakao_service)
            
            # 4. 여행 계획 생성
            trip_plan = self._create_trip_plan(
                places=places,
                travel_times=travel_times,
                duration_hours=duration_hours,
                location=location,
                transport=transport
            )
            
            # 5. 시리얼라이저로 응답 형식 검증
            serializer = TripPlanSerializer(data=trip_plan)
            serializer.is_valid(raise_exception=True)
            
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"위치 기반 여행 계획 생성 오류: {str(e)}")
            return Response({'error': f'여행 계획 생성 중 오류가 발생했습니다: {str(e)}'},
                         status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def _create_trip_plan(self, places, travel_times, duration_hours, location, transport):
        """여행 계획 생성"""
        # 여행 시간(분)을 기준으로 방문 가능한 장소 선정
        total_minutes = int(duration_hours * 60)
        
        # 최적의 장소 선정 (간단한 탐욕 알고리즘)
        selected_places = self._select_optimal_places(places, travel_times, total_minutes)
        
        # 여행 계획 객체 생성
        trip_plan = {
            'id': f'location-{location}-{duration_hours}h',
            'title': f'{location} {duration_hours}시간 코스',
            'description': f'{location} 지역의 별점 높은 장소들로 구성된 {duration_hours}시간 여행 코스입니다.',
            'imageUrl': selected_places[0]['image_url'] if selected_places else '',
            'rating': 4.5,  # 기본값
            'duration': total_minutes,
            'tags': ['카페', '맛집', location],
            'places': [],
        }
        
        # 선택된 장소들을 여행 계획에 추가
        for i, place in enumerate(selected_places):
            trip_plan['places'].append({
                'id': place['id'],
                'name': place['name'],
                'description': f"{place['category']}에 위치한 {place['name']}입니다.",
                'imageUrl': place['image_url'],
                'latitude': place['latitude'],
                'longitude': place['longitude'],
                'visitDuration': place['visit_duration'],
                'rating': place['rating'],
                'order': i + 1,
            })
        
        return trip_plan
    
    def _select_optimal_places(self, places, travel_times, total_minutes):
        """최적의 장소 조합 선택"""
        # 장소 평점 기준 정렬
        sorted_places = sorted(places, key=lambda x: x['rating'], reverse=True)
        
        selected_places = []
        remaining_time = total_minutes
        current_location_idx = None
        
        # 평점 높은 장소부터 선택
        for place in sorted_places:
            visit_duration = place['visit_duration']
            
            # 첫 장소 선택
            if not selected_places:
                selected_places.append(place)
                remaining_time -= visit_duration
                current_location_idx = places.index(place)
                continue
            
            # 현재 위치에서 다음 장소까지 이동 시간 계산
            place_idx = places.index(place)
            travel_time = travel_times[current_location_idx][place_idx] if 0 <= current_location_idx < len(travel_times) and 0 <= place_idx < len(travel_times[0]) else 30
            
            # 남은 시간이 충분한지 확인
            if remaining_time >= visit_duration + travel_time:
                selected_places.append(place)
                remaining_time -= (visit_duration + travel_time)
                current_location_idx = place_idx
            
            # 충분한 장소를 선택했거나 시간이 부족하면 중단
            if remaining_time < 30 or len(selected_places) >= 5:  # 최대 5개 장소
                break
        
        return selected_places
    
    def _calculate_travel_times(self, places, kakao_service):
        """장소 간 이동 시간 계산"""
        n = len(places)
        travel_times = [[0 for _ in range(n)] for _ in range(n)]
        
        for i in range(n):
            for j in range(n):
                if i == j:
                    travel_times[i][j] = 0
                else:
                    # 두 장소 간의 거리 계산
                    origin_x = places[i]['longitude']
                    origin_y = places[i]['latitude']
                    dest_x = places[j]['longitude']
                    dest_y = places[j]['latitude']
                    
                    distance_info = kakao_service.calculate_distance(
                        origin_x, origin_y, dest_x, dest_y
                    )
                    
                    # 이동 시간 저장 (분 단위)
                    travel_times[i][j] = distance_info['time']
        
        return travel_times
    
    def _categorize_place(self, category_name):
        """카테고리 분류"""
        category_name = category_name.lower() if category_name else ''
        
        if '카페' in category_name:
            return '카페'
        elif '음식점' in category_name or '식당' in category_name:
            return '음식점'
        elif '관광' in category_name or '명소' in category_name:
            return '관광지'
        elif '쇼핑' in category_name:
            return '쇼핑'
        elif '숙박' in category_name:
            return '숙소'
        else:
            return '기타'
    
    def _estimate_visit_duration(self, category_name):
        """방문 시간 추정"""
        category_name = category_name.lower() if category_name else ''
        
        if '카페' in category_name:
            return 60  # 카페: 1시간
        elif '음식점' in category_name or '식당' in category_name:
            return 90  # 음식점: 1시간 30분
        elif '관광' in category_name or '명소' in category_name:
            return 120  # 관광지: 2시간
        elif '쇼핑' in category_name:
            return 120  # 쇼핑: 2시간
        else:
            return 60  # 기본값: 1시간
    
    def _get_radius_from_duration(self, duration_hours):
        """검색 반경 계산"""
        if duration_hours <= 0.5:  # 30분
            return 5000   # 5km
        elif duration_hours <= 1:  # 1시간
            return 10000  # 10km
        elif duration_hours <= 2:  # 2시간
            return 20000  # 20km
        elif duration_hours <= 3:  # 3시간
            return 30000  # 30km
        else:
            return 50000  # 50km


class AITripPlannerView(APIView):
    """
    AI를 활용한 맞춤형 여행 계획 생성 API
    """
    permission_classes = [AllowAny]
    
    def post(self, request):
        # 요청에서 필요한 데이터 추출
        location = request.data.get('location', '')
        preferences = request.data.get('preferences', [])
        duration_days = int(request.data.get('duration_days', 1))
        travel_style = request.data.get('travel_style', '일반')
        with_who = request.data.get('with_who', '혼자')
        
        if not location:
            return Response({'error': '여행 지역을 입력해주세요'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # 1. 장소 데이터 수집
            places = self._collect_place_data(location, preferences)
            
            # 2. AI 기반 여행 계획 생성
            trip_plan = self._generate_ai_trip_plan(
                places=places,
                location=location,
                preferences=preferences,
                duration_days=duration_days,
                travel_style=travel_style,
                with_who=with_who
            )
            
            return Response(trip_plan, status=status.HTTP_200_OK)
            
        except Exception as e:
            logger.error(f"AI 여행 계획 생성 오류: {str(e)}")
            return Response({'error': f'여행 계획 생성 중 오류가 발생했습니다: {str(e)}'},
                         status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def _collect_place_data(self, location, preferences):
        """장소 데이터 수집"""
        places_data = []
        
        # 관광지 데이터 수집
        attractions = Attraction.objects.filter(addr1__icontains=location)[:20]
        for place in attractions:
            places_data.append({
                'id': f'attr_{place.id}',
                'name': place.title,
                'description': f"{place.title}은(는) {place.addr1}에 위치한 관광 명소입니다.",
                'image_url': place.image or '',
                'latitude': float(place.mapy) if place.mapy else 0,
                'longitude': float(place.mapx) if place.mapx else 0,
                'address': place.addr1,
                'contact': place.tel,
                'opening_hours': '09:00 - 18:00',  # 기본값
                'rating': 4.5,  # 기본값
                'visit_duration': 120,  # 기본값 2시간
                'category': '관광지',
            })
        
        # 음식점 데이터 수집 (선호도에 'food'가 있는 경우)
        if 'food' in preferences:
            foods = Food.objects.filter(addr1__icontains=location)[:10]
            for place in foods:
                places_data.append({
                    'id': f'food_{place.id}',
                    'name': place.title,
                    'description': f"{place.title}은(는) {place.addr1}에 위치한 음식점입니다.",
                    'image_url': place.image or '',
                    'latitude': float(place.mapy) if place.mapy else 0,
                    'longitude': float(place.mapx) if place.mapx else 0,
                    'address': place.addr1,
                    'contact': place.tel,
                    'opening_hours': '11:00 - 21:00',  # 기본값
                    'rating': 4.3,  # 기본값
                    'visit_duration': 90,  # 기본값 1시간 30분
                    'category': '음식점',
                })
        
        # 반려동물 동반 여행지 (선호도에 'pet'이 있는 경우)
        if 'pet' in preferences:
            pet_places = PetTour.objects.filter(addr1__icontains=location)[:10]
            for place in pet_places:
                places_data.append({
                    'id': f'pet_{place.id}',
                    'name': place.title,
                    'description': f"{place.title}은(는) {place.addr1}에 위치한 반려동물 동반 가능 장소입니다.",
                    'image_url': place.firstimage or '',
                    'latitude': float(place.mapy) if place.mapy else 0,
                    'longitude': float(place.mapx) if place.mapx else 0,
                    'address': place.addr1,
                    'contact': place.tel,
                    'opening_hours': '09:00 - 18:00',  # 기본값
                    'rating': 4.6,  # 기본값
                    'visit_duration': 120,  # 기본값 2시간
                    'category': '반려동물 동반',
                })
                
        # 충분한 결과가 없을 경우 카카오 API로 추가 데이터 수집
        if len(places_data) < 10:
            kakao_service = KakaoApiService()
            location_queries = [
                f"{location} 관광지",
                f"{location} 맛집",
                f"{location} 카페"
            ]
            
            for query in location_queries:
                search_result = kakao_service.search_places(query=query, size=10)
                documents = search_result.get('documents', [])
                
                for place in documents:
                    # 장소 데이터 가공
                    rating = round(4.0 + random.random() * 0.7, 1)
                    
                    if place.get('y') and place.get('x'):
                        places_data.append({
                            'id': f"kakao_{place.get('id', '')}",
                            'name': place.get('place_name', ''),
                            'description': f"{place.get('place_name', '')}은(는) {place.get('address_name', '')}에 위치한 {place.get('category_name', '')}입니다.",
                            'image_url': '',  # 카카오 API는 이미지 URL을 제공하지 않음
                            'latitude': float(place.get('y', 0)),
                            'longitude': float(place.get('x', 0)),
                            'address': place.get('address_name', ''),
                            'contact': place.get('phone', ''),
                            'opening_hours': '09:00 - 18:00',  # 기본값
                            'rating': rating,
                            'visit_duration': self._estimate_visit_duration(place.get('category_name', '')),
                            'category': self._categorize_place(place.get('category_name', '')),
                        })
        
        return places_data
    
    def _categorize_place(self, category_name):
        """카테고리 분류"""
        category_name = category_name.lower() if category_name else ''
        
        if '카페' in category_name:
            return '카페'
        elif '음식점' in category_name or '식당' in category_name:
            return '음식점'
        elif '관광' in category_name or '명소' in category_name:
            return '관광지'
        elif '쇼핑' in category_name:
            return '쇼핑'
        elif '숙박' in category_name:
            return '숙소'
        else:
            return '기타'
    
    def _estimate_visit_duration(self, category_name):
        """방문 시간 추정"""
        category_name = category_name.lower() if category_name else ''
        
        if '카페' in category_name:
            return 60  # 카페: 1시간
        elif '음식점' in category_name or '식당' in category_name:
            return 90  # 음식점: 1시간 30분
        elif '관광' in category_name or '명소' in category_name:
            return 120  # 관광지: 2시간
        elif '쇼핑' in category_name:
            return 120  # 쇼핑: 2시간
        else:
            return 60  # 기본값: 1시간
            
    def _generate_ai_trip_plan(self, places, location, preferences, duration_days, travel_style, with_who):
        """AI를 활용한 여행 계획 생성"""
        # 1일당 최적 방문 장소 수 계산
        places_per_day = 5  # 기본값
        
        if travel_style == '여유':
            places_per_day = 3
        elif travel_style == '효율':
            places_per_day = 6
        
        # 평점 기준 장소 정렬
        sorted_places = sorted(places, key=lambda x: x['rating'], reverse=True)
        
        # 일별 플랜 생성
        daily_plans = []
        plan_id = str(uuid.uuid4())[:8]
        
        # 여행 스타일에 따른 문구 생성
        style_description = self._get_style_description(travel_style, with_who)
        
        # 각 일자별 장소 할당 및 계획 생성
        places_by_category = {
            '관광지': [p for p in sorted_places if p['category'] == '관광지'],
            '음식점': [p for p in sorted_places if p['category'] == '음식점'],
            '카페': [p for p in sorted_places if p['category'] == '카페'],
            '반려동물 동반': [p for p in sorted_places if p['category'] == '반려동물 동반'],
            '쇼핑': [p for p in sorted_places if p['category'] == '쇼핑'],
            '기타': [p for p in sorted_places if p['category'] not in ['관광지', '음식점', '카페', '반려동물 동반', '쇼핑']],
        }
        
        total_places = sum(len(places) for places in places_by_category.values())
        
        for day in range(1, duration_days + 1):
            # 일별 장소 선택 (카테고리별로 균형 있게)
            day_places = []
            
            # 관광지 2개
            attractions = places_by_category['관광지'][min(2 * (day - 1), len(places_by_category['관광지']) - 1):min(2 * day, len(places_by_category['관광지']))]
            day_places.extend(attractions)
            
            # 음식점 1-2개
            food_places = places_by_category['음식점'][min(2 * (day - 1), len(places_by_category['음식점']) - 1):min(2 * day, len(places_by_category['음식점']))]
            day_places.extend(food_places)
            
            # 카페 1개
            if '카페' in preferences:
                cafes = places_by_category['카페'][min(day - 1, len(places_by_category['카페']) - 1):min(day, len(places_by_category['카페']))]
                day_places.extend(cafes)
            
            # 반려동물 동반 장소
            if 'pet' in preferences and places_by_category['반려동물 동반']:
                pet_places = places_by_category['반려동물 동반'][min(day - 1, len(places_by_category['반려동물 동반']) - 1):min(day, len(places_by_category['반려동물 동반']))]
                day_places.extend(pet_places)
            
            # 기타 장소로 채우기
            remaining_count = places_per_day - len(day_places)
            if remaining_count > 0:
                remaining_places = places_by_category['기타'][min(remaining_count * (day - 1), len(places_by_category['기타']) - 1):min(remaining_count * day, len(places_by_category['기타']))]
                day_places.extend(remaining_places)
            
            # 장소가 충분하지 않은 경우 다른 카테고리에서 가져오기
            if len(day_places) < places_per_day:
                all_places = []
                for category, cat_places in places_by_category.items():
                    all_places.extend([p for p in cat_places if p not in day_places])
                
                all_places = sorted(all_places, key=lambda x: x['rating'], reverse=True)
                day_places.extend(all_places[:places_per_day - len(day_places)])
            
            if not day_places:
                break
                
            # 일별 계획 생성
            daily_plan = {
                'day': day,
                'title': f'Day {day}: {location} 여행',
                'description': self._generate_daily_description(day_places, day, location),
                'places': []
            }
            
            # 시간순 최적 정렬
            day_places = self._sort_places_by_time(day_places)
            
            # 장소별 상세 정보 추가
            for i, place in enumerate(day_places):
                daily_plan['places'].append({
                    'id': str(place.get('id', i)),
                    'name': place['name'],
                    'description': place.get('description', f"{place['name']}에서의 시간을 즐겨보세요."),
                    'imageUrl': place.get('image_url', ''),
                    'latitude': place['latitude'],
                    'longitude': place['longitude'],
                    'visitDuration': place.get('visit_duration', 60),
                    'rating': place['rating'],
                    'order': i + 1,
                    'visitTime': self._suggest_visit_time(i, place),
                    'category': place.get('category', '관광지'),
                    'tips': self._generate_visit_tips(place),
                })
            
            daily_plans.append(daily_plan)
        
        # 최종 여행 계획 생성
        trip_plan = {
            'id': f'ai-trip-{plan_id}',
            'title': f'{location} {duration_days}일 여행 코스',
            'description': f'{location}에서의 {duration_days}일 {style_description}. 당신의 선호도에 맞춘 맞춤형 여행 계획입니다.',
            'imageUrl': sorted_places[0].get('image_url', '') if sorted_places else '',
            'rating': 4.8,
            'duration': duration_days * 24 * 60,  # 분 단위로 표현
            'tags': self._generate_trip_tags(preferences, location, travel_style, with_who),
            'places': self._flatten_daily_places(daily_plans),  # 일별 계획의 장소들을 하나의 리스트로 병합
        }
        
        return trip_plan
        
    def _flatten_daily_places(self, daily_plans):
        """일별 계획의 장소들을 하나의 리스트로 병합"""
        places = []
        for daily_plan in daily_plans:
            places.extend(daily_plan['places'])
        return places
        
    def _get_style_description(self, travel_style, with_who):
        """여행 스타일 문구 생성"""
        style_text = ""
        
        if travel_style == '여유':
            style_text = "여유로운 일정"
        elif travel_style == '효율':
            style_text = "효율적인 일정"
        else:
            style_text = "균형 잡힌 일정"
            
        who_text = ""
        if with_who == '혼자':
            who_text = "나 홀로"
        elif with_who == '친구':
            who_text = "친구와 함께하는"
        elif with_who == '연인':
            who_text = "연인과 함께하는"
        elif with_who == '가족':
            who_text = "가족과 함께하는"
        else:
            who_text = ""
            
        return f"{who_text} {style_text}"
    
    def _sort_places_by_time(self, places):
        """방문 시간순으로 장소 정렬"""
        # 방문 순서: 아침(관광지) -> 점심(음식점) -> 오후(관광지/쇼핑) -> 저녁(음식점) -> 밤(카페)
        
        # 카테고리별 그룹화
        attractions = [p for p in places if p.get('category') == '관광지' or p.get('category') == '반려동물 동반']
        restaurants = [p for p in places if p.get('category') == '음식점']
        cafes = [p for p in places if p.get('category') == '카페']
        shopping = [p for p in places if p.get('category') == '쇼핑']
        others = [p for p in places if p.get('category') not in ['관광지', '음식점', '카페', '쇼핑', '반려동물 동반']]
        
        # 식사 장소가 2개 이상이면 점심/저녁으로 나누기
        lunch = []
        dinner = []
        if len(restaurants) >= 2:
            lunch = [restaurants[0]]
            dinner = [restaurants[1]]
            restaurants = restaurants[2:]
        elif len(restaurants) == 1:
            lunch = [restaurants[0]]
            restaurants = []
        
        # 시간별 정렬
        morning = attractions[:1]
        afternoon = attractions[1:2] + shopping[:1] + others[:1]
        evening = shopping[1:2] + cafes[:1]
        night = cafes[1:] + restaurants
        
        # 최종 정렬된 장소 목록
        sorted_places = morning + lunch + afternoon + dinner + evening + night
        
        # 모든 장소가 포함되었는지 확인하고 누락된 것 추가
        all_sorted_ids = [p.get('id') for p in sorted_places]
        for place in places:
            if place.get('id') not in all_sorted_ids:
                sorted_places.append(place)
        
        return sorted_places
    
    def _suggest_visit_time(self, order, place):
        """방문 시간 추천"""
        category = place.get('category', '관광지')
        
        if order == 0:
            return "09:00 ~ 11:00"
        elif order == 1 and category == '음식점':
            return "12:00 ~ 13:30"
        elif order == 2:
            return "14:00 ~ 16:00"
        elif order == 3 and category == '음식점':
            return "18:00 ~ 19:30"
        elif order == 4:
            return "20:00 ~ 21:30"
        else:
            return "시간 미정"
    
    def _generate_daily_description(self, places, day, location):
        """일별 여행 설명 생성"""
        categories = [p.get('category', '장소') for p in places]
        
        # 카테고리별 개수 계산
        category_counts = {}
        for category in categories:
            if category in category_counts:
                category_counts[category] += 1
            else:
                category_counts[category] = 1
        
        # 설명 생성
        description = f"Day {day}: {location}의 "
        
        category_texts = []
        for category, count in category_counts.items():
            if count > 0:
                category_texts.append(f"{category} {count}곳")
        
        if category_texts:
            description += ", ".join(category_texts)
        else:
            description += "다양한 명소"
        
        description += "를 방문하는 일정입니다."
        
        return description
    
    def _generate_visit_tips(self, place):
        """방문 팁 생성"""
        category = place.get('category', '관광지')
        
        tips = []
        
        if category == '관광지':
            tips = [
                "방문 전 영업시간을 확인하세요.",
                "주차 공간이 제한적일 수 있으니 대중교통 이용을 추천합니다.",
                "사진 촬영 금지 구역을 확인하세요."
            ]
        elif category == '음식점':
            tips = [
                "예약을 추천합니다.",
                "피크 시간을 피해 방문하면 대기 시간을 줄일 수 있습니다.",
                "인기 메뉴를 미리 확인해보세요."
            ]
        elif category == '카페':
            tips = [
                "와이파이가 제공됩니다.",
                "디저트와 함께 주문하면 더 좋습니다.",
                "창가 자리에서 뷰를 감상해보세요."
            ]
        elif category == '쇼핑':
            tips = [
                "세일 기간을 확인해보세요.",
                "현금보다 카드 결제가 편리합니다.",
                "기념품 코너를 놓치지 마세요."
            ]
        elif category == '반려동물 동반':
            tips = [
                "반려동물 리드줄 지참은 필수입니다.",
                "반려동물 용품을 미리 준비하세요.",
                "다른 방문객들을 위해 배변 봉투를 챙겨가세요."
            ]
        else:
            tips = [
                "미리 정보를 찾아보고 방문하면 더욱 즐겁습니다.",
                "주변 명소도 함께 둘러보세요.",
                "리뷰를 참고하면 도움이 됩니다."
            ]
        
        # 랜덤으로 팁 2개 선택
        if len(tips) > 2:
            selected_tips = random.sample(tips, 2)
        else:
            selected_tips = tips
            
        return selected_tips
    
    def _generate_trip_tags(self, preferences, location, travel_style, with_who):
        """여행 태그 생성"""
        tags = [location]
        
        # 여행 스타일 태그
        if travel_style == '여유':
            tags.append('슬로우트래블')
        elif travel_style == '효율':
            tags.append('효율여행')
        
        # 동반자 태그
        if with_who == '혼자':
            tags.append('나홀로여행')
        elif with_who == '친구':
            tags.append('우정여행')
        elif with_who == '연인':
            tags.append('커플여행')
        elif with_who == '가족':
            tags.append('가족여행')
        
        # 선호도 태그
        if 'famous' in preferences:
            tags.append('인기명소')
        if 'kids' in preferences:
            tags.append('키즈존')
        if 'pet' in preferences:
            tags.append('반려동물')
        if 'cafe' in preferences:
            tags.append('카페투어')
        if 'food' in preferences:
            tags.append('맛집탐방')
        
        return tags


class DbSearchPlacesView(APIView):
    """
    데이터베이스 기반 장소 검색 API
    GET 및 POST 메서드 지원
    """
    permission_classes = [AllowAny]
    
    def get(self, request):
        """
        GET 메서드로 장소 검색
        """
        # 쿼리 파라미터에서 필요한 데이터 추출
        keyword = request.query_params.get('keyword', '')
        user_type = request.query_params.get('user_type', '')
        
        # 필터링 옵션
        is_drive_course = request.query_params.get('is_drive_course') == 'true'
        is_no_kids_zone = request.query_params.get('is_no_kids_zone') == 'true'
        is_kids_zone = request.query_params.get('is_kids_zone') == 'true'
        is_pet_zone = request.query_params.get('is_pet_zone') == 'true'
        max_travel_time = request.query_params.get('max_travel_time')
        categories = request.query_params.getlist('categories') if request.query_params.getlist('categories') else []
        sort_by = request.query_params.get('sort_by', 'popularity')
        
        try:
            # 1. 기본 장소 데이터 수집 (키워드 기반)
            places_data = self._collect_place_data(keyword)
            
            # 2. 필터링 적용
            if is_kids_zone:
                # 키즈존은 가족 여행에 적합
                pass
                
            if is_no_kids_zone:
                # 노키즈존은 연인/혼자 여행에 적합
                pass
                
            if is_pet_zone:
                # 반려동물 동반 장소 우선
                places_data = [p for p in places_data if p['category'] == '반려동물 동반'] + [p for p in places_data if p['category'] != '반려동물 동반']
            
            if is_drive_course:
                # 드라이브 코스 우선
                places_data = [p for p in places_data if 'attr_' in p['id']] + [p for p in places_data if 'attr_' not in p['id']]
                
            # 카테고리 필터링
            if categories:
                filtered_places = []
                for place in places_data:
                    category = place.get('category', '').lower()
                    if any(c.lower() in category for c in categories):
                        filtered_places.append(place)
                places_data = filtered_places if filtered_places else places_data
            
            # 여행 시간 필터
            if max_travel_time:
                # 실제 이동 시간 계산은 복잡하므로 여기서는 생략
                pass
                
            # 3. 정렬 적용
            if sort_by == 'rating':
                places_data.sort(key=lambda x: x['rating'], reverse=True)
            elif sort_by == 'review_count':
                # 리뷰 카운트가 없으므로 평점으로 대체
                places_data.sort(key=lambda x: x['rating'], reverse=True)
            elif sort_by == 'distance':
                # 거리 정보가 없으므로 기본 정렬 유지
                pass
            
            # 4. Place 모델 형식으로 변환
            results = []
            for place in places_data:
                # 카테고리 매핑
                category_name = place.get('category', '기타')
                categories = [category_name]
                
                if '관광지' in category_name:
                    categories.append('자연')
                if '음식점' in category_name:
                    categories.append('맛집')
                    
                # ID 처리
                place_id = place.get('id', '')
                
                # 장소 객체 생성
                place_obj = {
                    'id': place_id,
                    'name': place.get('name', ''),
                    'description': place.get('description', ''),
                    'imageUrl': place.get('image_url', ''),
                    'latitude': place.get('latitude', 0),
                    'longitude': place.get('longitude', 0),
                    'address': place.get('address', ''),
                    'categories': categories,
                    'rating': place.get('rating', 4.0),
                    'reviewCount': random.randint(10, 200),  # 임시 리뷰 수
                    'is_drive_course': 'attr_' in place_id,
                    'is_kids_zone': 'pet_' not in place_id and 'food_' not in place_id,
                    'is_no_kids_zone': 'food_' in place_id,
                    'is_pet_zone': 'pet_' in place_id,
                    'travel_time': random.randint(10, 60),  # 임시 이동 시간
                }
                
                results.append(place_obj)
            
            # 사용자 타입별 정렬
            if user_type == 'alone':
                # 혼자 여행에는 카페, 관광지 등 추천
                results.sort(key=lambda x: 1 if 'pet_' in x['id'] or ('카페' in x['categories']) else 2)
            elif user_type == 'couple':
                # 커플 여행에는 카페, 식당 등 추천
                results.sort(key=lambda x: 1 if 'food_' in x['id'] or ('카페' in x['categories']) else 2)
            elif user_type == 'family':
                # 가족 여행에는 관광지, 키즈존 등 추천
                results.sort(key=lambda x: 1 if 'attr_' in x['id'] and x['is_kids_zone'] else 2)
            elif user_type == 'friends':
                # 친구 여행에는 맛집, 액티비티 등 추천
                results.sort(key=lambda x: 1 if 'food_' in x['id'] or ('관광지' in x['categories']) else 2)
            
            # 결과를 맵 형태로 감싸서 반환
            response_data = {
                'results': results,
                'count': len(results),
                'page': 1,
                'pageSize': len(results),
                'hasMore': False
            }
            
            return Response(
                response_data,
                status=status.HTTP_200_OK,
                content_type='application/json; charset=utf-8'
            )
            
        except Exception as e:
            logger.error(f"데이터베이스 장소 검색 오류: {str(e)}")
            return Response(
                {'error': f'장소 검색 중 오류가 발생했습니다: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def post(self, request):
        """
        POST 메서드로 장소 검색
        """
        # 요청에서 필요한 데이터 추출
        keyword = request.data.get('keyword', '')
        user_type = request.data.get('user_type', '')
        
        # 필터링 옵션
        is_drive_course = request.data.get('is_drive_course', False)
        is_no_kids_zone = request.data.get('is_no_kids_zone', False)
        is_kids_zone = request.data.get('is_kids_zone', False)
        is_pet_zone = request.data.get('is_pet_zone', False)
        max_travel_time = request.data.get('max_travel_time')
        categories = request.data.get('categories', [])
        sort_by = request.data.get('sort_by', 'popularity')
        
        try:
            # 1. 기본 장소 데이터 수집 (키워드 기반)
            places_data = self._collect_place_data(keyword)
            
            # 2. 필터링 적용
            if is_kids_zone:
                # 키즈존은 가족 여행에 적합
                pass
                
            if is_no_kids_zone:
                # 노키즈존은 연인/혼자 여행에 적합
                pass
                
            if is_pet_zone:
                # 반려동물 동반 장소 우선
                places_data = [p for p in places_data if p['category'] == '반려동물 동반'] + [p for p in places_data if p['category'] != '반려동물 동반']
            
            if is_drive_course:
                # 드라이브 코스 우선
                places_data = [p for p in places_data if 'attr_' in p['id']] + [p for p in places_data if 'attr_' not in p['id']]
                
            # 카테고리 필터링
            if categories:
                filtered_places = []
                for place in places_data:
                    category = place.get('category', '').lower()
                    if any(c.lower() in category for c in categories):
                        filtered_places.append(place)
                places_data = filtered_places if filtered_places else places_data
            
            # 여행 시간 필터
            if max_travel_time:
                # 실제 이동 시간 계산은 복잡하므로 여기서는 생략
                pass
                
            # 3. 정렬 적용
            if sort_by == 'rating':
                places_data.sort(key=lambda x: x['rating'], reverse=True)
            elif sort_by == 'review_count':
                # 리뷰 카운트가 없으므로 평점으로 대체
                places_data.sort(key=lambda x: x['rating'], reverse=True)
            elif sort_by == 'distance':
                # 거리 정보가 없으므로 기본 정렬 유지
                pass
            
            # 4. Place 모델 형식으로 변환
            results = []
            for place in places_data:
                # 카테고리 매핑
                category_name = place.get('category', '기타')
                categories = [category_name]
                
                if '관광지' in category_name:
                    categories.append('자연')
                if '음식점' in category_name:
                    categories.append('맛집')
                    
                # ID 처리
                place_id = place.get('id', '')
                
                # 장소 객체 생성
                place_obj = {
                    'id': place_id,
                    'name': place.get('name', ''),
                    'description': place.get('description', ''),
                    'imageUrl': place.get('image_url', ''),
                    'latitude': place.get('latitude', 0),
                    'longitude': place.get('longitude', 0),
                    'address': place.get('address', ''),
                    'categories': categories,
                    'rating': place.get('rating', 4.0),
                    'reviewCount': random.randint(10, 200),  # 임시 리뷰 수
                    'is_drive_course': 'attr_' in place_id,
                    'is_kids_zone': 'pet_' not in place_id and 'food_' not in place_id,
                    'is_no_kids_zone': 'food_' in place_id,
                    'is_pet_zone': 'pet_' in place_id,
                    'travel_time': random.randint(10, 60),  # 임시 이동 시간
                }
                
                results.append(place_obj)
            
            # 사용자 타입별 정렬
            if user_type == 'alone':
                # 혼자 여행에는 카페, 관광지 등 추천
                results.sort(key=lambda x: 1 if 'pet_' in x['id'] or ('카페' in x['categories']) else 2)
            elif user_type == 'couple':
                # 커플 여행에는 카페, 식당 등 추천
                results.sort(key=lambda x: 1 if 'food_' in x['id'] or ('카페' in x['categories']) else 2)
            elif user_type == 'family':
                # 가족 여행에는 관광지, 키즈존 등 추천
                results.sort(key=lambda x: 1 if 'attr_' in x['id'] and x['is_kids_zone'] else 2)
            elif user_type == 'friends':
                # 친구 여행에는 맛집, 액티비티 등 추천
                results.sort(key=lambda x: 1 if 'food_' in x['id'] or ('관광지' in x['categories']) else 2)
            
            # 결과를 맵 형태로 감싸서 반환
            response_data = {
                'results': results,
                'count': len(results),
                'page': 1,
                'pageSize': len(results),
                'hasMore': False
            }
            
            return Response(
                response_data,
                status=status.HTTP_200_OK,
                content_type='application/json; charset=utf-8'
            )
            
        except Exception as e:
            logger.error(f"데이터베이스 장소 검색 오류: {str(e)}")
            return Response(
                {'error': f'장소 검색 중 오류가 발생했습니다: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _collect_place_data(self, keyword):
        """키워드 기반 장소 데이터 수집"""
        places_data = []
        
        # 관광지 데이터 수집
        query = Attraction.objects.all()
        if keyword:
            query = query.filter(title__icontains=keyword) | query.filter(addr1__icontains=keyword)
        
        attractions = query[:20]
        for place in attractions:
            places_data.append({
                'id': f'attr_{place.id}',
                'name': place.title,
                'description': f"{place.title}은(는) {place.addr1}에 위치한 관광 명소입니다.",
                'image_url': place.image or '',
                'latitude': float(place.mapy) if place.mapy else 0,
                'longitude': float(place.mapx) if place.mapx else 0,
                'address': place.addr1,
                'contact': place.tel,
                'opening_hours': '09:00 - 18:00',  # 기본값
                'rating': 4.0 + round(random.random() * 1.0, 1),  # 4.0-5.0 사이 랜덤값
                'visit_duration': 120,  # 기본값 2시간
                'category': '관광지',
            })
        
        # 음식점 데이터 수집
        query = Food.objects.all()
        if keyword:
            query = query.filter(title__icontains=keyword) | query.filter(addr1__icontains=keyword)
        
        foods = query[:10]
        for place in foods:
            places_data.append({
                'id': f'food_{place.id}',
                'name': place.title,
                'description': f"{place.title}은(는) {place.addr1}에 위치한 음식점입니다.",
                'image_url': place.image or '',
                'latitude': float(place.mapy) if place.mapy else 0,
                'longitude': float(place.mapx) if place.mapx else 0,
                'address': place.addr1,
                'contact': place.tel,
                'opening_hours': '11:00 - 21:00',  # 기본값
                'rating': 4.0 + round(random.random() * 1.0, 1),  # 4.0-5.0 사이 랜덤값
                'visit_duration': 90,  # 기본값 1시간 30분
                'category': '음식점',
            })
        
        # 반려동물 동반 여행지
        query = PetTour.objects.all()
        if keyword:
            query = query.filter(title__icontains=keyword) | query.filter(addr1__icontains=keyword)
            
        pet_places = query[:10]
        for place in pet_places:
            places_data.append({
                'id': f'pet_{place.id}',
                'name': place.title,
                'description': f"{place.title}은(는) {place.addr1}에 위치한 반려동물 동반 가능 장소입니다.",
                'image_url': place.firstimage or '',
                'latitude': float(place.mapy) if place.mapy else 0,
                'longitude': float(place.mapx) if place.mapx else 0,
                'address': place.addr1,
                'contact': place.tel,
                'opening_hours': '09:00 - 18:00',  # 기본값
                'rating': 4.0 + round(random.random() * 1.0, 1),  # 4.0-5.0 사이 랜덤값
                'visit_duration': 120,  # 기본값 2시간
                'category': '반려동물 동반',
            })
                
        # 충분한 결과가 없을 경우 카카오 API로 추가 데이터 수집
        if len(places_data) < 10:
            kakao_service = KakaoApiService()
            search_result = kakao_service.search_places(query=keyword if keyword else "명소", size=10)
            documents = search_result.get('documents', [])
            
            for place in documents:
                # 장소 데이터 가공
                rating = round(4.0 + random.random() * 0.7, 1)
                
                if place.get('y') and place.get('x'):
                    category = self._categorize_place(place.get('category_name', ''))
                    places_data.append({
                        'id': f"kakao_{place.get('id', '')}",
                        'name': place.get('place_name', ''),
                        'description': f"{place.get('place_name', '')}은(는) {place.get('address_name', '')}에 위치한 {place.get('category_name', '')}입니다.",
                        'image_url': '',  # 카카오 API는 이미지 URL을 제공하지 않음
                        'latitude': float(place.get('y', 0)),
                        'longitude': float(place.get('x', 0)),
                        'address': place.get('address_name', ''),
                        'contact': place.get('phone', ''),
                        'opening_hours': '09:00 - 18:00',  # 기본값
                        'rating': rating,
                        'visit_duration': self._estimate_visit_duration(place.get('category_name', '')),
                        'category': category,
                    })
        
        return places_data
    
    def _categorize_place(self, category_name):
        """카테고리 분류"""
        category_name = category_name.lower() if category_name else ''
        
        if '카페' in category_name:
            return '카페'
        elif '음식점' in category_name or '식당' in category_name:
            return '음식점'
        elif '관광' in category_name or '명소' in category_name:
            return '관광지'
        elif '쇼핑' in category_name:
            return '쇼핑'
        elif '숙박' in category_name:
            return '숙소'
        else:
            return '기타'
    
    def _estimate_visit_duration(self, category_name):
        """방문 시간 추정"""
        category_name = category_name.lower() if category_name else ''
        
        if '카페' in category_name:
            return 60  # 카페: 1시간
        elif '음식점' in category_name or '식당' in category_name:
            return 90  # 음식점: 1시간 30분
        elif '관광' in category_name or '명소' in category_name:
            return 120  # 관광지: 2시간
        elif '쇼핑' in category_name:
            return 120  # 쇼핑: 2시간
        else:
            return 60  # 기본값: 1시간