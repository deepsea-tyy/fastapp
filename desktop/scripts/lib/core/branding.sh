# 从 tauri.conf 同步的 branding.env（desktop/.work/，跨 stage clean 持久）

desktop_load_branding_env() {
  local branding="$DESKTOP_BRANDING_ENV"
  local env_line key val

  if [ ! -f "$branding" ]; then
    echo "branding.env 不存在: $branding (请先执行 tauri-conf stage)" >&2
    return 1
  fi

  while IFS= read -r env_line || [ -n "$env_line" ]; do
    case "$env_line" in
      '' | '#'*) continue ;;
      *=*)
        key=${env_line%%=*}
        val=${env_line#*=}
        case "$key" in
          PRODUCT_NAME | LOGO_REL)
            printf -v "$key" '%s' "$val"
            export "$key"
            ;;
        esac
        ;;
    esac
  done <"$branding"

  if [ -z "${PRODUCT_NAME:-}" ] || [ -z "${LOGO_REL:-}" ]; then
    echo "branding.env 缺少 PRODUCT_NAME 或 LOGO_REL: $branding" >&2
    return 1
  fi
}

desktop_sync_admin_branding() {
  local logo_src icon_ico icon_png

  logo_src="$DESKTOP_ROOT/$LOGO_REL"
  if [ ! -f "$logo_src" ]; then
    echo "logo 不存在: $logo_src" >&2
    return 1
  fi

  icon_ico="$DESKTOP_ROOT/src-tauri/icons/icon.ico"
  icon_png="$DESKTOP_ROOT/src-tauri/icons/icon.png"
  if [ ! -f "$icon_ico" ] && [ ! -f "$icon_png" ]; then
    echo "Tauri icons 不存在（请先执行 tauri-conf stage）" >&2
    return 1
  fi

  echo "    sync admin branding (productName=$PRODUCT_NAME)"
  cp "$logo_src" "$REPO_ROOT/admin/public/logo.png"
  if [ -f "$icon_ico" ]; then
    cp "$icon_ico" "$REPO_ROOT/admin/public/favicon.ico"
  else
    cp "$icon_png" "$REPO_ROOT/admin/public/favicon.ico"
  fi
}
