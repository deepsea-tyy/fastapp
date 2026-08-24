# 阿里巴巴普惠体 — Web 字体

DOM 用 **woff2**；FFmpeg 水印用 **otf**（仅 `{locale}-regular.otf`）；Phaser MSDF 见 `admin/public/font/bitmap/`。

## 统一命名

```
{locale}-{weight}.woff2
{locale}-regular.otf          # FFmpeg 每语种 1 个
```

| 文件 `{weight}` | CSS `font-weight` | 官网字重 |
|---|---|---|
| `regular` | 400 | 55 Regular |
| `medium` | 500 | 65 Medium |
| `bold` | 700 | 85 Bold |

`{locale}` ∈ `sc` | `tc` | `jp` | `kr`

示例：`sc-regular.woff2`、`tc-medium.woff2`、`jp-bold.woff2`

**CSS family**（与文件名独立）：`AlibabaPuHuiTi-3-55-Regular-{locale}`  
栈：`sc` → `tc` → `jp` → `kr` → `sans-serif`（`admin/src/assets/styles/resources/fonts.scss`）。

---

## 手动下载 — 官网

入口：[https://www.alibabafonts.com/#/font](https://www.alibabafonts.com/#/font)

下载 woff2 / otf 后 **重命名** 为上表格式放入本目录。

| locale | 官网产品 | 需补文件 |
|---|---|---|
| **sc** | 阿里巴巴普惠体 3.0 | `sc-regular/medium/bold.woff2` + `sc-regular.otf` |
| **tc** | 阿里巴巴普惠體 TC | `tc-regular/medium/bold.woff2` + `tc-regular.otf` |
| **jp** | 阿里巴巴普惠体 日文 | `jp-regular/medium/bold.woff2` + `jp-regular.otf` |
| **kr** | 阿里巴巴普惠体 韩文 | `kr-regular/medium/bold.woff2` + `kr-regular.otf` |

---

## 手动下载 — jsDelivr（仅 sc woff2）

下载后重命名为本仓库文件名：

| 本仓库文件名 | 下载地址 |
|---|---|
| `sc-regular.woff2` | https://cdn.jsdelivr.net/npm/alibabapuhuiti-3-55-regular@1.0.0/AlibabaPuHuiTi-3-55-Regular.woff2 |
| `sc-medium.woff2` | https://cdn.jsdelivr.net/npm/alibabapuhuiti-3-65-medium@1.0.0/AlibabaPuHuiTi-3-65-Medium.woff2 |
| `sc-bold.woff2` | https://cdn.jsdelivr.net/npm/alibabapuhuiti-3-85-bold@1.0.0/AlibabaPuHuiTi-3-85-Bold.woff2 |

```bash
DEST=admin/public/font/alibaba-pu-hui-ti-3
curl -fsSL -o "$DEST/sc-regular.woff2" \
  "https://cdn.jsdelivr.net/npm/alibabapuhuiti-3-55-regular@1.0.0/AlibabaPuHuiTi-3-55-Regular.woff2"
curl -fsSL -o "$DEST/sc-medium.woff2" \
  "https://cdn.jsdelivr.net/npm/alibabapuhuiti-3-65-medium@1.0.0/AlibabaPuHuiTi-3-65-Medium.woff2"
curl -fsSL -o "$DEST/sc-bold.woff2" \
  "https://cdn.jsdelivr.net/npm/alibabapuhuiti-3-85-bold@1.0.0/AlibabaPuHuiTi-3-85-Bold.woff2"
```

**tc / jp / kr** 请走官网产品页。

---

## 完整清单

**Web woff2**（12 个）：`{sc,tc,jp,kr}-{regular,medium,bold}.woff2`

**FFmpeg otf**（4 个）：`{sc,tc,jp,kr}-regular.otf`

---

## 校验

```bash
export REPO_ROOT=$PWD
source desktop/scripts/lib/stage/fonts.sh && desktop_sync_fonts
```
