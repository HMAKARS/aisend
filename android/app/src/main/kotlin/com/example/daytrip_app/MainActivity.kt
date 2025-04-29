package com.example.aisend_app

import io.flutter.embedding.android.FlutterActivity
import com.kakao.vectormap.KakaoMapSdk // ✅ 추가 (kakao_map_plugin 내부 SDK)
import android.os.Bundle


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ 여기서 KakaoMapSdk를 초기화해야 에러가 사라진다
        KakaoMapSdk.init(this, "") // 네이티브 앱 키 입력!
    }
}
