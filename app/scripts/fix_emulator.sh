#!/bin/bash

# Android 模拟器连接修复脚本

ANDROID_SDK="${ANDROID_SDK:-$HOME/Library/Android/sdk}"
ADB="$ANDROID_SDK/platform-tools/adb"
EMULATOR="$ANDROID_SDK/emulator/emulator"

# 检查工具是否存在
[ ! -f "$ADB" ] && {
    echo "❌ 错误: 找不到 ADB，请检查 Android SDK 路径"
    echo "   当前路径: $ADB"
    echo "   请设置 ANDROID_SDK 环境变量或确保 Android SDK 已正确安装"
    exit 1
}

echo "🔧 开始修复模拟器连接..."

# 1. 关闭所有模拟器进程
echo "📱 关闭所有模拟器进程..."
killall -9 qemu-system-aarch64 emulator 2>/dev/null || true
sleep 2

# 2. 重启 ADB 服务器
echo "🔄 重启 ADB 服务器..."
$ADB kill-server 2>/dev/null || true
sleep 1
$ADB start-server

# 3. 检查设备状态
echo ""
echo "📋 当前设备状态:"
$ADB devices

# 4. 如果提供了模拟器名称，则启动它
[ -n "$1" ] && {
    AVD_NAME="$1"
    [ ! -f "$EMULATOR" ] && {
        echo "❌ 错误: 找不到 emulator 命令"
        exit 1
    }
    
    echo ""
    echo "🚀 启动模拟器: $AVD_NAME"
    $EMULATOR -avd "$AVD_NAME" -no-snapshot-load > "/tmp/emulator_${AVD_NAME}.log" 2>&1 &
    EMULATOR_PID=$!
    
    echo "⏳ 等待模拟器启动（PID: $EMULATOR_PID）..."
    echo "   日志文件: /tmp/emulator_${AVD_NAME}.log"
    
    # 等待模拟器连接
    for i in {1..30}; do
        sleep 2
        DEVICE_STATUS=$($ADB devices 2>/dev/null | grep "emulator-" | awk '{print $2}' || echo "")
        [ "$DEVICE_STATUS" = "device" ] && {
            echo ""
            echo "✅ 模拟器已成功连接！"
            $ADB devices
            echo ""
            echo "📱 Flutter 设备列表:"
            flutter devices 2>/dev/null || echo "   (Flutter 命令不可用，请稍后运行 'flutter devices' 查看)"
            exit 0
        }
        echo -n "."
    done
    
    echo ""
    echo "⚠️  警告: 模拟器启动超时，但进程仍在运行"
    echo "   请检查日志: /tmp/emulator_${AVD_NAME}.log"
    echo "   或手动运行: flutter devices"
} || {
    echo ""
    echo "💡 提示: 要启动模拟器，请运行:"
    echo "   $0 <模拟器名称>"
    echo ""
    echo "   例如: $0 Pixel_9_Pro_XL"
    echo ""
    echo "   查看可用模拟器: flutter emulators"
}
