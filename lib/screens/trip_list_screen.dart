import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart';

class TripListScreen extends StatefulWidget {
  final TripType tripType;

  const TripListScreen({Key? key, required this.tripType}) : super(key: key);

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 여행 목록 가져오기
    Future.microtask(() =>
        Provider.of<TripProvider>(context, listen: false)
            .fetchTripsByType(widget.tripType));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tripType.displayName} 여행 코스'),
      ),
      body: Consumer<TripProvider>(
        builder: (ctx, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (tripProvider.error.isNotEmpty) {
            return Center(child: Text('오류 발생: ${tripProvider.error}'));
          } else if (tripProvider.trips.isEmpty) {
            return const Center(child: Text('여행 코스가 없습니다.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: tripProvider.trips.length,
              itemBuilder: (ctx, index) {
                final trip = tripProvider.trips[index];
                return TripCard(
                  trip: trip,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailScreen(tripId: trip.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}