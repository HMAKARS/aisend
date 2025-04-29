// lib/models/tourism_spot.dart
class TourismSpot {
  final String id;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String firstImage; // 대표 이미지
  final String contentTypeId; // 관광지 유형

  TourismSpot({
    required this.id,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.firstImage,
    required this.contentTypeId,
  });

  factory TourismSpot.fromJson(Map<String, dynamic> json) {
    return TourismSpot(
      id: json['contentid'],
      title: json['title'],
      address: json['addr1'],
      latitude: double.parse(json['mapy']),
      longitude: double.parse(json['mapx']),
      firstImage: json['firstimage'] ?? '',
      contentTypeId: json['contenttypeid'],
    );
  }
}

class TourismSpotDetail {
  final String id;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String firstImage;
  final String overview;
  final String tel;
  final String homepage;
  final List<String> images;
  
  TourismSpotDetail({
    this.id = '',
    this.title = '',
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.firstImage = '',
    this.overview = '',
    this.tel = '',
    this.homepage = '',
    this.images = const [],
  });
  
  factory TourismSpotDetail.fromJson(Map<String, dynamic> json) {
    List<String> imageList = [];
    if (json['firstimage'] != null && json['firstimage'].isNotEmpty) {
      imageList.add(json['firstimage']);
    }
    if (json['firstimage2'] != null && json['firstimage2'].isNotEmpty) {
      imageList.add(json['firstimage2']);
    }
    
    return TourismSpotDetail(
      id: json['contentid'] ?? '',
      title: json['title'] ?? '',
      address: json['addr1'] ?? '',
      latitude: json['mapy'] != null ? double.tryParse(json['mapy']) ?? 0.0 : 0.0,
      longitude: json['mapx'] != null ? double.tryParse(json['mapx']) ?? 0.0 : 0.0,
      firstImage: json['firstimage'] ?? '',
      overview: json['overview'] ?? '',
      tel: json['tel'] ?? '',
      homepage: json['homepage'] ?? '',
      images: imageList,
    );
  }
}