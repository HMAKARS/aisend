import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../widgets/attraction_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/trip_service.dart';

class MapScreen extends StatefulWidget {
  final List<Attraction>? attractions;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? title;

  const MapScreen({
    super.key, 
    this.attractions,
    this.initialLatitude,
    this.initialLongitude,
    this.title,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  int _selectedAttractionIndex = -1;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  List<Attraction> _attractions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttractions();
  }

  @override
  void dispose() {
    // 지도 컨트롤러 리소스 해제
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAttractions() async {
    if (widget.attractions != null) {
      setState(() {
        _attractions = widget.attractions!;
        _isLoading = false;
      });
    } else {
      // 바텀 네비게이션에서 진입한 경우 - 모든 여행 코스의 관광지 로드
      try {
        final trips = await TripService().getAllTrips();
        final allAttractions = <Attraction>[];
        
        for (var trip in trips) {
          allAttractions.addAll(trip.attractions);
        }
        
        setState(() {
          _attractions = allAttractions;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')),
          );
        }
      }
    }
  }

  Set<Marker> _createMarkers() {
    return _attractions.asMap().entries.map((entry) {
      final index = entry.key;
      final attraction = entry.value;
      return Marker(
        markerId: MarkerId(attraction.id),
        position: LatLng(attraction.latitude, attraction.longitude),
        infoWindow: InfoWindow(
          title: attraction.name,
          snippet: '${attraction.visitDuration}분 소요',
        ),
        onTap: () {
          setState(() {
            _selectedAttractionIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(attraction.latitude, attraction.longitude),
            ),
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('내 주변'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_attractions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('내 주변'),
        ),
        body: const Center(
          child: Text('주변 여행지 정보가 없습니다.'),
        ),
      );
    }

    // 지도 초기 카메라 위치
    final CameraPosition initialPosition;
    
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      // 특정 위치가 제공된 경우
      initialPosition = CameraPosition(
        target: LatLng(widget.initialLatitude!, widget.initialLongitude!),
        zoom: 15, // 좀 더 가깝게 줌
      );
    } else if (_attractions.isNotEmpty) {
      // 관광지 목록이 있는 경우 중심점 계산
      final avgLat = _attractions.map((a) => a.latitude).reduce((a, b) => a + b) / _attractions.length;
      final avgLng = _attractions.map((a) => a.longitude).reduce((a, b) => a + b) / _attractions.length;
      initialPosition = CameraPosition(
        target: LatLng(avgLat, avgLng),
        zoom: 12,
      );
    } else {
      // 기본값 (서울 시청)
      initialPosition = const CameraPosition(
        target: LatLng(37.5665, 126.9780),
        zoom: 12,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '내 주변'),
      ),
      body: Stack(
        children: [
          // 지도
          Positioned.fill(
            child: _attractions.isNotEmpty
              ? GoogleMap(
                  initialCameraPosition: initialPosition,
                  markers: _createMarkers(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                )
              : const Center(child: Text('지도를 불러올 수 없습니다.')),
          ),
          
          // 하단 관광지 카드 슬라이더
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _attractions.length,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedAttractionIndex = index;
                  });
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        _attractions[index].latitude,
                        _attractions[index].longitude,
                      ),
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final attraction = _attractions[index];
                  return AttractionCard(
                    attraction: attraction,
                    isSelected: index == _selectedAttractionIndex,
                    onTap: () {
                      // 관광지 상세 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${attraction.name} 상세 정보는 아직 준비중입니다.')),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 경로 안내 시작 (나중에 구현)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('경로 안내 기능은 아직 준비중입니다.')),
          );
        },
        label: const Text('경로 안내'),
        icon: const Icon(Icons.directions),
      ),
    );
  }
}