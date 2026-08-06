#!/bin/bash

# 定义路径
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)
SERVER_DIR="$BASE_DIR/server"
PLUGIN_DIR="$SERVER_DIR/plugin"
STORAGE_DIR="$SERVER_DIR/storage"
PHAR_FILE="$SERVER_DIR/fastapp.phar"

# 清理运行时容器
rm -rf "$SERVER_DIR/runtime/container"

# 1. 删除已存在的 fastapp.phar
if [ -f "$PHAR_FILE" ]; then
    echo "删除已存在的 fastapp.phar..."
    rm "$PHAR_FILE"
fi

# 2. 将plugin和storage移到server同级目录
if [ -d "$PLUGIN_DIR" ]; then
    echo "移动plugin目录到server同级..."
    mv "$PLUGIN_DIR" "$BASE_DIR/"
fi

if [ -d "$STORAGE_DIR" ]; then
    echo "移动storage目录到server同级..."
    mv "$STORAGE_DIR" "$BASE_DIR/"
fi

# 3. 打包
echo "开始打包..."
cd "$SERVER_DIR"
php -d phar.readonly=Off bin/hyperf.php phar:build

# 4. 复位 - 将plugin和storage移回server目录
echo "复位plugin和storage目录..."
if [ -d "$BASE_DIR/plugin" ]; then
    mv "$BASE_DIR/plugin" "$SERVER_DIR/"
fi

if [ -d "$BASE_DIR/storage" ]; then
    mv "$BASE_DIR/storage" "$SERVER_DIR/"
fi

echo "打包完成!"
