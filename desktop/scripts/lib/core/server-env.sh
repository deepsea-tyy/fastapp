# 从 server/.env 读取构建期端口配置。

desktop_read_server_env_var() {
  local key="$1"
  local file="$DESKTOP_SERVER_SRC/.env"

  if [ ! -f "$file" ]; then
    echo "server/.env 不存在: $file" >&2
    return 1
  fi
  grep -E "^${key}=" "$file" 2>/dev/null | tail -1 | sed -E 's/^[^=]+=//; s/^[[:space:]]+//; s/[[:space:]]+$//; s/^["'\''](.*)["'\'']$/\1/' || true
}

desktop_read_server_env_port() {
  local app_port app_ws_port

  app_port=$(desktop_read_server_env_var APP_PORT)
  app_ws_port=$(desktop_read_server_env_var APP_WS_PORT)

  if [ -z "$app_port" ]; then
    echo "server/.env 缺少 APP_PORT" >&2
    return 1
  fi
  if [ -z "$app_ws_port" ]; then
    echo "server/.env 缺少 APP_WS_PORT" >&2
    return 1
  fi

  DESKTOP_APP_PORT="$app_port"
  DESKTOP_APP_WS_PORT="$app_ws_port"
  export DESKTOP_APP_PORT DESKTOP_APP_WS_PORT
}
