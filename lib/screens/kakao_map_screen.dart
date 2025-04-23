import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import '../models/trip.dart';
import '../widgets/attraction_card.dart';
import '../config/config.dart';

class KakaoMapScreen extends StatefulWidget {
  final List<Attraction>? attractions;

  const KakaoMapScreen({super.key, this.attractions});

  @override
  State<KakaoMapScreen> createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  late WebViewController _webViewController;
  List<Attraction> _attractions = [];
  bool _isLoading = true;
  int _selectedAttractionIndex = -1;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  
  // 카카오맵 JavaScript API 키
  late String kakaoMapApiKey;
  
  // 환경 변수에서 API 키 가져오기
  void _initApiKey() {
    kakaoMapApiKey = AppConfig.kakaoMapApiKey;
  }

  @override
  void initState() {
    super.initState();
    _initApiKey(); // API 키 초기화
    _loadAttractions();
    _initWebView();
  }
  
  void _initWebView() {
    // 웹뷰 컨트롤러 초기화
    _webViewController = WebViewController();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    
    // 디버깅용 HTTP/HTTPS 확인
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          print('NavigationRequest: ${request.url}');
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {
          print('페이지 로딩 시작: $url');
        },
        onPageFinished: (String url) {
          print('페이지 로딩 완료: $url');
          if (_attractions.isNotEmpty) {
            // 페이지 로드 완료 후 약간의 지연 시간을 두고 마커 추가
            Future.delayed(const Duration(milliseconds: 1000), () {
              _addMarkersToMap();
            });
          }
        },
        onWebResourceError: (WebResourceError error) {
          print('WebView 오류: ${error.errorCode} - ${error.description}');
          // 오류 코드 설명
          String errorMessage = '';
          switch (error.errorCode) {
            case -1: // ERR_CLEARTEXT_NOT_PERMITTED
              errorMessage = 'HTTP 트래픽이 허용되지 않습니다. AndroidManifest.xml에 android:usesCleartextTraffic="true"를 추가해야 합니다.';
              break;
            case -2: // ERR_FAILED
              errorMessage = '일반적인 실패. 네트워크 연결을 확인하세요.';
              break;
            case -6: // ERR_CONNECTION_REFUSED
              errorMessage = '연결이 거부되었습니다. 서버가 실행 중인지 확인하세요.';
              break;
            case -7: // ERR_CONNECTION_TIMED_OUT
              errorMessage = '연결 시간이 초과되었습니다. 네트워크 연결을 확인하세요.';
              break;
            default:
              errorMessage = '알 수 없는 오류입니다.';
          }
          print('오류 설명: $errorMessage');
          
          // 사용자에게 오류 메시지 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('지도 로드 중 오류가 발생했습니다: ${error.description}')),
            );
          }
        },
      ),
    );
    
    // JavaScript와 Flutter 간의 통신을 위한 채널 설정
    _webViewController.addJavaScriptChannel(
      'FlutterApp', 
      onMessageReceived: (JavaScriptMessage message) {
        print('카카오맵에서 메시지: ${message.message}');
        
        // 마커 클릭 이벤트 처리
        if (message.message.startsWith('marker:')) {
          final markerId = message.message.substring(7);
          final markerIndex = _attractions.indexWhere((a) => a.id == markerId);
          if (markerIndex >= 0) {
            setState(() {
              _selectedAttractionIndex = markerIndex;
            });
            _pageController.animateToPage(
              markerIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
    );
    
    // HTML 로드
    _webViewController.loadHtmlString(_getMapHtml());
    
    // 콘솔 로그 캡처 (추가 디버깅)
    _webViewController.addJavaScriptChannel(
      'Console',
      onMessageReceived: (JavaScriptMessage message) {
        print('JS 콘솔: ${message.message}');
      },
    );
    
    // 콘솔 로그 리다이렉트
    _webViewController.runJavaScript('''
      console.log = function(message) {
        if (window.Console) {
          Console.postMessage(String(message));
        }
      };
      console.error = function(message) {
        if (window.Console) {
          Console.postMessage('ERROR: ' + String(message));
        }
      };
    ''');
  }

  String _getMapHtml() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <style>
          body, html { margin: 0; padding: 0; width: 100%; height: 100%; }
          #map { width: 100%; height: 100%; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          function sendToFlutter(message) {
            if (window.FlutterApp) {
              FlutterApp.postMessage(message);
            } else {
              console.log(message);
            }
          }
          
          var map;
          var markers = [];
          
          function initMap() {
            sendToFlutter('지도 초기화 시작');
            try {
              var container = document.getElementById('map');
              sendToFlutter('맵 컨테이너: ' + (container ? 'OK' : 'NULL'));
              
              if (typeof kakao === 'undefined' || !kakao.maps) {
                sendToFlutter('카카오맵 SDK가 로드되지 않았습니다');
                return;
              }
              
              var options = {
                center: new kakao.maps.LatLng(37.5665, 126.9780), // 서울 시청 기본 좌표
                level: 7
              };
              
              map = new kakao.maps.Map(container, options);
              sendToFlutter('지도가 성공적으로 초기화되었습니다');
            } catch(e) {
              sendToFlutter('지도 초기화 오류: ' + e.toString());
            }
          }
          
          // 카카오맵 SDK 로드 및 콜백
          function loadKakaoMapScript() {
            sendToFlutter('카카오맵 SDK 로드 시작');
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.src = 'https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoMapApiKey&autoload=false';
            script.onload = function() {
              sendToFlutter('SDK 스크립트 로드 완료');
              kakao.maps.load(function() {
                sendToFlutter('kakao.maps.load 콜백 실행');
                initMap();
              });
            };
            script.onerror = function() {
              sendToFlutter('SDK 스크립트 로드 실패');
            };
            document.head.appendChild(script);
          }
          
          function addMarker(id, lat, lng, title) {
            try {
              if (!map) {
                sendToFlutter('맵이 초기화되지 않아 마커를 추가할 수 없습니다');
                return;
              }
              
              var markerPosition = new kakao.maps.LatLng(lat, lng);
              var marker = new kakao.maps.Marker({
                position: markerPosition
              });
              
              marker.setMap(map);
              markers.push(marker);
              
              // 인포윈도우 추가
              var infowindow = new kakao.maps.InfoWindow({
                content: '<div style="padding:5px;font-size:12px;">' + title + '</div>'
              });
              
              kakao.maps.event.addListener(marker, 'click', function() {
                // 마커 클릭시 Flutter에 id 전달
                sendToFlutter('marker:' + id);
              });
              
              kakao.maps.event.addListener(marker, 'mouseover', function() {
                infowindow.open(map, marker);
              });
              
              kakao.maps.event.addListener(marker, 'mouseout', function() {
                infowindow.close();
              });
              
              return marker;
            } catch(e) {
              sendToFlutter('마커 추가 오류: ' + e.toString());
            }
          }
          
          function moveCamera(lat, lng) {
            try {
              if (!map) {
                sendToFlutter('맵이 초기화되지 않아 이동할 수 없습니다');
                return;
              }
              
              var moveLatLon = new kakao.maps.LatLng(lat, lng);
              map.setCenter(moveLatLon);
            } catch(e) {
              sendToFlutter('지도 이동 오류: ' + e.toString());
            }
          }
          
          function clearMarkers() {
            try {
              if (!markers || markers.length === 0) return;
              
              for (var i = 0; i < markers.length; i++) {
                markers[i].setMap(null);
              }
              markers = [];
            } catch(e) {
              sendToFlutter('마커 제거 오류: ' + e.toString());
            }
          }
          
          // 스크립트 로드 시작
          window.onload = function() {
            sendToFlutter('페이지 로드 완료');
            loadKakaoMapScript();
          };
        </script>
      </body>
      </html>
    ''';
  }
  
  // 지도에 마커 추가
  void _addMarkersToMap() {
    if (_attractions.isEmpty) return;
    
    // 지도 로드 상태를 확인
    _webViewController.runJavaScript('''
      if (typeof map === 'undefined' || !map) {
        sendToFlutter('지도가 아직 초기화되지 않았습니다. 잠시 후 다시 시도합니다.');
        setTimeout(function() {
          if (typeof map !== 'undefined' && map) {
            sendToFlutter('지도 초기화 확인 완료, 마커 추가 진행');
            clearMarkers();
            ${_getMarkerJavaScript()}
          } else {
            sendToFlutter('지도가 여전히 초기화되지 않았습니다.');
          }
        }, 2000);
      } else {
        clearMarkers();
        ${_getMarkerJavaScript()}
      }
    ''');
  }
  
  // 마커 추가를 위한 JavaScript 코드 생성
  String _getMarkerJavaScript() {
    StringBuffer script = StringBuffer();
    
    // 각 관광지에 대한 마커 추가
    for (int i = 0; i < _attractions.length; i++) {
      final attraction = _attractions[i];
      script.write('''
        addMarker("${attraction.id}", ${attraction.latitude}, ${attraction.longitude}, "${attraction.name}");
      ''');
    }
    
    // 모든 관광지의 좌표 평균 위치로 지도 이동
    if (_attractions.isNotEmpty) {
      final avgLat = _attractions.map((a) => a.latitude).reduce((a, b) => a + b) / _attractions.length;
      final avgLng = _attractions.map((a) => a.longitude).reduce((a, b) => a + b) / _attractions.length;
      script.write('''
        moveCamera($avgLat, $avgLng);
      ''');
    }
    
    return script.toString();
  }

  Future<void> _loadAttractions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (widget.attractions != null) {
        // 직접 전달받은 관광지 정보 사용
        setState(() {
          _attractions = widget.attractions!;
          _isLoading = false;
        });
      } else {
        // 앱의 데이터 소스에서 관광지 정보 로드 (예시 코드)
        // 실제 구현에서는 TripService 등을 통해 데이터 로드
        await Future.delayed(const Duration(seconds: 1)); // 로딩 시간 시뮬레이션
        
        // 서울 주요 관광지 예시 데이터
        setState(() {
          _attractions = [
            Attraction(
              id: '1',
              name: '경복궁',
              description: '조선시대의 대표적인 궁궐',
              imageUrl: 'https://via.placeholder.com/300x200?text=Gyeongbokgung',
              latitude: 37.5796,
              longitude: 126.9768,
              visitDuration: 120,
              rating: 4.8,
            ),
            Attraction(
              id: '2',
              name: '남산타워',
              description: '서울의 랜드마크',
              imageUrl: 'https://via.placeholder.com/300x200?text=Namsan+Tower',
              latitude: 37.5512,
              longitude: 126.9882,
              visitDuration: 90,
              rating: 4.6,
            ),
            Attraction(
              id: '3',
              name: '명동거리',
              description: '쇼핑의 메카',
              imageUrl: 'https://via.placeholder.com/300x200?text=Myeongdong',
              latitude: 37.5636,
              longitude: 126.9810,
              visitDuration: 180,
              rating: 4.4,
            ),
            Attraction(
              id: '4',
              name: '북촌한옥마을',
              description: '전통 한옥 거리',
              imageUrl: 'https://via.placeholder.com/300x200?text=Bukchon',
              latitude: 37.5830,
              longitude: 126.9860,
              visitDuration: 150,
              rating: 4.7,
            ),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_attractions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('주변 여행지 정보가 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: true,
        title: const Text(
          '내 주변 여행지',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),*/
        actions: [
          /*IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87, size: 22),
            onPressed: () {
              // 지도 새로고침
              _webViewController.reload();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('지도를 새로고침합니다')),
              );
            },
          ),*/
        ],
      ),
      body: Stack(
        children: [
          // 카카오맵 웹뷰
          Positioned.fill(
            child: WebViewWidget(controller: _webViewController),
          ),
          
          // 하단 관광지 카드 슬라이더
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _attractions.length,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedAttractionIndex = index;
                  });
                  
                  // 선택된 관광지로 지도 이동
                  final attraction = _attractions[index];
                  _webViewController.runJavaScript(
                    'moveCamera(${attraction.latitude}, ${attraction.longitude})'
                  );
                },
                itemBuilder: (context, index) {
                  final attraction = _attractions[index];
                  return AttractionCard(
                    attraction: attraction,
                    isSelected: index == _selectedAttractionIndex,
                    onTap: () {
                      // 관광지 상세 화면으로 이동 (나중에 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${attraction.name} 상세 정보는 아직 준비중입니다.')),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}