#!/bin/bash

# Flutter 项目彻底清理脚本
# 用于清理所有构建缓存和残留文件，解决编译卡顿等问题

set -e

# 设置代理（如果需要翻墙）
# export https_proxy=http://127.0.0.1:7890
# export http_proxy=http://127.0.0.1:7890
# export all_proxy=socks5://127.0.0.1:7890

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

echo "🧹 开始彻底清理 Flutter 项目..."
echo "项目目录: $PROJECT_DIR"
echo ""

# 1. Flutter 标准清理
echo "1️⃣  执行 Flutter clean..."
flutter clean || echo "⚠️  Flutter clean 执行失败，继续清理..."

# 2. 删除 .dart_tool（包含编译缓存）
echo "2️⃣  删除 .dart_tool 目录（包含编译缓存）..."
if [ -d ".dart_tool" ]; then
    rm -rf .dart_tool
    echo "   ✓ 已删除 .dart_tool"
else
    echo "   ℹ️  .dart_tool 不存在，跳过"
fi

# 3. 删除构建目录
echo "3️⃣  删除 build 目录..."
if [ -d "build" ]; then
    rm -rf build
    echo "   ✓ 已删除 build"
else
    echo "   ℹ️  build 目录不存在，跳过"
fi

# 4. 删除插件配置文件
echo "4️⃣  删除插件配置文件..."
rm -f .flutter-plugins
rm -f .flutter-plugins-dependencies
echo "   ✓ 已删除插件配置文件"

# 5. 清理 Android 相关缓存（如果存在）
if [ -d "android" ]; then
    echo "5️⃣  清理 Android 缓存..."
    cd android
    
    # 清理 Gradle 构建
    if [ -f "gradlew" ]; then
        ./gradlew clean 2>/dev/null || echo "   ⚠️  Gradle clean 失败，继续..."
    fi
    
    # 删除 Gradle 缓存目录
    if [ -d ".gradle" ]; then
        rm -rf .gradle
        echo "   ✓ 已删除 .gradle"
    fi
    
    # 删除 app/build
    if [ -d "app/build" ]; then
        rm -rf app/build
        echo "   ✓ 已删除 app/build"
    fi
    
    cd ..
else
    echo "5️⃣  Android 目录不存在，跳过"
fi

# 6. 清理 iOS 相关缓存（如果存在）
if [ -d "ios" ]; then
    echo "6️⃣  清理 iOS 缓存..."
    
    # 删除 Pods
    if [ -d "ios/Pods" ]; then
        rm -rf ios/Pods
        echo "   ✓ 已删除 Pods"
    fi
    
    # 删除其他 iOS 缓存
    rm -f ios/Podfile.lock
    rm -rf ios/.symlinks
    rm -rf ios/build
    rm -rf ios/DerivedData
    rm -rf ios/Flutter/Generated.xcconfig
    rm -rf ios/Flutter/flutter_export_environment.sh
    rm -rf ios/Flutter/ephemeral
    
    echo "   ✓ 已清理 iOS 缓存文件"
else
    echo "6️⃣  iOS 目录不存在，跳过"
fi

# 7. 清理 macOS 相关缓存（如果存在）
if [ -d "macos" ]; then
    echo "7️⃣  清理 macOS 缓存..."
    rm -rf macos/.symlinks
    rm -rf macos/Pods
    rm -rf macos/Flutter/ephemeral
    echo "   ✓ 已清理 macOS 缓存"
else
    echo "7️⃣  macOS 目录不存在，跳过"
fi

# 8. 清理 Linux 相关缓存（如果存在）
if [ -d "linux" ]; then
    echo "8️⃣  清理 Linux 缓存..."
    rm -rf linux/flutter/ephemeral
    echo "   ✓ 已清理 Linux 缓存"
else
    echo "8️⃣  Linux 目录不存在，跳过"
fi

# 9. 清理 Windows 相关缓存（如果存在）
if [ -d "windows" ]; then
    echo "9️⃣  清理 Windows 缓存..."
    rm -rf windows/flutter/ephemeral
    echo "   ✓ 已清理 Windows 缓存"
else
    echo "9️⃣  Windows 目录不存在，跳过"
fi

# 10. 清理 Web 相关缓存（如果存在）
if [ -d "web" ]; then
    echo "🔟 清理 Web 缓存..."
    rm -rf web/.dart_tool
    echo "   ✓ 已清理 Web 缓存"
else
    echo "🔟 Web 目录不存在，跳过"
fi

# 11. 重新获取依赖
echo ""
echo "📦 重新获取 Flutter 依赖..."
flutter pub get

echo ""
echo "✅ 清理完成！"
echo ""
echo "💡 提示："
echo "   - 如果编译仍然卡顿，可以尝试重启 IDE"
echo "   - 如需清理全局 pub 缓存，运行: flutter pub cache repair"
echo "   - 如需清理 IDE 缓存，请手动清理 IDE 的缓存目录"
