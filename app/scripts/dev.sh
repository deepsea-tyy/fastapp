#!/bin/bash

# Flutter 快速运行脚本
# 自动检查设备连接，修复模拟器问题，跳过自动 pub get

cd "$(dirname "$0")/.."

# 配置
ANDROID_SDK="${ANDROID_SDK:-$HOME/Library/Android/sdk}"
ADB="$ANDROID_SDK/platform-tools/adb"

# 检查是否有可用设备
has_devices() {
    command -v flutter >/dev/null 2>&1 && \
    flutter devices --machine 2>/dev/null | grep -q '"id":'
}

# 获取 Android 设备状态：0=在线, 2=离线, 1=无设备
get_android_status() {
    [ ! -f "$ADB" ] && return 1
    local devices=$($ADB devices 2>/dev/null)
    echo "$devices" | grep -q "device$" && return 0
    echo "$devices" | grep -q "offline" && return 2
    return 1
}

# 修复 Android 连接
fix_android() {
    echo "🔧 检测到 Android 设备连接问题，正在修复..."
    killall -9 qemu-system-aarch64 emulator 2>/dev/null || true
    sleep 2
    [ -f "$ADB" ] && $ADB kill-server 2>/dev/null && sleep 1 && $ADB start-server
    echo "✅ ADB 服务器已重启"
}

# 显示提示信息
show_hint() {
    echo "💡 提示: 可以运行以下命令启动模拟器:"
    echo "   ./scripts/fix_emulator.sh Pixel_9_Pro_XL"
    echo ""
    echo "   或查看可用模拟器: flutter emulators"
}

# 检查并获取依赖
[ ! -f ".dart_tool/package_config.json" ] && {
    echo "📦 首次运行，获取依赖..."
    flutter pub get || {
        echo "❌ 依赖获取失败，请检查网络连接或 Flutter 环境"
        exit 1
    }
} || echo "✅ 依赖已存在，跳过检查"

# 解析参数
ARGS=()
ANDROID_REQUESTED=false
FIRST_POS_ARG=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device)
            [[ "$2" == *"android"* || "$2" == *"emulator"* ]] && ANDROID_REQUESTED=true
            ARGS+=("$1" "$2")
            FIRST_POS_ARG=false
            shift 2
            ;;
        -*)
            # Flutter 选项参数，直接添加
            ARGS+=("$1")
            shift
            ;;
        *)
            # 第一个位置参数且不是选项，可能是设备 ID
            if [ "$FIRST_POS_ARG" = true ] && [[ "$1" =~ ^(emulator-|android|ios|macos|chrome|web|linux|windows|[a-z0-9_-]+)$ ]]; then
                ARGS+=("-d" "$1")
                [[ "$1" == *"android"* || "$1" == *"emulator"* ]] && ANDROID_REQUESTED=true
                FIRST_POS_ARG=false
            else
                ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

# 设备检查和修复
if ! has_devices; then
    echo "⚠️  未检测到可用设备"
    get_android_status
    case $? in
        2)  # 离线设备
            fix_android
            sleep 2
            has_devices && echo "✅ 设备连接已修复" || {
                echo "💡 提示: 可以手动运行以下命令修复连接:"
                echo "   ./scripts/fix_emulator.sh [模拟器名称]"
                echo ""
                echo "   或查看可用设备: flutter devices"
            }
            ;;
        1)  # 无设备
            show_hint
            ;;
    esac
elif [ "$ANDROID_REQUESTED" = true ]; then
    get_android_status
    case $? in
        2) fix_android && sleep 2 ;;
        1) echo "⚠️  未检测到 Android 设备" && show_hint ;;
    esac
fi

# 显示设备列表并运行
echo ""
echo "📱 当前可用设备:"
flutter devices 2>/dev/null || echo "   (无法获取设备列表)"
echo ""
echo "🚀 启动应用..."
flutter run --no-pub "${ARGS[@]}"
