import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../widgets/trip_card.dart';
import 'dart:ui';
import 'trip_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 현재 날씨 (실제로는 API 연동 필요)
  final String currentWeather = '맑음'; // 예: 맑음, 비, 눈, 흐림 등

  // 선택된 테마 인덱스
  int _selectedThemeIndex = 0;

  // 테마 리스트
  final List<String> themes = ['전체', '힐링', '액티비티', '역사', '맛집', '카페'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F4F8), Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            // 상단 앱바와 배경 이미지
            SliverAppBar(
              expandedHeight: 270.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'AISEND',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0,
                        color: Color.fromARGB(150, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://picsum.photos/1000/600?random=1',
                      fit: BoxFit.cover,
                    ),
                    // 그라데이션 오버레이
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // 감성적인 서브타이틀 추가
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: Text(
                        '당신의 완벽한 하루를 계획해보세요',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 날씨 기반 추천 여행 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            _getWeatherIcon(currentWeather),
                            const SizedBox(width: 8),
                            Text(
                              '$currentWeather 날씨에 딱 맞는 여행',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '오늘같은 날씨에 즐기기 좋은 여행 코스를 추천해드려요',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 날씨 기반 추천 여행 카드 목록
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 215,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _buildWeatherBasedTripCard(
                        context,
                        '서울 실내 데이트 코스',
                        '미술관, 카페, 맛집을 즐기는 코스',
                        '4시간 코스',
                        'https://picsum.photos/300/200?random=11',
                        4.7,
                        '1', // 임시 ID
                      ),
                      _buildWeatherBasedTripCard(
                        context,
                        '청계천 산책 코스',
                        '도심 속 자연을 느끼는 여유로운 코스',
                        '3시간 코스',
                        'https://picsum.photos/300/200?random=12',
                        4.5,
                        '2', // 임시 ID
                      ),
                      _buildWeatherBasedTripCard(
                        context,
                        '한강 자전거 투어',
                        '한강을 따라 자전거를 타며 즐기는 코스',
                        '5시간 코스',
                        'https://picsum.photos/300/200?random=13',
                        4.8,
                        '3', // 임시 ID
                      ),
                      _buildWeatherBasedTripCard(
                        context,
                        '남산 둘레길 코스',
                        '서울 시내를 내려다보며 걷는 트레킹 코스',
                        '4시간 코스',
                        'https://picsum.photos/300/200?random=14',
                        4.6,
                        '4', // 임시 ID
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 테마별 추천 여행 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '테마별 추천 여행',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '당신의 취향에 맞는 테마별 여행 코스를 찾아보세요',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 테마 필터 버튼
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedThemeIndex = index;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedThemeIndex == index
                                ? Theme
                                .of(context)
                                .primaryColor
                                : Colors.white,
                            foregroundColor: _selectedThemeIndex == index
                                ? Colors.white
                                : Colors.black87,
                            elevation: _selectedThemeIndex == index ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedThemeIndex == index
                                    ? Theme
                                    .of(context)
                                    .primaryColor
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                          child: Text(themes[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 테마별 추천 여행 목록
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildThemeBasedTripCard(
                      context,
                      'https://picsum.photos/1000/600?random=15',
                      '제주 힐링 여행',
                      '제주의 자연과 함께하는 힐링 코스',
                      '2박 3일 코스',
                      4.9,
                      '5', // 임시 ID
                    ),
                    const SizedBox(height: 16),
                    _buildThemeBasedTripCard(
                      context,
                      'https://picsum.photos/1000/600?random=16',
                      '부산 맛집 투어',
                      '부산의 대표 맛집을 탐험하는 미식 코스',
                      '당일 코스',
                      4.7,
                      '6', // 임시 ID
                    ),
                  ],
                ),
              ),
            ),

            // 인기 여행지 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '인기 여행지',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // 모든 여행지 보기 기능 (나중에 구현)
                          },
                          child: Row(
                            children: [
                              Text(
                                '더보기',
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '지금 가장 많이 찾는 인기 여행지에요',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 인기 여행지 카드 목록
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _buildPopularDestinationCard(
                        context,
                        'https://picsum.photos/300/200?random=6',
                        '서울',
                        '도심 속 다양한 문화',
                      ),
                      _buildPopularDestinationCard(
                        context,
                        'https://picsum.photos/300/200?random=7',
                        '부산',
                        '해변과 산이 어우러진 도시',
                      ),
                      _buildPopularDestinationCard(
                        context,
                        'https://picsum.photos/300/200?random=8',
                        '제주도',
                        '천혜의 자연 경관',
                      ),
                      _buildPopularDestinationCard(
                        context,
                        'https://picsum.photos/300/200?random=9',
                        '경주',
                        '천년의 역사가 살아 숨쉬는 곳',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  // 날씨 아이콘 반환 메서드
  Widget _getWeatherIcon(String weather) {
    IconData iconData;
    Color iconColor;

    switch (weather) {
      case '맑음':
        iconData = Icons.wb_sunny;
        iconColor = Colors.amber;
        break;
      case '흐림':
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case '비':
        iconData = Icons.beach_access; // 우산 아이콘
        iconColor = Colors.blue;
        break;
      case '눈':
        iconData = Icons.ac_unit;
        iconColor = Colors.lightBlue;
        break;
      default:
        iconData = Icons.wb_sunny;
        iconColor = Colors.amber;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  // 날씨 기반 추천 여행 카드
  Widget _buildWeatherBasedTripCard(BuildContext context, String title,
      String description, String duration,
      String imageUrl, double rating, String tripId) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(tripId: tripId),
            ),
          );
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 100,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularDestinationCard(BuildContext context, String imageUrl,
      String name, String description) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.5',
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeBasedTripCard(BuildContext context,
      String imageUrl,
      String title,
      String description,
      String duration,
      double rating,
      String tripId,) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(tripId: tripId),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        shadowColor: Colors.black26,
        child: Column(
          children: [
            // 이미지와 제목 오버레이
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 즐겨찾기 버튼
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.red,
                      onPressed: () {
                        // 즐겨찾기 추가 기능 (나중에 구현)
                      },
                    ),
                  ),
                ),
              ],
            ),
            // 하단 정보
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 소요 시간
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  // 평점
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 20,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(120)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
