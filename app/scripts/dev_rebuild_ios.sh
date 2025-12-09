#!/bin/bash

# iOS 项目重新构建脚本
# 用于清理并重新构建 iOS 项目

set -e

# 设置代理（如果需要翻墙）
# export https_proxy=http://127.0.0.1:7890
# export http_proxy=http://127.0.0.1:7890
# export all_proxy=socks5://127.0.0.1:7890

echo "🧹 开始清理 iOS 项目..."

# 1. 清理 Flutter 构建缓存
echo "1. 清理 Flutter 构建缓存..."
cd "$(dirname "$0")/.."
flutter clean

# 2. 清理 iOS 相关文件
echo "2. 清理 iOS 构建文件和依赖..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/build
rm -rf ios/DerivedData
rm -rf ios/Flutter/Generated.xcconfig
rm -rf ios/Flutter/flutter_export_environment.sh

# 3. 清理项目构建目录
echo "3. 清理项目构建目录..."
rm -rf build

# 4. 重新获取 Flutter 依赖
echo "4. 重新获取 Flutter 依赖..."
flutter pub get

# 5. 预缓存 iOS 工具
echo "5. 预缓存 iOS 工具..."
flutter precache --ios

# 6. 重新安装 CocoaPods 依赖
echo "6. 重新安装 CocoaPods 依赖..."
cd ios
export LANG=en_US.UTF-8
pod deintegrate 2>/dev/null || true
pod install

echo "✅ iOS 项目重新构建完成！"
echo ""
echo "如果遇到 'Null check operator' 错误，这是 Flutter 3.38.3 的已知问题，可以："
echo "1. 使用 Xcode 直接构建: open ios/Runner.xcworkspace"
echo "2. 或者运行: flutter run -d <device_id>"
