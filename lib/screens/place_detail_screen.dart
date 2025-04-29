import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import 'map_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;

  const PlaceDetailScreen({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 장소 상세 정보 로드
    Future.microtask(() {
      Provider.of<PlaceProvider>(context, listen: false)
          .getPlaceDetails(widget.placeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PlaceProvider>(
        builder: (context, placeProvider, child) {
          if (placeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (placeProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '오류가 발생했습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeProvider.error,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('돌아가기'),
                  ),
                ],
              ),
            );
          }

          final place = placeProvider.selectedPlace;
          if (place == null) {
            return const Center(child: Text('장소 정보를 찾을 수 없습니다'));
          }

          return _buildPlaceDetail(place);
        },
      ),
    );
  }

  Widget _buildPlaceDetail(Place place) {
    return CustomScrollView(
      slivers: [
        // 앱바
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              place.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${place.name}이(가) 찜 목록에 추가되었습니다')),
                  );
                },
              ),
            ),
          ],
        ),

        // 콘텐츠
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 정보 섹션
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildTravelTimeBadge(place.travelTime),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: place.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 18.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${place.rating.toStringAsFixed(1)} (${place.reviewCount})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 특징 태그들
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (place.isDriveCourse)
                          _buildFeatureChip('드라이브', Icons.drive_eta, Colors.blue),
                        if (place.isNoKidsZone)
                          _buildFeatureChip('노키즈존', Icons.do_not_disturb, Colors.red),
                        if (place.isKidsZone)
                          _buildFeatureChip('키즈존', Icons.child_care, Colors.green),
                        if (place.isPetZone)
                          _buildFeatureChip('반려동물', Icons.pets, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),

              // 구분선
              Divider(color: Colors.grey[300], height: 1),

              // 지도 섹션
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('위치', Icons.map),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                initialLatitude: place.latitude,
                                initialLongitude: place.longitude,
                                title: place.name,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            const Center(
                              child: Text('지도 로딩 중...'),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '전체화면',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 길찾기 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        // 길찾기 기능 구현
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('길찾기 기능이 구현될 예정입니다')),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('길찾기'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 구분선
              Divider(color: Colors.grey[300], height: 1),

              // 설명 섹션
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('소개', Icons.info_outline),
                    const SizedBox(height: 12),
                    Text(
                      place.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 구분선
              Divider(color: Colors.grey[300], height: 1),

              // 편의시설 섹션
              if (place.facilities.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('편의시설', Icons.local_convenience_store),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.facilities
                            .map((facility) => _buildFacilityChip(facility))
                            .toList(),
                      ),
                    ],
                  ),
                ),

              // 영업시간 섹션
              if (place.openingHours.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('영업시간', Icons.access_time),
                      const SizedBox(height: 12),
                      // 여기에 영업시간 표시 위젯 (미구현)
                      Text(
                        '영업시간 정보가 제공될 예정입니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // 소요 시간 배지 위젯
  Widget _buildTravelTimeBadge(int minutes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(minutes),
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 특징 칩 위젯
  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 편의시설 칩 위젯
  Widget _buildFacilityChip(String facility) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        facility,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue[800],
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  // 소요 시간 형식화
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0 
          ? '$hours시간 $remainingMinutes분'
          : '$hours시간';
    }
  }
}