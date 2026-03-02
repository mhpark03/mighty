package com.mhpark.mighty

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Edge-to-edge: 시스템 바가 콘텐츠 위에 오도록 설정
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // Android 15 (API 35+): deprecated SHORT_EDGES → ALWAYS로 전환
        if (Build.VERSION.SDK_INT >= 35) {
            window.attributes.layoutInDisplayCutoutMode =
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
        }
    }

    override fun onPostResume() {
        super.onPostResume()
        // Flutter PlatformPlugin이 시스템 바 설정을 덮어쓸 수 있으므로 재적용
        if (Build.VERSION.SDK_INT >= 35) {
            window.attributes.layoutInDisplayCutoutMode =
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
        }
    }
}
