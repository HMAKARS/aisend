import 'package:flutter/material.dart';

class SearchDrawerFilter extends StatefulWidget {
  final bool isDriveCourse;
  final bool isNoKidsZone;
  final bool isKidsZone;
  final bool isPetZone;
  final String? selectedTimeFilter;
  final Function(bool, bool, bool, bool, String?) onFilterChanged;

  const SearchDrawerFilter({
    Key? key,
    required this.isDriveCourse,
    required this.isNoKidsZone,
    required this.isKidsZone,
    required this.isPetZone,
    required this.selectedTimeFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<SearchDrawerFilter> createState() => _SearchDrawerFilterState();
}

class _SearchDrawerFilterState extends State<SearchDrawerFilter> {
  late bool _isDriveCourse;
  late bool _isNoKidsZone;
  late bool _isKidsZone;
  late bool _isPetZone;
  late String? _selectedTimeFilter;

  @override
  void initState() {
    super.initState();
    // 초기 상태 설정
    _isDriveCourse = widget.isDriveCourse;
    _isNoKidsZone = widget.isNoKidsZone;
    _isKidsZone = widget.isKidsZone;
    _isPetZone = widget.isPetZone;
    _selectedTimeFilter = widget.selectedTimeFilter;
  }

  // 필터 변경 시 호출되는 메서드
  void _updateFilter({
    bool? driveCourse,
    bool? noKidsZone,
    bool? kidsZone, 
    bool? petZone,
    String? timeFilter,
  }) {
    // 상태 업데이트
    setState(() {
      if (driveCourse != null) _isDriveCourse = driveCourse;
      if (noKidsZone != null) _isNoKidsZone = noKidsZone;
      if (kidsZone != null) _isKidsZone = kidsZone;
      if (petZone != null) _isPetZone = petZone;
      if (timeFilter != null) _selectedTimeFilter = timeFilter;
    });
    
    // 필터 변경 즉시 적용
    widget.onFilterChanged(
      _isDriveCourse,
      _isNoKidsZone,
      _isKidsZone,
      _isPetZone,
      _selectedTimeFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 뒤로 가기 버튼 처리
      canPop: true,
      onPopInvoked: (didPop) {
        // 이미 필터 변경 시 적용되므로 추가 작업 필요 없음
      },
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 필터 헤더
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '필터',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // 초기화 버튼을 누르면 모든 필터를 기본값으로 재설정하고 즉시 적용
                          _updateFilter(
                            driveCourse: false,
                            noKidsZone: false,
                            kidsZone: false,
                            petZone: false,
                            timeFilter: '30분 이내',
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('초기화'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 장소 타입 섹션
                        _buildFilterSection(
                          '장소 타입',
                          Icons.place_outlined,
                          [
                            _buildModernCheckboxTile(
                              '드라이브 할 거에요!',
                              _isDriveCourse,
                              Icons.drive_eta_outlined,
                              (value) => _updateFilter(driveCourse: value),
                            ),
                            _buildModernCheckboxTile(
                              '노키즈존 여부',
                              _isNoKidsZone,
                              Icons.do_not_disturb_outlined,
                              (value) => _updateFilter(noKidsZone: value),
                            ),
                            _buildModernCheckboxTile(
                              '키즈존 여부',
                              _isKidsZone,
                              Icons.child_care_outlined,
                              (value) => _updateFilter(kidsZone: value),
                            ),
                            _buildModernCheckboxTile(
                              '펫존 여부',
                              _isPetZone,
                              Icons.pets_outlined,
                              (value) => _updateFilter(petZone: value),
                            ),
                          ],
                        ),
                        
                        const Divider(
                          height: 32, 
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        
                        // 시간 필터 섹션
                        _buildFilterSection(
                          '현재 위치 기준 소요 시간',
                          Icons.access_time,
                          [
                            _buildModernRadioTile(
                              '30분 이내',
                              '30분 이내',
                              _selectedTimeFilter,
                              (value) => _updateFilter(timeFilter: value),
                            ),
                            _buildModernRadioTile(
                              '1시간 이내',
                              '1시간 이내',
                              _selectedTimeFilter,
                              (value) => _updateFilter(timeFilter: value),
                            ),
                            _buildModernRadioTile(
                              '2시간 이내',
                              '2시간 이내',
                              _selectedTimeFilter,
                              (value) => _updateFilter(timeFilter: value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 닫기 버튼
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 필터 섹션 위젯
  Widget _buildFilterSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
  
  // 모던 스타일 체크박스 타일 위젯
  Widget _buildModernCheckboxTile(String title, bool value, IconData icon, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? Colors.blue : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(
              icon,
              size: 20,
              color: value ? Colors.blue : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 모던 스타일 라디오 타일 위젯
  Widget _buildModernRadioTile(String title, String value, String? groupValue, Function(String?) onChanged) {
    final bool isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
