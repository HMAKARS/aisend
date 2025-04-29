import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/kakao_map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/myTravel_screen.dart';
import 'providers/trip_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/place_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'config/config.dart';


Future<void> main() async {
  // 위젯 바인딩 초기화 (플러터 엔진과 위젯 연결)
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env 파일 로드
  await dotenv.load(fileName: '.env');
  AuthRepository.initialize(appKey: Config.kakaoNativeApiKey);
  //KakaoMapSDK.instance.initialize(appKey: Config.kakaoNativeApiKey); // ✅ 초기화

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => TripProvider()),
        ChangeNotifierProvider(create: (ctx) => PlaceProvider()),
      ],
      child: MaterialApp(
        title: 'AISEND',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: AuthCheckScreen(),
        routes: {
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          SignUpScreen.routeName: (ctx) => const SignUpScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // 로그인 상태를 확인하여 적절한 화면으로 이동
    return FutureBuilder(
      future: authProvider.checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // 로그인 상태에 따라 시작 화면 결정
        //final isLoggedIn = snapshot.data ?? false;
        //if (isLoggedIn) {
          return const MainScreen();
        //} else {
          //return const LoginScreen();
        //}
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const SearchScreen(),
    const KakaoMapScreen(),
    const HomeScreen(),
    const myTravelScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      // 하단 네비게이션 바 코드 수정부분
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 10,
          unselectedFontSize: 10,
          iconSize: 20,
          elevation: 0,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.near_me_outlined),
              label: '내 주변',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              label: '내 여행',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}