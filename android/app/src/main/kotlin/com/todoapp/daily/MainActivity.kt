package com.todoapp.daily

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15 이상에서 엣지 투 엣지 디스플레이 지원
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Android 15 이상에서 필요한 추가 설정
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // Android 15 (API 35) 이상에서만 실행되는 코드
        }
        
        super.onCreate(savedInstanceState)
    }
}
