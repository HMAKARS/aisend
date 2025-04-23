import 'place.dart';

enum TripType {
  solo,      // 혼자
  couple,    // 연인
  family,    // 가족
  friends,   // 친구
}

extension TripTypeExtension on TripType {
  String get displayName {
    switch (this) {
      case TripType.solo:
        return '혼자여행';
      case TripType.couple:
        return '연인과 함께';
      case TripType.family:
        return '가족여행';
      case TripType.friends:
        return '친구와 함께';
    }
  }
  
  String get iconName {
    switch (this) {
      case TripType.solo:
        return 'person';
      case TripType.couple:
        return 'favorite';
      case TripType.family:
        return 'family_restroom';
      case TripType.friends:
        return 'groups';
    }
  }
}

class CourseStop {
  final Place place;
  final int duration; // 분 단위로 체류 시간
  final String note;

  CourseStop({
    required this.place,
    required this.duration,
    this.note = '',
  });

  factory CourseStop.fromJson(Map<String, dynamic> json, List<Place> allPlaces) {
    // allPlaces에서 id로 Place 찾기
    Place place = allPlaces.firstWhere(
      (p) => p.id == json['placeId'],
      orElse: () => Place(
        id: json['placeId'],
        name: '알 수 없는 장소',
        description: '',
        imageUrl: '',
        latitude: 0,
        longitude: 0,
        address: '',
        categories: [],
      ),
    );
    
    return CourseStop(
      place: place,
      duration: json['duration'],
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': place.id,
      'duration': duration,
      'note': note,
    };
  }
}

class TripCourse {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final TripType tripType;
  final String region;
  final List<CourseStop> stops;
  final int totalDuration; // 분 단위로 총 소요 시간
  final double rating;
  final int reviewCount;
  final bool isOfficial; // 공식 코스 여부
  final DateTime createdAt;

  TripCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tripType,
    required this.region,
    required this.stops,
    required this.totalDuration,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isOfficial = false,
    required this.createdAt,
  });

  factory TripCourse.fromJson(Map<String, dynamic> json, List<Place> allPlaces) {
    List<CourseStop> stops = [];
    if (json['stops'] != null) {
      stops = (json['stops'] as List)
          .map((stop) => CourseStop.fromJson(stop, allPlaces))
          .toList();
    }
    
    return TripCourse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      tripType: TripType.values.firstWhere(
        (type) => type.toString() == 'TripType.${json['tripType']}',
        orElse: () => TripType.solo,
      ),
      region: json['region'],
      stops: stops,
      totalDuration: json['totalDuration'],
      rating: json['rating'] ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isOfficial: json['isOfficial'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'tripType': tripType.toString().split('.').last,
      'region': region,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'totalDuration': totalDuration,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOfficial': isOfficial,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
