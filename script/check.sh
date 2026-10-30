#!/usr/bin/env bash
# 仓库根语法检查：PHP / plugin locale YAML / Python。全部跑完再汇总，不中途退出。
# 默认扫 git 相对 HEAD 的变更（含未跟踪）；--all 扫约定目录；也可再跟路径。
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ALL=0
PATHS=()
for arg in "$@"; do
  if [ "$arg" = "--all" ]; then
    ALL=1
  else
    PATHS+=("$arg")
  fi
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
: >"$tmp/php" ; : >"$tmp/yaml" ; : >"$tmp/py"

rel() {
  local p="$1"
  case "$p" in
    "$ROOT"/*) printf '%s\n' "${p#"$ROOT"/}" ;;
    /*) printf '%s\n' "$p" ;;
    *) printf '%s\n' "$p" ;;
  esac
}

abs() {
  local p="$1"
  case "$p" in
    /*) printf '%s\n' "$p" ;;
    *) printf '%s\n' "$ROOT/$p" ;;
  esac
}

skip_php() {
  case "$1" in
    */vendor/*|vendor/*|*/runtime/*|runtime/*) return 0 ;;
  esac
  return 1
}

skip_py() {
  case "$1" in
    */.venv/*|.venv/*|*/__pycache__/*|*/models/*|tools/models/*|*/runtime/*|tools/runtime/*) return 0 ;;
  esac
  return 1
}

is_locale_yaml() {
  case "$1" in
    server/plugin/*/web/locales/*.yaml|server/plugin/*/web/locales/*.yml) return 0 ;;
    server/plugin/*/*/web/locales/*.yaml|server/plugin/*/*/web/locales/*.yml) return 0 ;;
  esac
  return 1
}

add_php() {
  local f r
  f="$(abs "$1")"
  [ -f "$f" ] || return 0
  r="$(rel "$f")"
  skip_php "$r" && return 0
  case "$r" in *.php) printf '%s\n' "$r" >>"$tmp/php" ;; esac
}

add_py() {
  local f r
  f="$(abs "$1")"
  [ -f "$f" ] || return 0
  r="$(rel "$f")"
  skip_py "$r" && return 0
  case "$r" in *.py) printf '%s\n' "$r" >>"$tmp/py" ;; esac
}

add_yaml() {
  local f r
  f="$(abs "$1")"
  [ -f "$f" ] || return 0
  r="$(rel "$f")"
  is_locale_yaml "$r" || return 0
  printf '%s\n' "$r" >>"$tmp/yaml"
}

add_path() {
  local f r
  f="$(abs "$1")"
  [ -e "$f" ] || return 0
  r="$(rel "$f")"
  if [ -d "$f" ]; then
    find "$f" -type f \( -name '*.php' -o -name '*.py' -o -name '*.yaml' -o -name '*.yml' \) -print |
      while IFS= read -r p; do add_path "$p"; done
    return 0
  fi
  case "$r" in
    *.php) add_php "$r" ;;
    *.py) add_py "$r" ;;
    *.yaml|*.yml) add_yaml "$r" ;;
  esac
}

scan_all() {
  find "$ROOT/server" -type f -name '*.php' ! -path '*/vendor/*' ! -path '*/runtime/*' -print |
    while IFS= read -r p; do add_php "$p"; done
  find "$ROOT/server/plugin" -type f \( -name '*.yaml' -o -name '*.yml' \) -path '*/web/locales/*' -print |
    while IFS= read -r p; do add_yaml "$p"; done
  find "$ROOT/tools" "$ROOT/script" -type f -name '*.py' \
    ! -path '*/.venv/*' ! -path '*/__pycache__/*' ! -path '*/models/*' ! -path '*/runtime/*' -print 2>/dev/null |
    while IFS= read -r p; do add_py "$p"; done
}

if [ "$ALL" -eq 1 ]; then
  scan_all
elif git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  {
    git -C "$ROOT" diff --name-only HEAD
    git -C "$ROOT" ls-files --others --exclude-standard
  } | while IFS= read -r p; do
    [ -n "$p" ] || continue
    add_path "$p"
  done
fi
for p in "${PATHS[@]+"${PATHS[@]}"}"; do
  add_path "$p"
done

sort -u "$tmp/php" -o "$tmp/php"
sort -u "$tmp/yaml" -o "$tmp/yaml"
sort -u "$tmp/py" -o "$tmp/py"

php_n=0 yaml_n=0 py_n=0
php_fail=0 yaml_fail=0 py_fail=0
php_ok=0 yaml_ok=0 py_ok=0

echo "== php =="
if [ ! -s "$tmp/php" ]; then
  echo "(skip: no php files)"
else
  if ! command -v php >/dev/null 2>&1; then
    echo "FAIL php not found"
    php_fail=1
  else
    while IFS= read -r r; do
      php_n=$((php_n + 1))
      out="$(php -l "$ROOT/$r" 2>&1)" || true
      case "$out" in
        *"No syntax errors detected"*)
          php_ok=$((php_ok + 1))
          echo "OK $r"
          ;;
        *)
          php_fail=$((php_fail + 1))
          echo "FAIL $r"
          printf '%s\n' "$out"
          ;;
      esac
    done <"$tmp/php"
    echo "php ok=$php_ok fail=$php_fail / $php_n"
  fi
fi

echo
echo "== yaml =="
if [ ! -s "$tmp/yaml" ]; then
  echo "(skip: no locale yaml files)"
else
  yaml_out="$(
    cd "$ROOT/admin" && CHECK_ROOT="$ROOT" node --input-type=module -e '
import { parseForESLint } from "yaml-eslint-parser";
import fs from "fs";
import path from "path";
const root = process.env.CHECK_ROOT || "";
const files = fs.readFileSync(0, "utf8").split("\n").filter(Boolean);
let failed = 0;
let ok = 0;
for (const rel of files) {
  const file = path.join(root, rel);
  try {
    parseForESLint(fs.readFileSync(file, "utf8"), { filePath: file });
    ok += 1;
    console.log("OK", rel);
  } catch (e) {
    failed += 1;
    console.error("FAIL", rel, e && e.message ? e.message : e);
  }
}
console.log("yaml ok=" + ok + " fail=" + failed + " / " + files.length);
process.exit(failed ? 1 : 0);
' <"$tmp/yaml" 2>&1
  )" && yaml_st=0 || yaml_st=$?
  printf '%s\n' "$yaml_out"
  yaml_fail="$(printf '%s\n' "$yaml_out" | grep -c '^FAIL ' || true)"
  yaml_ok="$(printf '%s\n' "$yaml_out" | grep -c '^OK ' || true)"
  if [ "$yaml_st" -ne 0 ] && [ "$yaml_fail" -eq 0 ]; then
    yaml_fail=1
  fi
fi

echo
echo "== python =="
if [ ! -s "$tmp/py" ]; then
  echo "(skip: no python files)"
else
  PY=""
  PY_UV=0
  if [ -x "$ROOT/tools/.venv/bin/python" ]; then
    PY="$ROOT/tools/.venv/bin/python"
  elif command -v uv >/dev/null 2>&1; then
    PY_UV=1
  elif command -v python3 >/dev/null 2>&1; then
    PY="python3"
  else
    echo "FAIL python not found (tools/.venv, uv, or python3)"
    py_fail=1
  fi
  if [ "$py_fail" -eq 0 ]; then
    while IFS= read -r r; do
      py_n=$((py_n + 1))
      if [ "$PY_UV" -eq 1 ]; then
        out="$(cd "$ROOT/tools" && uv run python -m py_compile "$ROOT/$r" 2>&1)" && st=0 || st=$?
      else
        out="$("$PY" -m py_compile "$ROOT/$r" 2>&1)" && st=0 || st=$?
      fi
      if [ "$st" -eq 0 ]; then
        py_ok=$((py_ok + 1))
        echo "OK $r"
      else
        py_fail=$((py_fail + 1))
        echo "FAIL $r"
        printf '%s\n' "$out"
      fi
    done <"$tmp/py"
    echo "python ok=$py_ok fail=$py_fail / $py_n"
  fi
fi

echo
if [ "$php_fail" -eq 0 ] && [ "$yaml_fail" -eq 0 ] && [ "$py_fail" -eq 0 ]; then
  echo "== summary == OK"
  exit 0
fi
echo "== summary == FAIL php=$php_fail yaml=$yaml_fail python=$py_fail"
exit 1
