import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Trip> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // 텍스트가 변경될 때마다 검색 로직 구현 (필요한 경우)
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // 실제로는 API 연동 등의 검색 로직이 필요합니다.
      // 현재는 임시로 전체 여행 목록에서 필터링합니다.
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.fetchAllTrips();
      
      setState(() {
        _searchResults = tripProvider.trips
            .where((trip) =>
                trip.title.toLowerCase().contains(query.toLowerCase()) ||
                trip.location.toLowerCase().contains(query.toLowerCase()) ||
                trip.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 검색'),
      ),
      body: Column(
        children: [
          // 검색 입력 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소, 여행 이름 등으로 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // 필터 영역 (향후 확장 가능)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('서울', false),
                  _buildFilterChip('부산', false),
                  _buildFilterChip('제주도', false),
                  _buildFilterChip('혼자여행', false),
                  _buildFilterChip('가족여행', false),
                  _buildFilterChip('4시간 이내', false),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 검색 결과 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? const Center(
                        child: Text('여행 목적지나 이름을 검색해보세요'),
                      )
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Text('검색 결과가 없습니다'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final trip = _searchResults[index];
                              return TripCard(
                                trip: trip,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TripDetailScreen(tripId: trip.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // 필터 적용 로직 (나중에 구현)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('필터 기능은 아직 준비중입니다.')),
          );
        },
      ),
    );
  }
}