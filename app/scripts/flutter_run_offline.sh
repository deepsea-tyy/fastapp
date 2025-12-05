#!/bin/bash

# Flutter 快速运行脚本
# 跳过自动 pub get，避免每次检查包更新

cd "$(dirname "$0")/.."

# 检查依赖是否已获取（通过检查 .dart_tool/package_config.json）
if [ ! -f ".dart_tool/package_config.json" ]; then
    echo "📦 首次运行，获取依赖..."
    flutter pub get
else
    echo "✅ 依赖已存在，跳过检查"
fi

# 使用 --no-pub 跳过 flutter run 的自动 pub get 检查
flutter run --no-pub "$@"
