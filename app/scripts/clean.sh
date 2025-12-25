#!/bin/bash

# Flutter 项目彻底清理脚本
#
# 使用方法:
#   ./scripts/clean.sh           # 彻底清理所有平台
#   ./scripts/clean.sh quick     # 快速清理（仅核心文件）
#   ./scripts/clean.sh --help    # 显示帮助

cd "$(dirname "$0")/.."

# 显示帮助
show_help() {
    echo "Flutter 项目清理脚本"
    echo ""
    echo "使用方法:"
    echo "  $0           # 彻底清理所有平台"
    echo "  $0 quick     # 快速清理（仅核心文件，不清理平台缓存）"
    echo "  $0 --help    # 显示此帮助信息"
    echo ""
    echo "说明:"
    echo "  - 彻底清理：清理所有平台（iOS、Android、macOS、Linux、Windows、Web）的缓存和构建文件"
    echo "  - 快速清理：仅清理 Flutter 核心缓存和构建文件，跳过平台特定清理"
    exit 0
}

# 检查参数
MODE="${1:-full}"
[ "$MODE" = "--help" ] && show_help
[ "$MODE" = "-h" ] && show_help

echo "🧹 开始清理 Flutter 项目..."
echo "项目目录: $(pwd)"
echo "清理模式: $([ "$MODE" = "quick" ] && echo "快速清理" || echo "彻底清理")"
echo ""

# 清理函数
clean_dir() {
    [ -d "$1" ] && rm -rf "$1" && echo "   ✓ 已删除 $1" || echo "   ℹ️  $1 不存在，跳过"
}

clean_file() {
    [ -f "$1" ] && rm -f "$1" && echo "   ✓ 已删除 $1" || true
}

# 1. Flutter 标准清理
echo "1️⃣  执行 Flutter clean..."
flutter clean 2>/dev/null || echo "   ⚠️  Flutter clean 执行失败，继续清理..."

# 2-4. 清理核心目录和文件
echo "2️⃣  删除核心缓存目录..."
clean_dir ".dart_tool"
clean_dir "build"
clean_file ".flutter-plugins"
clean_file ".flutter-plugins-dependencies"

# 5. 清理平台特定文件（仅在完整清理模式下）
if [ "$MODE" != "quick" ]; then
    # 5. 清理 Android
    if [ -d "android" ]; then
        echo "5️⃣  清理 Android 缓存..."
        cd android
        [ -f "gradlew" ] && ./gradlew clean 2>/dev/null || true
        clean_dir ".gradle"
        clean_dir "app/build"
        cd ..
    else
        echo "5️⃣  Android 目录不存在，跳过"
    fi

    # 6. 清理 iOS
    if [ -d "ios" ]; then
        echo "6️⃣  清理 iOS 缓存..."
        clean_dir "ios/Pods"
        clean_file "ios/Podfile.lock"
        clean_dir "ios/.symlinks"
        clean_dir "ios/build"
        clean_dir "ios/DerivedData"
        clean_dir "ios/Flutter/Generated.xcconfig"
        clean_dir "ios/Flutter/flutter_export_environment.sh"
        clean_dir "ios/Flutter/ephemeral"
    else
        echo "6️⃣  iOS 目录不存在，跳过"
    fi

    # 7-10. 清理其他平台
    platforms=("macos:7:macOS" "linux:8:Linux" "windows:9:Windows" "web:10:Web")
    for item in "${platforms[@]}"; do
        IFS=':' read -r platform num name <<< "$item"
        if [ -d "$platform" ]; then
            echo "${num}️⃣  清理 $name 缓存..."
            case $platform in
                macos) clean_dir "macos/.symlinks" && clean_dir "macos/Pods" && clean_dir "macos/Flutter/ephemeral" ;;
                linux|windows) clean_dir "$platform/flutter/ephemeral" ;;
                web) clean_dir "web/.dart_tool" ;;
            esac
        else
            echo "${num}️⃣  $name 目录不存在，跳过"
        fi
    done
else
    echo "5️⃣  跳过平台特定清理（快速模式）"
fi

# 重新生成代码
echo ""
echo "🔨 重新生成代码..."
flutter pub run build_runner build --delete-conflicting-outputs

# 重新获取依赖
echo ""
echo "📦 重新获取 Flutter 依赖..."
flutter pub get

echo ""
echo "✅ 清理完成！"
echo ""
echo "💡 提示："
echo "   - 如果编译仍然卡顿，可以尝试重启 IDE"
echo "   - 如需清理全局 pub 缓存，运行: flutter pub cache repair"
