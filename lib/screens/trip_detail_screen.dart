import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../providers/auth_provider.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.fetchTripDetail(widget.tripId);
      await tripProvider.fetchTripPlan(widget.tripId); // fetch recommended course
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TripProvider>(
        builder: (ctx, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (tripProvider.error.isNotEmpty) {
            return Center(child: Text('오류 발생: ${tripProvider.error}'));
          } else if (tripProvider.selectedTrip == null) {
            return const Center(child: Text('여행 정보를 찾을 수 없습니다.'));
          } else {
            final trip = tripProvider.selectedTrip!;
            final tripPlan = tripProvider.tripPlan;
            return CustomScrollView(
              slivers: [
                // 앱바
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(trip.title),
                    background: Image.network(
                      trip.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 상세 정보
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 기본 정보
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                trip.type.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: _getTypeColor(trip.type),
                            ),
                            const SizedBox(width: 8),
                            RatingBarIndicator(
                              rating: trip.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 18.0,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.rating.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 위치 및 소요 시간
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              trip.location,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${(trip.duration / 60).round()}시간 ${trip.duration % 60}분',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 여행 설명
                        Text(
                          '여행 소개',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trip.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (tripPlan != null) ...[
                          const SizedBox(height: 24),
                          Text('추천 장소', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Column(
                            children: (tripPlan['course'] as List<dynamic>).map((place) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(place['type'] == '카페'
                                      ? Icons.local_cafe
                                      : Icons.restaurant),
                                  title: Text(place['name']),
                                  subtitle: Text(
                                      '평점 ${place['rating']} / 주차: ${place['parking'] == true ? '가능' : '불가'}'),
                                  trailing: place['instagram_hot'] == true
                                      ? const Icon(Icons.whatshot, color: Colors.red)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        // 명소 목록
                        Text(
                          '방문 명소',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              final attraction = trip.attractions[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        attraction.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            attraction.name,
                                            style: Theme.of(context).textTheme.titleMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '소요시간: ${attraction.visitDuration}분',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: trip.attractions.length,
                            viewportFraction: 0.8,
                            scale: 0.9,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 지도
                        Text(
                          '여행 경로',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 300,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildMap(trip),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Consumer<TripProvider>(
        builder: (ctx, provider, _) {
          return FloatingActionButton.extended(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (!authProvider.isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그인이 필요합니다.')),
                );
                return;
              }

              final success = await provider.toggleFavorite(widget.tripId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '저장되었습니다.' : '저장 실패'),
                  ),
                );
              }
            },
            label: const Text('저장하기'),
            icon: const Icon(Icons.favorite_border), // 또는 상태에 따라 변경 가능
          );
        },
      ),
    );
  }

  Widget _buildMap(Trip trip) {
    return const Center(child: Text('카카오맵 경로 표시 예정'));
  }

  Color _getTypeColor(TripType type) {
    switch (type) {
      case TripType.solo:
        return Colors.blue;
      case TripType.couple:
        return Colors.red;
      case TripType.family:
        return Colors.green;
      case TripType.friends:
        return Colors.orange;
    }
  }
}