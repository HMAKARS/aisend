import 'place.dart';

class TripPlan {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<TripStop> stops;
  final int totalTravelTime; // 총 소요 시간(분)
  final double totalDistance; // 총 거리(km)
  final double rating; // 평점
  final int reviewCount; // 리뷰 수
  
  // 여행 유형 관련 필드
  final bool isDriveCourse;
  final bool isNoKidsZone;
  final bool isKidsZone;
  final bool isPetZone;
  
  // 추천 여행 계획 유형
  final List<String> recommendedFor; // [alone, couple, family, friends]
  
  // 키워드/특성
  final List<String> keywords;

  TripPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.stops,
    required this.totalTravelTime,
    required this.totalDistance,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isDriveCourse = false,
    this.isNoKidsZone = false,
    this.isKidsZone = false,
    this.isPetZone = false,
    this.recommendedFor = const [],
    this.keywords = const [],
  });
  
  // 공장 메서드
  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      stops: (json['stops'] as List).map((stop) => TripStop.fromJson(stop)).toList(),
      totalTravelTime: json['totalTravelTime'],
      totalDistance: json['totalDistance'],
      rating: json['rating'] ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isDriveCourse: json['isDriveCourse'] ?? false,
      isNoKidsZone: json['isNoKidsZone'] ?? false,
      isKidsZone: json['isKidsZone'] ?? false,
      isPetZone: json['isPetZone'] ?? false,
      recommendedFor: List<String>.from(json['recommendedFor'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'totalTravelTime': totalTravelTime,
      'totalDistance': totalDistance,
      'rating': rating,
      'reviewCount': reviewCount,
      'isDriveCourse': isDriveCourse,
      'isNoKidsZone': isNoKidsZone,
      'isKidsZone': isKidsZone,
      'isPetZone': isPetZone,
      'recommendedFor': recommendedFor,
      'keywords': keywords,
    };
  }
}

class TripStop {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> categories;
  final double rating;
  final int travelTimeFromPrevious; // 이전 장소로부터의 소요 시간(분)
  final double distanceFromPrevious; // 이전 장소로부터의 거리(km)
  final Map<String, dynamic> openingHours;
  final List<String> facilities;
  final String stopType; // 'intermediate' 또는 'destination'
  
  TripStop({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.categories,
    this.rating = 0.0,
    this.travelTimeFromPrevious = 0,
    this.distanceFromPrevious = 0.0,
    this.openingHours = const {},
    this.facilities = const [],
    this.stopType = 'intermediate',
  });
  
  factory TripStop.fromJson(Map<String, dynamic> json) {
    return TripStop(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      categories: List<String>.from(json['categories'] ?? []),
      rating: json['rating'] ?? 0.0,
      travelTimeFromPrevious: json['travelTimeFromPrevious'] ?? 0,
      distanceFromPrevious: json['distanceFromPrevious'] ?? 0.0,
      openingHours: json['openingHours'] ?? {},
      facilities: List<String>.from(json['facilities'] ?? []),
      stopType: json['stopType'] ?? 'intermediate',
    );
  }
  
  factory TripStop.fromPlace(Place place, {
    int travelTimeFromPrevious = 0,
    double distanceFromPrevious = 0.0,
    String stopType = 'intermediate'
  }) {
    return TripStop(
      id: place.id,
      name: place.name,
      description: place.description,
      imageUrl: place.imageUrl,
      latitude: place.latitude,
      longitude: place.longitude,
      address: place.address,
      categories: place.categories,
      rating: place.rating,
      travelTimeFromPrevious: travelTimeFromPrevious,
      distanceFromPrevious: distanceFromPrevious,
      openingHours: place.openingHours,
      facilities: place.facilities,
      stopType: stopType,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'categories': categories,
      'rating': rating,
      'travelTimeFromPrevious': travelTimeFromPrevious,
      'distanceFromPrevious': distanceFromPrevious,
      'openingHours': openingHours,
      'facilities': facilities,
      'stopType': stopType,
    };
  }
}