import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_type_card.dart';
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
  
  // 선택된 여행 타입 상태
  TripType? _selectedTripType;
  
  // 드라이브 옵션 상태
  bool _wantToDrive = false;

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
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // 실제로는 API 연동 등의 검색 로직이 필요합니다.
      // 현재는 임시로 전체 여행 목록에서 필터링합니다.
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.fetchAllTrips();
      
      List<Trip> filteredTrips = tripProvider.trips;
      
      // 여행 타입 필터링
      if (_selectedTripType != null) {
        filteredTrips = filteredTrips.where((trip) => trip.type == _selectedTripType).toList();
      }
      
      // 검색어 필터링 (검색어가 있는 경우에만)
      if (query.isNotEmpty) {
        filteredTrips = filteredTrips.where((trip) =>
            trip.title.toLowerCase().contains(query.toLowerCase()) ||
            trip.location.toLowerCase().contains(query.toLowerCase()) ||
            trip.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
      }
      
      // TODO: 드라이브 필터링 로직 추가 (API 연동 시)
      // 현재는 예시로만 포함
      if (_wantToDrive && _selectedTripType == TripType.solo) {
        // 드라이브 코스 필터링을 여기에 추가
        // 나중에 서버 API와 연동하여 드라이브 코스 필터링 로직 추가
      }
      
      setState(() {
        _searchResults = filteredTrips;
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
  
  // 여행 타입 선택 시 호출되는 메서드
  void _selectTripType(TripType type) {
    setState(() {
      if (_selectedTripType == type) {
        // 이미 선택된 타입을 다시 선택하면 해제
        _selectedTripType = null;
        _wantToDrive = false; // 타입 해제 시 드라이브 옵션도 해제
      } else {
        _selectedTripType = type;
        // 혼자 여행이 아닌 다른 타입 선택 시 드라이브 옵션 해제
        if (_selectedTripType != TripType.solo) {
          _wantToDrive = false;
        }
      }
    });
    
    // 여행 타입 변경 시 자동으로 검색 실행
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '여행 검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          // 혼자 여행이 선택된 경우에만 드라이브 옵션 표시
          if (_selectedTripType == TripType.solo)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Text(
                    '드라이브할래요',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  Checkbox(
                    value: _wantToDrive,
                    onChanged: (value) {
                      setState(() {
                        _wantToDrive = value ?? false;
                      });
                      _performSearch(); // 옵션 변경 시 검색 다시 실행
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
        ],
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // 여행 유형 선택 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTripTypeCard(
                  TripType.solo,
                  '혼자',
                  Icons.person,
                  Colors.blue,
                ),
                _buildTripTypeCard(
                  TripType.couple,
                  '연인',
                  Icons.favorite,
                  Colors.red,
                ),
                _buildTripTypeCard(
                  TripType.family,
                  '가족',
                  Icons.family_restroom,
                  Colors.green,
                ),
                _buildTripTypeCard(
                  TripType.friends,
                  '친구',
                  Icons.people,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 검색 결과 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched && _selectedTripType == null
                    ? _buildInitialView()
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedTripType != null ? 
                                    '선택한 여행 유형에 맞는 코스가 없습니다.' :
                                    '검색 결과가 없습니다.',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
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
  
  // 여행 타입 선택 카드 위젯
  Widget _buildTripTypeCard(
    TripType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedTripType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTripType(type),
        child: Card(
          elevation: isSelected ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : Colors.grey,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 초기 검색 화면 위젯
  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/AISEND-removebg-preview.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          const Text(
            '어떤 여행을 계획 중이신가요?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '여행 타입을 선택하거나 검색어를 입력해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}