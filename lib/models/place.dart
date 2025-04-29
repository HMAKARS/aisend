class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic> openingHours;
  final List<String> facilities;
  
  // 추가 필드 (검색 필터링용)
  final bool isDriveCourse;
  final bool isKidsZone;
  final bool isNoKidsZone; 
  final bool isPetZone;
  final int travelTime; // 현재 위치에서의 소요 시간(분)

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.categories,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.openingHours = const {},
    this.facilities = const [],
    this.isDriveCourse = false,
    this.isKidsZone = false,
    this.isNoKidsZone = false,
    this.isPetZone = false,
    this.travelTime = 0,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      categories: List<String>.from(json['categories'] ?? []),
      rating: json['rating'] ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      openingHours: json['openingHours'] ?? {},
      facilities: List<String>.from(json['facilities'] ?? []),
      isDriveCourse: json['is_drive_course'] ?? false,
      isKidsZone: json['is_kids_zone'] ?? false,
      isNoKidsZone: json['is_no_kids_zone'] ?? false,
      isPetZone: json['is_pet_zone'] ?? false,
      travelTime: json['travel_time'] ?? 0,
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
      'reviewCount': reviewCount,
      'openingHours': openingHours,
      'facilities': facilities,
      'is_drive_course': isDriveCourse,
      'is_kids_zone': isKidsZone,
      'is_no_kids_zone': isNoKidsZone,
      'is_pet_zone': isPetZone,
      'travel_time': travelTime,
    };
  }
}