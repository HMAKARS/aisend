from django.test import TestCase
from .models import Attraction

class AttractionModelTests(TestCase):
    def setUp(self):
        Attraction.objects.create(
            name="테스트 장소",
            description="테스트 설명",
            latitude=37.5665,
            longitude=126.9780,
            address="서울시 중구",
            rating=4.5,
        )
    
    def test_attraction_creation(self):
        """관광 명소 생성 테스트"""
        attraction = Attraction.objects.get(name="테스트 장소")
        self.assertEqual(attraction.rating, 4.5)
        self.assertEqual(attraction.address, "서울시 중구")
