class Trip {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final int duration; // 분 단위
  final double rating;
  final TripType type;
  final List<Attraction> attractions;

  // 추가 필드
  final bool isDriveCourse;
  final bool isNoKidsZone;
  final bool isKidsZone;
  final bool isPetZone;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.duration,
    required this.rating,
    required this.type,
    required this.attractions,
    this.isDriveCourse = false,
    this.isNoKidsZone = false,
    this.isKidsZone = false,
    this.isPetZone = false,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      duration: json['duration'],
      rating: json['rating'].toDouble(),
      type: TripTypeExtension.fromString(json['type']),
      attractions: (json['attractions'] as List?)
          ?.map((item) => Attraction.fromJson(item))
          .toList() ?? [],
      // 추가 필드 매핑
      isDriveCourse: json['is_drive_course'] ?? false,
      isNoKidsZone: json['is_no_kids_zone'] ?? false,
      isKidsZone: json['is_kids_zone'] ?? false,
      isPetZone: json['is_pet_zone'] ?? false,
    );
  }
}

class Attraction {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final int visitDuration; // 분 단위
  final double rating;

  Attraction({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.visitDuration,
    required this.rating,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      visitDuration: json['visitDuration'],
      rating: json['rating'].toDouble(),
    );
  }
}

enum TripType { solo, couple, family, friends }

extension TripTypeExtension on TripType {
  String get displayName {
    switch (this) {
      case TripType.solo:
        return '혼자';
      case TripType.couple:
        return '연인';
      case TripType.family:
        return '가족';
      case TripType.friends:
        return '친구';
    }
  }

  static TripType fromString(String type) {
    switch (type) {
      case 'solo':
        return TripType.solo;
      case 'couple':
        return TripType.couple;
      case 'family':
        return TripType.family;
      case 'friends':
        return TripType.friends;
      default:
        return TripType.solo;
    }
  }
}