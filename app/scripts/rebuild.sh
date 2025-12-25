#!/bin/bash

# Flutter 项目重建脚本
# 支持 iOS、Android 和全平台重建
#
# 使用方法:
#   ./scripts/rebuild.sh          # 重建所有平台
#   ./scripts/rebuild.sh ios      # 仅重建 iOS
#   ./scripts/rebuild.sh android  # 仅重建 Android

cd "$(dirname "$0")/.."

PLATFORM="${1:-all}"

# 清理函数
clean_dir() { [ -d "$1" ] && rm -rf "$1" && echo "   ✓ 已删除 $1"; }
clean_file() { [ -f "$1" ] && rm -f "$1" && echo "   ✓ 已删除 $1"; }

# Flutter 基础清理
flutter_base_clean() {
    echo "📦 清理 Flutter 缓存..."
    flutter clean 2>/dev/null || echo "   ⚠️  Flutter clean 失败"
    clean_dir "build"
    clean_dir ".dart_tool"
}

# iOS 重建
rebuild_ios() {
    echo ""
    echo "🍎 开始重建 iOS 项目..."

    if [ ! -d "ios" ]; then
        echo "   ⚠️  iOS 目录不存在，跳过"
        return
    fi

    # 清理 iOS 相关文件
    echo "1. 清理 iOS 构建文件..."
    clean_dir "ios/Pods"
    clean_file "ios/Podfile.lock"
    clean_dir "ios/.symlinks"
    clean_dir "ios/build"
    clean_dir "ios/DerivedData"
    clean_dir "ios/Flutter/Generated.xcconfig"
    clean_dir "ios/Flutter/flutter_export_environment.sh"
    clean_dir "ios/Flutter/ephemeral"

    # 重新获取依赖
    echo "2. 重新获取 Flutter 依赖..."
    flutter pub get

    # 预缓存 iOS 工具
    echo "3. 预缓存 iOS 工具..."
    flutter precache --ios

    # 重新安装 CocoaPods
    echo "4. 重新安装 CocoaPods 依赖..."
    cd ios
    export LANG=en_US.UTF-8
    pod deintegrate 2>/dev/null || true
    pod install || {
        echo "   ⚠️  CocoaPods 安装失败"
        cd ..
        return 1
    }
    cd ..

    echo "✅ iOS 项目重建完成！"
}

# Android 重建
rebuild_android() {
    echo ""
    echo "🤖 开始重建 Android 项目..."

    if [ ! -d "android" ]; then
        echo "   ⚠️  Android 目录不存在，跳过"
        return
    fi

    # 清理 Android 缓存
    echo "1. 清理 Android 构建文件..."
    cd android
    [ -f "gradlew" ] && ./gradlew clean 2>/dev/null || true
    clean_dir ".gradle"
    clean_dir "app/build"
    clean_dir "build"
    cd ..

    # 重新获取依赖
    echo "2. 重新获取 Flutter 依赖..."
    flutter pub get

    # 预缓存 Android 工具
    echo "3. 预缓存 Android 工具..."
    flutter precache --android

    echo "✅ Android 项目重建完成！"
}

# 全平台重建
rebuild_all() {
    echo "🔨 开始重建所有平台..."
    flutter_base_clean

    # 重建 iOS
    rebuild_ios

    # 重建 Android
    rebuild_android

    # 重新获取依赖（如果之前没有）
    if [ ! -f ".dart_tool/package_config.json" ]; then
        echo ""
        echo "📦 重新获取 Flutter 依赖..."
        flutter pub get
    fi

    echo ""
    echo "✅ 全平台重建完成！"
}

# 主逻辑
case "$PLATFORM" in
    ios)
        flutter_base_clean
        rebuild_ios
        ;;
    android)
        flutter_base_clean
        rebuild_android
        ;;
    all)
        rebuild_all
        ;;
    *)
        echo "❌ 未知平台: $PLATFORM"
        echo ""
        echo "使用方法:"
        echo "  $0          # 重建所有平台"
        echo "  $0 ios      # 仅重建 iOS"
        echo "  $0 android  # 仅重建 Android"
        exit 1
        ;;
esac

echo ""
echo "💡 提示:"
echo "   - 运行 ./scripts/dev.sh 启动应用"
echo "   - 如需彻底清理，运行 ./scripts/clean.sh"
