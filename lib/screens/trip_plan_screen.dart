import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:url_launcher/url_launcher.dart'; // 추가
import '../models/place.dart';
import '../config/config.dart';

class TripPlanScreen extends StatefulWidget {
  final Place mainPlace;

  const TripPlanScreen({Key? key, required this.mainPlace}) : super(key: key);

  @override
  State<TripPlanScreen> createState() => _TripPlanScreenState();
}

class _TripPlanScreenState extends State<TripPlanScreen> {
  final List<Marker> _markers = [];
  final List<LatLng> _path = [];

  final kakaoNativeKey = Config.kakaoNativeApiKey;
  Map<String, dynamic>? cafeInfo;
  Map<String, dynamic>? restaurantInfo;
  String? selectedMarkerId;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    _markers.add(Marker(
      markerId: 'main',
      latLng: LatLng(widget.mainPlace.latitude, widget.mainPlace.longitude),
      infoWindowContent: widget.mainPlace.name,
    ));
    _path.add(LatLng(widget.mainPlace.latitude, widget.mainPlace.longitude));

    await _searchNearbyPlaces();

    setState(() {});
  }

  Future<void> _searchNearbyPlaces() async {
    final headers = {
      'Authorization': 'KakaoAK $kakaoNativeKey',
    };

    final cafeResponse = await http.get(
      Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json?query=카페&x=${widget.mainPlace.longitude}&y=${widget.mainPlace.latitude}&radius=3000',
      ),
      headers: headers,
    );

    if (cafeResponse.statusCode == 200) {
      final cafeData = jsonDecode(cafeResponse.body);
      if (cafeData['documents'].isNotEmpty) {
        final cafe = cafeData['documents'][0];
        final cafeLat = double.parse(cafe['y']);
        final cafeLng = double.parse(cafe['x']);
        _markers.add(Marker(
          markerId: 'cafe',
          latLng: LatLng(cafeLat, cafeLng),
          infoWindowContent: cafe['place_name'],
        ));
        _path.add(LatLng(cafeLat, cafeLng));
        cafeInfo = cafe;
      }
    }

    final foodResponse = await http.get(
      Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json?query=맛집&x=${widget.mainPlace.longitude}&y=${widget.mainPlace.latitude}&radius=3000',
      ),
      headers: headers,
    );

    if (foodResponse.statusCode == 200) {
      final foodData = jsonDecode(foodResponse.body);
      if (foodData['documents'].isNotEmpty) {
        final restaurant = foodData['documents'][0];
        final restaurantLat = double.parse(restaurant['y']);
        final restaurantLng = double.parse(restaurant['x']);
        _markers.add(Marker(
          markerId: 'restaurant',
          latLng: LatLng(restaurantLat, restaurantLng),
          infoWindowContent: restaurant['place_name'],
        ));
        _path.add(LatLng(restaurantLat, restaurantLng));
        restaurantInfo = restaurant;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          KakaoMap(
            center: LatLng(widget.mainPlace.latitude, widget.mainPlace.longitude),
            currentLevel: 7,
            markers: _markers,
            polylines: [
              Polyline(
                polylineId: 'trip_path',
                points: _path,
                strokeColor: Colors.blue,
                strokeWidth: 4,
              ),
            ],
            onMarkerTap: (markerId, latLng, zoomLevel) {
              setState(() {
                selectedMarkerId = markerId;
              });
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10.0),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedMarkerId == 'cafe' && cafeInfo != null)
                      _buildPlaceDetailCard(cafeInfo!, '중간 목적지 (카페)')
                    else if (selectedMarkerId == 'restaurant' && restaurantInfo != null)
                      _buildPlaceDetailCard(restaurantInfo!, '최종 목적지 (맛집)')
                    else ...[
                      if (cafeInfo != null) _buildPlaceDetailCard(cafeInfo!, '중간 목적지 (카페)'),
                      if (restaurantInfo != null) _buildPlaceDetailCard(restaurantInfo!, '최종 목적지 (맛집)'),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceDetailCard(Map<String, dynamic> place, String title) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(place['place_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(place['road_address_name'] ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            if (place['phone'] != null && place['phone'] != '')
              Text('📞 ${place['phone']}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.directions_car, "출발", onPressed: () {
                  _navigateToPlace(place['y'], place['x']);
                }),
                _buildActionButton(Icons.flag, "도착", onPressed: () {
                  _openMapAtPlace(place['y'], place['x']);
                }),
                _buildActionButton(Icons.share, "공유"),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) => _buildMenuImageCard(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuImageCard(int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://via.placeholder.com/100'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _navigateToPlace(String lat, String lng) async {
    final url = Uri.parse('https://map.kakao.com/link/to/목적지,$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openMapAtPlace(String lat, String lng) async {
    final url = Uri.parse('https://map.kakao.com/link/map/목적지,$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}