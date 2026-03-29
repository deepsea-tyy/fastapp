#!/bin/bash

# macOS 多场景 DNS 切换脚本
# 支持: dev / daily / auto
# 作者: 助手 (Qwen)
# 用法: ./dns-switch.sh [dev|daily|auto|show]

set -e

# 自动检测主网络服务（优先 Wi-Fi，其次有线）
detect_service() {
  # 尝试获取当前活跃的网络接口
  ACTIVE_IF=$(route get default 2>/dev/null | grep interface | awk '{print $2}' | head -1)
  if [ -n "$ACTIVE_IF" ]; then
    # 通过接口名反查服务名
    SERVICE=$(networksetup -listallnetworkservices | while read line; do
      if [[ "$line" != *"*" ]] && [[ -n "$line" ]]; then
        IFACE=$(networksetup -getinfo "$line" 2>/dev/null | grep "Ethernet Address" -B5 | grep "Device" | awk '{print $2}')
        if [ "$IFACE" = "$ACTIVE_IF" ]; then
          echo "$line"
          break
        fi
      fi
    done)
  fi

  # 如果上面失败，回退到关键词匹配
  if [ -z "$SERVICE" ]; then
    SERVICE=$(networksetup -listallnetworkservices | grep -E "Wi-Fi|Ethernet|en0|en1" | head -1)
  fi

  if [ -z "$SERVICE" ]; then
    echo "❌ 未找到有效的网络服务（Wi-Fi 或以太网）" >&2
    exit 1
  fi
}

detect_service
echo "📡 当前网络服务: $SERVICE"

apply_dns() {
  local name="$1"
  shift
  local servers=("$@")
  echo "🔧 切换到 $name 模式: ${servers[*]}"
  networksetup -setdnsservers "$SERVICE" "${servers[@]}"
  echo "✅ 已设置 DNS: ${servers[*]}"
}

case "$1" in
  dev)
    apply_dns "开发模式" 1.1.1.1 8.8.8.8
    ;;

  daily)
    apply_dns "日常模式" 223.5.5.5 119.29.29.29
    ;;

  auto)
    echo "🏠 恢复为自动 DNS（DHCP）..."
    networksetup -setdnsservers "$SERVICE" "Empty"
    echo "✅ 已恢复自动 DNS"
    ;;

  show)
    echo "🔍 当前 DNS 配置:"
    networksetup -getdnsservers "$SERVICE"
    exit 0
    ;;

  *)
    echo "用法: $0 {dev|daily|auto|show}"
    echo ""
    echo "  dev    - 开发/测试/GitHub: 1.1.1.1 + 8.8.8.8"
    echo "  daily  - 日常上网（混合）: 223.5.5.5（阿里） + 119.29.29.29（腾讯）"
    echo "  auto   - 恢复自动（由路由器分配）"
    echo "  show   - 显示当前 DNS"
    exit 1
    ;;
esac

# 刷新 DNS 缓存（静默处理权限错误）
echo "🔄 正在刷新 DNS 缓存..."
{
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
} >/dev/null 2>&1

echo "✨ 切换完成！"