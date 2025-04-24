import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import '../widgets/trip_type_card.dart';
import '../widgets/search_drawer_filter.dart';
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

  // 필터 옵션 상태
  bool _isDriveCourse = false;
  bool _isNoKidsZone = false;
  bool _isKidsZone = false;
  bool _isPetZone = false;
  String? _selectedTimeFilter = '30분 이내'; // 기본값 설정

  // Drawer 상태 변수
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // 자동 검색 실행 제거 - 여행 타입 버튼을 눌러야만 검색이 시작됨
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

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (!mounted) return;
    
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

      // 드라이브 코스 필터링
      if (_isDriveCourse) {
        // 드라이브 코스 필터링 로직 (서버 API와 연동 시 구현)
        // 임시 구현: 설명에 '드라이브'라는 단어가 포함된 여행만 표시
        filteredTrips = filteredTrips.where((trip) =>
            trip.description.toLowerCase().contains('드라이브')).toList();
      }

      // 노키즈존 필터링
      if (_isNoKidsZone) {
        // 노키즈존 필터링 로직 (서버 API와 연동 시 구현)
        // 임시 구현: 설명에 '노키즈'라는 단어가 포함된 여행만 표시
        filteredTrips = filteredTrips.where((trip) =>
            trip.description.toLowerCase().contains('노키즈')).toList();
      }
      
      // 키즈존 필터링
      if (_isKidsZone) {
        // 키즈존 필터링 로직 (서버 API와 연동 시 구현)
        // 임시 구현: 설명에 '키즈'라는 단어가 포함된 여행만 표시
        filteredTrips = filteredTrips.where((trip) =>
            trip.description.toLowerCase().contains('키즈')).toList();
      }
      
      // 펫존 필터링
      if (_isPetZone) {
        // 펫존 필터링 로직 (서버 API와 연동 시 구현)
        // 임시 구현: 설명에 '펫' 또는 '애완' 단어가 포함된 여행만 표시
        filteredTrips = filteredTrips.where((trip) =>
            trip.description.toLowerCase().contains('펫') ||
            trip.description.toLowerCase().contains('애완')).toList();
      }
      if (_selectedTimeFilter != null) {
        // 임시 구현: 실제로는 위치 기반 API와 연동하여 구현해야 함
        int minutes = 0;
        
        switch (_selectedTimeFilter) {
          case '30분 이내':
            minutes = 30;
            break;
          case '1시간 이내':
            minutes = 60;
            break;
          case '2시간 이내':
            minutes = 120;
            break;
        }
        
        if (minutes > 0) {
          // 임시 구현: 시간별 필터링 로직 (실제로는 거리/시간 계산 API 필요)
          // 현재는 minutes 값을 여행 ID와 비교하여 임시 필터링
          filteredTrips = filteredTrips.where((trip) => 
              int.parse(trip.id) <= minutes).toList();
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = filteredTrips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 여행 타입 선택 시 호출되는 메서드
  void _selectTripType(TripType type) {
    setState(() {
      if (_selectedTripType == type) {
        // 이미 선택된 타입을 다시 선택하면 해제
        _selectedTripType = null;
      } else {
        _selectedTripType = type;
      }
      // 검색이 시작되었음을 표시
      _hasSearched = true;
    });

    // 여행 타입 변경 시 항상 검색 실행
    if (mounted) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '떠나볼까요?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: SearchDrawerFilter(
        isDriveCourse: _isDriveCourse,
        isNoKidsZone: _isNoKidsZone,
        isKidsZone: _isKidsZone,
        isPetZone: _isPetZone,
        selectedTimeFilter: _selectedTimeFilter,
        onFilterChanged: (driveCourse, noKidsZone, kidsZone, petZone, timeFilter) {
          setState(() {
            _isDriveCourse = driveCourse;
            _isNoKidsZone = noKidsZone;
            _isKidsZone = kidsZone;
            _isPetZone = petZone;
            _selectedTimeFilter = timeFilter;
          });
          
          // 여행 타입이 선택되었거나 이미 검색을 했을 때만 검색 수행
          if (mounted && (_selectedTripType != null || _hasSearched)) {
            _performSearch();
          }
        },
      ),
      body: Column(
        children: [
          // 검색 입력 영역
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0 , vertical: 0.0),
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
          ),*/

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



          const SizedBox(height: 8),

          // 검색 결과 영역
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // 새로고침 시 검색 수행
                if (mounted) {
                  await _performSearch();
                }
              },
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasSearched && _selectedTripType == null
                      ? _buildInitialView()
                      : _searchResults.isEmpty
                          ? Container(
                              color: Colors.white,
                              child: ListView(  // SingleChildScrollView 대신 ListView 사용하여 RefreshIndicator가 작동하도록 함
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.search_off,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          '검색 결과가 없습니다.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '필터 옵션을 변경해보세요.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ),
        ],
        ),
      );
    //);
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
          color: Colors.white,
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
    return Container(
      color: Colors.white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/AISEND-removebg-preview.png',
                  width: 160,
                  height: 160,
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
                  '여행 타입을 선택해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}