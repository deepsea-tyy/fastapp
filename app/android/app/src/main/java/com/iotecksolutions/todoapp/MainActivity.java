package com.iotecksolutions.todoapp;

import android.os.Build;
import android.os.Bundle;
import androidx.core.view.WindowCompat;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        // 方案A：使用颜色值配置 SplashScreen API
        // windowBackground 显示全屏背景图片，windowSplashScreenBackground 使用颜色值避免默认背景
        // 立即移除 SplashScreen，让 Flutter 内容显示
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSplashScreen()
                .setOnExitAnimationListener(
                    (splashScreenView) -> {
                        // 立即移除，不显示淡出动画
                        splashScreenView.remove();
                    });
        }

        super.onCreate(savedInstanceState);
    }
}
