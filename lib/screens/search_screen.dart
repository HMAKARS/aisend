import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/place_provider.dart';
import '../widgets/place_card.dart';
import '../widgets/search_drawer_filter.dart';
import '../screens/place_detail_screen.dart';
import '../screens/trip_plan_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 검색 관련 상태
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isShowingSuggestions = false;
  
  // 검색어 관련 상태
  List<String> _recentSearches = [];
  List<String> _searchSuggestions = [];
  
  // 정렬 옵션 상태
  String _sortOption = '인기순';
  List<String> _sortOptions = ['인기순', '평점 높은순', '리뷰 많은순', '거리순'];
  
  // 선택된 사용자 유형 상태
  UserType? _selectedUserType;

  // 필터 옵션 상태
  bool _isDriveCourse = false;
  bool _isNoKidsZone = false;
  bool _isKidsZone = false;
  bool _isPetZone = false;
  String? _selectedTimeFilter = '30분 이내'; // 기본값 설정
  
  // 카테고리 필터 상태
  List<String> _categories = ['관광지', '맛집', '카페', '숙소', '쇼핑', '문화시설'];
  List<String> _selectedCategories = [];

  // Drawer 상태 변수
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  // 검색 필드 포커스 변경 시 호출되는 메서드
  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _isShowingSuggestions = true;
      });
    }
  }

  // 텍스트 변경시 호출되는 메서드
  void _onSearchChanged() {
    setState(() {
      _isShowingSuggestions = _searchController.text.isNotEmpty;
    });
  }
  
  // 최근 검색어 로드
  Future<void> _loadRecentSearches() async {
    // 실제 구현에서는 SharedPreferences 등을 사용하여 저장된 검색어를 불러옴
    // 예시 데이터
    setState(() {
      _recentSearches = ['제주도', '서울 데이트', '부산 해변', '경주 여행'];
    });
  }
  
  // 최근 검색어 저장
  void _saveRecentSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      // 이미 있는 경우 제거 후 맨 앞에 추가
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      
      // 최대 10개까지만 유지
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    
    // 실제 구현에서는 SharedPreferences 등을 사용하여 저장
  }
  
  // 검색어 제안 처리
  Future<void> _handleSearchSuggestions() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isShowingSuggestions = false;
        _searchSuggestions = [];
      });
      return;
    }
    
    setState(() {
      _isShowingSuggestions = true;
    });
    
    // 실제 구현에서는 API 호출하여 검색어 제안을 받아옴
    // 예시 데이터 - 실제로는 백엔드에서 제공하는 API 호출
    await Future.delayed(const Duration(milliseconds: 300)); // 디바운스 효과
    
    if (_searchController.text.trim() != query) return; // 검색어가 변경된 경우 무시
    
    setState(() {
      _searchSuggestions = [
        '$query 관광지',
        '$query 맛집',
        '$query 추천 코스',
        '$query 숙소',
      ];
    });
  }
  
  // 검색 제안 선택 처리
  void _onSuggestionSelected(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _isShowingSuggestions = false;
    });
    _performSearch();
    _saveRecentSearch(suggestion);
  }
  
  // 최근 검색어 삭제
  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
    // 실제 구현에서는 SharedPreferences 등을 사용하여 저장
  }
  
  // 카테고리 토글
  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    
    if (_selectedUserType != null && _hasSearched) {
      _performSearch();
    }
  }
  
  // 정렬 옵션 변경
  void _changeSortOption(String option) {
    setState(() {
      _sortOption = option;
    });
    
    if (_selectedUserType != null && _hasSearched) {
      _performSearch();
    }
  }

  // 검색 제안 및 최근 검색어 위젯
  Widget _buildSearchSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchSuggestions.isNotEmpty && _searchController.text.isNotEmpty)
            ..._searchSuggestions.map((suggestion) => _buildSuggestionItem(suggestion))
          else if (_recentSearches.isNotEmpty)
            ...[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '최근 검색어',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _recentSearches = [];
                          _isShowingSuggestions = false;
                        });
                        // 실제 구현에서는 SharedPreferences 등을 사용하여 저장
                      },
                      child: const Text(
                        '전체 삭제',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._recentSearches.take(5).map((search) => _buildRecentSearchItem(search)),
            ],
        ],
      ),
    );
  }

  // 검색 제안 아이템 위젯
  Widget _buildSuggestionItem(String suggestion) {
    return InkWell(
      onTap: () => _onSuggestionSelected(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Icon(Icons.north_west, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 최근 검색어 아이템 위젯
  Widget _buildRecentSearchItem(String search) {
    return InkWell(
      onTap: () => _onSuggestionSelected(search),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const Icon(Icons.history, size: 18, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                search,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            InkWell(
              onTap: () => _removeRecentSearch(search),
              child: const Icon(Icons.close, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 수행 함수
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (!mounted || _selectedUserType == null) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _isShowingSuggestions = false; // 검색 시작시 제안 창 닫기
    });

    try {
      // PlaceProvider를 통한 검색 실행
      final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
      
      await placeProvider.searchPlaces(
        userType: _selectedUserType!,
        keyword: query.isNotEmpty ? query : null,
        isDriveCourse: _isDriveCourse ? true : null,
        isNoKidsZone: _isNoKidsZone ? true : null,
        isKidsZone: _isKidsZone ? true : null, 
        isPetZone: _isPetZone ? true : null,
        timeFilter: _selectedTimeFilter,
        categories: _selectedCategories.isNotEmpty ? _selectedCategories : null,
        sortBy: _sortOption,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 사용자 유형 선택 시 호출되는 메서드
  void _selectUserType(UserType type) {
    setState(() {
      if (_selectedUserType == type) {
        // 이미 선택된 타입을 다시 선택하면 해제
        _selectedUserType = null;
      } else {
        _selectedUserType = type;
      }
      // 검색이 시작되었음을 표시
      _hasSearched = true;
    });

    // 사용자 유형 변경 시 검색 실행
    if (mounted && _selectedUserType != null) {
      _performSearch();
    }
  }
  
  // 검색 필터 초기화 함수
  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _isShowingSuggestions = false;
      _selectedCategories = [];
      _sortOption = '인기순';
    });
    FocusScope.of(context).unfocus();
    
    if (_selectedUserType != null) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 키보드 외부 탭 시 포커스 제거 및 제안 목록 닫기
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _isShowingSuggestions = false;
        });
      },
      child: Scaffold(
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
            // 검색 히스토리 아이콘
           /* IconButton(
              icon: const Icon(
                Icons.history,
                color: Colors.blue,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  // 검색창이 비어있을 때만 최근 검색어 표시
                  if (_searchController.text.isEmpty) {
                    _isShowingSuggestions = !_isShowingSuggestions;
                  }
                });
              },
            ),*/
            // 필터 아이콘
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
            
            // 사용자 유형이 선택되었거나 이미 검색을 했을 때만 검색 수행
            if (mounted && (_selectedUserType != null || _hasSearched)) {
              _performSearch();
            }
          },
        ),
        body: Column(
          children: [
            // 사용자 유형 선택 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildUserTypeCard(
                    UserType.alone,
                    '혼자',
                    Icons.person,
                    Colors.blue,
                  ),
                  _buildUserTypeCard(
                    UserType.couple,
                    '연인',
                    Icons.favorite,
                    Colors.red,
                  ),
                  _buildUserTypeCard(
                    UserType.family,
                    '가족',
                    Icons.family_restroom,
                    Colors.green,
                  ),
                  _buildUserTypeCard(
                    UserType.friends,
                    '친구',
                    Icons.people,
                    Colors.orange,
                  ),
                ],
              ),
            ),

/*/*            // 검색 입력 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '장소, 여행 이름 등으로 검색',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            if (_selectedUserType != null) {
                              _performSearch();
                            }
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (_) {
                  if (_selectedUserType != null) {
                    _handleSearchSuggestions();
                  }
                },
                onSubmitted: (_) {
                  if (_selectedUserType != null) {
                    _performSearch();
                    _saveRecentSearch(_searchController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('먼저 사용자 유형을 선택해주세요')),
                    );
                  }
                },
              ),
            ),

            // 검색어 제안 또는 최근 검색어 표시
            if (_isShowingSuggestions)
              _buildSearchSuggestions(),*/
              */
            const SizedBox(height: 8),

            // 검색 결과 영역
            Expanded(
              child: Consumer<PlaceProvider>(
                builder: (context, placeProvider, child) {
                  if (_isLoading || placeProvider.isLoading) {
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
                            '검색 중 오류가 발생했습니다',
                            style: TextStyle(
                              fontSize: 16,
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
                              _performSearch();
                            },
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!_hasSearched || _selectedUserType == null) {
                    return _buildInitialView();
                  }

                  if (placeProvider.places.isEmpty) {
                    return _buildEmptyResultsView();
                  }

                  return _buildSearchResultsList(placeProvider.places);
                },
              ),
            ),
          ],
        ),
        // 플로팅 액션 버튼 - 검색 초기화 (Scaffold 레벨에서만 사용)
        floatingActionButton: _hasSearched ? FloatingActionButton(
          mini: true,
          backgroundColor: Colors.white,
          onPressed: _resetSearch,
          child: const Icon(Icons.refresh, color: Colors.blue),
        ) : null,
      ),
    );
  }

  // 검색 결과 리스트 위젯
  Widget _buildSearchResultsList(List<Place> places) {
    return RefreshIndicator(
      onRefresh: _performSearch,
      child: Column(
        children: [
          // 카테고리 필터 영역
          _buildCategoryFilter(),
          
          // 검색 결과 정보 및 정렬 옵션 헤더
          _buildResultsHeader(places.length),
          
          // 실제 검색 결과 리스트
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return PlaceCard(
                  place: place,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripPlanScreen(
                          mainPlace: place,   // 검색해서 고른 메인 장소
                        ),
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
  
  // 카테고리 필터 위젯
  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: _categories.map((category) {
          final isSelected = _selectedCategories.contains(category);
          return GestureDetector(
            onTap: () => _toggleCategory(category),
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // 검색 결과 헤더 (결과 수 + 정렬 옵션)
  Widget _buildResultsHeader(int resultsCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 $resultsCount개의 결과',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _changeSortOption,
            itemBuilder: (context) {
              return _sortOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      _sortOption == option
                          ? const Icon(Icons.check, size: 16, color: Colors.blue)
                          : const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                );
              }).toList();
            },
            child: Row(
              children: [
                Text(
                  _sortOption,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 검색 결과 없음 위젯
  Widget _buildEmptyResultsView() {
    return RefreshIndicator(
      onRefresh: _performSearch,
      child: Column(
        children: [
          // 카테고리 필터는 결과가 없어도 표시
          _buildCategoryFilter(),
          
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        '다른 검색어를 입력하거나 필터 옵션을 변경해 보세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _resetSearch,
                          icon: const Icon(Icons.refresh),
                          label: const Text('검색 초기화'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            elevation: 0,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                          icon: const Icon(Icons.tune),
                          label: const Text('필터 변경'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // 다른 추천 장소 표시
                    if (_searchController.text.isNotEmpty)
                      ...[
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '"${_searchController.text}" 대신 이런 장소는 어떨까요?',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAlternativeSuggestions(),
                      ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 대체 추천 위젯 (검색 결과가 없을 때)
  Widget _buildAlternativeSuggestions() {
    // 예시 데이터 - 실제로는 백엔드에서 추천 데이터를 받아와야 함
    List<String> suggestions = [
      '제주도 해변',
      '서울 근교 드라이브',
      '경주 역사 여행',
      '부산 맛집 투어',
    ];
    
    return Container(
      height: 120,
      padding: const EdgeInsets.only(left: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                _searchController.text = suggestion;
                _performSearch();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForSuggestion(suggestion),
                        size: 32,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 추천 아이템에 맞는 아이콘 선택
  IconData _getIconForSuggestion(String suggestion) {
    if (suggestion.contains('해변')) {
      return Icons.beach_access;
    } else if (suggestion.contains('드라이브')) {
      return Icons.drive_eta;
    } else if (suggestion.contains('역사')) {
      return Icons.account_balance;
    } else if (suggestion.contains('맛집')) {
      return Icons.restaurant;
    } else {
      return Icons.place;
    }
  }

  // 초기 화면 위젯
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
                  '위에서 여행 타입을 선택해주세요',
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

  // 사용자 유형 선택 카드 위젯
  Widget _buildUserTypeCard(
    UserType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedUserType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectUserType(type),
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
}