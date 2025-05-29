from django.urls import path
from .views import AttractionListView, AttractionDetailView, PlaceSearchView, LocationBasedTripView, AITripPlannerView, DbSearchPlacesView

app_name = 'attractions'

urlpatterns = [
    # 관광 명소 관련 API
    path('', AttractionListView.as_view(), name='attraction-list'),
    path('<int:pk>/', AttractionDetailView.as_view(), name='attraction-detail'),
    
    # 장소 검색 및 여행 계획 생성 API
    path('search/', PlaceSearchView.as_view(), name='place-search'),
    path('location-trip/', LocationBasedTripView.as_view(), name='location-based-trip'),
    
    # AI 여행 계획 생성 API
    path('ai-trip/', AITripPlannerView.as_view(), name='ai-trip-planner'),
    
    # 데이터베이스 기반 장소 검색 API
    path('places/search/', DbSearchPlacesView.as_view(), name='db-search-places'),
    
    # 플러터 앱에서 사용하는 추가 API 엔드포인트
    path('attractions/search/', DbSearchPlacesView.as_view(), name='attractions-search'),
    path('foods/search/', DbSearchPlacesView.as_view(), name='foods-search'),
]
