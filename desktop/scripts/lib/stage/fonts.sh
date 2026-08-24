# 普惠体：校验 admin/public/font/alibaba-pu-hui-ti-3/（见目录内 README.md）

desktop_sync_fonts() {
  local dest="$REPO_ROOT/admin/public/font/alibaba-pu-hui-ti-3"
  local readme="$dest/README.md"

  mkdir -p "$dest"

  local locales=(sc tc jp kr)
  local weights=(regular medium bold)
  local locale weight f

  for locale in "${locales[@]}"; do
    for weight in "${weights[@]}"; do
      f="$dest/${locale}-${weight}.woff2"
      if [ ! -f "$f" ]; then
        echo "    警告: Web 字体缺失 $f" >&2
        echo "          见 $readme" >&2
      fi
    done
    f="$dest/${locale}-regular.otf"
    if [ ! -f "$f" ]; then
      echo "    警告: FFmpeg otf 缺失 $f" >&2
    fi
  done
}
