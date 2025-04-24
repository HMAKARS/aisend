import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoMapWebView extends StatelessWidget {
  final Map<String, dynamic>? tripPlan;

  const KakaoMapWebView({Key? key, required this.tripPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plan = tripPlan;

    if (plan == null || plan['course'] == null || plan['course'] is! List) {
      return const Center(child: Text("경로 정보가 없습니다."));
    }

    final List locations = plan['course'] as List;
    if (locations.isEmpty) {
      return const Center(child: Text("추천 장소가 없습니다."));
    }

    final markersJs = locations.map((loc) {
      final lat = loc['lat']?.toString() ?? '0';
      final lng = loc['lng']?.toString() ?? '0';
      final name = loc['name']?.toString().replaceAll('"', '\\"') ?? '';
      return '''
        new kakao.maps.Marker({ 
          map: map, 
          position: new kakao.maps.LatLng($lat, $lng),
          title: "$name"
        });
      ''';
    }).join('\n');

    final lat = locations[0]['lat'];
    final lng = locations[0]['lng'];

    final html = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_KAKAO_API_KEY"></script>
        <style>
          html, body { margin: 0; padding: 0; height: 100%; }
          #map { width: 100%; height: 100%; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          var mapContainer = document.getElementById('map');
          var mapOption = {
            center: new kakao.maps.LatLng($lat, $lng),
            level: 5
          };
          var map = new kakao.maps.Map(mapContainer, mapOption);
          $markersJs
        </script>
      </body>
      </html>
    ''';

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);

    return WebViewWidget(controller: controller);
  }
}