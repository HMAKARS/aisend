from rest_framework import serializers
from .models import Attraction

class AttractionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attraction
        fields = '__all__'
        
class TripPlanPlaceSerializer(serializers.Serializer):
    """여행 계획의 장소 정보 시리얼라이저"""
    id = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField()
    imageUrl = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()
    visitDuration = serializers.IntegerField()
    rating = serializers.FloatField()
    order = serializers.IntegerField()

class TripPlanSerializer(serializers.Serializer):
    """여행 계획 시리얼라이저"""
    id = serializers.CharField()
    title = serializers.CharField()
    description = serializers.CharField()
    imageUrl = serializers.CharField(required=False, allow_blank=True)
    rating = serializers.FloatField()
    duration = serializers.IntegerField()
    tags = serializers.ListField(child=serializers.CharField(), required=False)
    places = TripPlanPlaceSerializer(many=True)

class PlaceSerializer(serializers.Serializer):
    """장소 정보 시리얼라이저"""
    id = serializers.CharField()
    name = serializers.CharField()
    description = serializers.CharField(required=False, allow_blank=True)
    imageUrl = serializers.CharField(required=False, allow_blank=True)
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()
    address = serializers.CharField(required=False, allow_blank=True)
    categories = serializers.ListField(child=serializers.CharField(), required=False)
    rating = serializers.FloatField(required=False, default=0.0)
    reviewCount = serializers.IntegerField(required=False, default=0)
    is_drive_course = serializers.BooleanField(required=False, default=False)
    is_kids_zone = serializers.BooleanField(required=False, default=False)
    is_no_kids_zone = serializers.BooleanField(required=False, default=False)
    is_pet_zone = serializers.BooleanField(required=False, default=False)
    travel_time = serializers.IntegerField(required=False, default=0)
