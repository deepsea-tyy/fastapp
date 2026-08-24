/**
 * 构建 StoryStudio Phaser 位图/MSDF 字体图集。
 * 用法（仓库根）：
 *   node script/font/gen-bitmap-font.mjs
 *
 * - charset.txt 五行：英数标点 / 简 / 繁 / 日 / 韩（first-wins 去重）
 * - 各脚本用对应 FONT_OTF 生成 MSDF 临时 sheet
 * - pack-msdf-atlas.py：字形级 shelf 装箱 → admin/public/font/bitmap/
 *
 * 依赖：npx msdf-bmfont-xml、Python3 + Pillow
 */
import { execFileSync } from 'node:child_process'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const REPO_ROOT = path.resolve(__dirname, '../..')
const SCRIPT_DIR = __dirname
const CHARSET_PATH = path.join(SCRIPT_DIR, 'charset.txt')
const FONT_DIR = path.join(REPO_ROOT, 'admin/public/font/alibaba-pu-hui-ti-3')
const OUT_DIR = path.join(REPO_ROOT, 'admin/public/font/bitmap')

/** 行序 = first-wins；font = 渲染用 OTF locale */
const SCRIPT_ROWS = [
  { id: 'latn', font: 'sc' },
  { id: 'sc', font: 'sc' },
  { id: 'tc', font: 'tc' },
  { id: 'jp', font: 'jp' },
  { id: 'kr', font: 'kr' },
]

const FONT_SIZE = 42
const ATLAS_SIZE = 8192
const MAX_CHARS = 15000
const FONT_STEM = `AlibabaPuHuiTi-3-55-Regular-${FONT_SIZE}`
const SHARED_PNG = `${FONT_STEM}.png`
const SHARED_JSON = `${FONT_STEM}.json`
const LEGACY_NAMES = [
  `alibaba-pu-hui-ti-3-${FONT_SIZE}`,
  `puhui-${FONT_SIZE}`,
  ...['sc', 'tc', 'jp', 'kr'].map(l => `puhui-${l}-${FONT_SIZE}`),
]

/** locale → OTF（{locale}-regular.otf） */
const FONT_OTF = {
  sc: ['sc-regular.otf'],
  tc: ['tc-regular.otf'],
  jp: ['jp-regular.otf'],
  kr: ['kr-regular.otf'],
}

function uniqueChars(text) {
  return [...new Set([...text].filter(ch => !/\s/.test(ch)))].join('')
}

/**
 * 按 charset.txt 行拆脚本桶；重叠码位 first-wins（行序）。
 * 同 font 的桶合并（latn+sc → 一次 sc OTF）。
 */
function parseCharsetByScript() {
  if (!fs.existsSync(CHARSET_PATH))
    throw new Error(`缺少 charset.txt: ${CHARSET_PATH}`)

  const lines = fs.readFileSync(CHARSET_PATH, 'utf8').split(/\r?\n/)
  const owned = new Set()
  /** @type {Map<string, { id: string, font: string, chars: string }>} */
  const byFont = new Map()

  for (let i = 0; i < SCRIPT_ROWS.length; i++) {
    const row = SCRIPT_ROWS[i]
    const raw = lines[i] ?? ''
    const chars = []
    for (const ch of uniqueChars(raw)) {
      if (owned.has(ch))
        continue
      owned.add(ch)
      chars.push(ch)
    }
    console.log(`  [${row.id}] keep=${chars.length} (line unique=${uniqueChars(raw).length})`)
    if (chars.length === 0)
      continue

    const prev = byFont.get(row.font)
    if (prev) {
      prev.chars += chars.join('')
      prev.id = `${prev.id}+${row.id}`
    }
    else {
      byFont.set(row.font, { id: row.id, font: row.font, chars: chars.join('') })
    }
  }

  const total = owned.size
  if (total > MAX_CHARS) {
    throw new Error(
      `charset 超限: ${total} > ${MAX_CHARS}。请精简 charset.txt`,
    )
  }
  console.log(`charset total unique: ${total} / ${MAX_CHARS}`)
  return [...byFont.values()]
}

function resolveFontOtf(locale) {
  const candidates = FONT_OTF[locale] ?? []
  for (const name of candidates) {
    const full = path.join(FONT_DIR, name)
    if (fs.existsSync(full))
      return full
  }
  throw new Error(`字体源文件不存在 (${locale}): ${candidates.map(n => path.join(FONT_DIR, n)).join(' 或 ')}`)
}

function runMsdfForBucket(bucket, tmpDir) {
  const fontOtf = resolveFontOtf(bucket.font)
  const charsetPath = path.join(tmpDir, `charset-${bucket.id}.txt`)
  fs.writeFileSync(charsetPath, bucket.chars, 'utf8')

  const outBase = path.join(tmpDir, `${FONT_STEM}-${bucket.id}`)
  const args = [
    '--yes',
    'msdf-bmfont-xml',
    '-f', 'json',
    '-t', 'msdf',
    '-s', String(FONT_SIZE),
    '-i', charsetPath,
    '-o', outBase,
    '-m', `${ATLAS_SIZE},${ATLAS_SIZE}`,
    '-p', '2',
    '-b', '2',
    '-r', '4',
    fontOtf,
  ]
  console.log(`\n→ [${bucket.id}/${bucket.font}] npx ${args.slice(1).join(' ')}`)
  execFileSync('npx', args, { stdio: 'inherit', cwd: REPO_ROOT })

  const png = `${outBase}.png`
  const stem = path.basename(fontOtf, '.otf')
  const fontJson = path.join(tmpDir, `${stem}.json`)
  const targetJson = `${outBase}.json`
  if (!fs.existsSync(png) || !fs.existsSync(fontJson)) {
    throw new Error(`输出缺失: ${png} / ${fontJson}`)
  }
  fs.renameSync(fontJson, targetJson)

  const meta = JSON.parse(fs.readFileSync(targetJson, 'utf8'))
  if ((meta.pages ?? []).length > 1) {
    throw new Error(`[${bucket.id}] 已拆成多页，charset 过大；请减少字符或字号`)
  }
  console.log(`  tmp ok: ${png} (chars=${meta.chars?.length ?? '?'})`)
  return { id: bucket.id, png, json: targetJson, meta }
}

function packUnifiedAtlas(sheets) {
  const packer = path.join(SCRIPT_DIR, 'pack-msdf-atlas.py')
  const listPath = path.join(OUT_DIR, '_pack-glyphs.json')
  const outPng = path.join(OUT_DIR, SHARED_PNG)
  const outJson = path.join(OUT_DIR, SHARED_JSON)
  fs.writeFileSync(
    listPath,
    JSON.stringify({
      outPng,
      outJson,
      pageName: SHARED_PNG,
      maxSize: ATLAS_SIZE,
      pad: 2,
      sheets: sheets.map(s => ({ png: s.png, meta: s.meta })),
    }),
    'utf8',
  )
  console.log(`\n→ glyph pack: python3 ${packer}`)
  const out = execFileSync('python3', [packer, listPath], { encoding: 'utf8' })
  fs.unlinkSync(listPath)
  const summary = JSON.parse(out.trim().split('\n').pop())
  console.log(`packed → ${outPng}`, summary)
  console.log(`  json → ${outJson}`)
  return summary
}

function cleanupOrphans() {
  for (const stem of LEGACY_NAMES) {
    for (const ext of ['png', 'json']) {
      const orphan = path.join(OUT_DIR, `${stem}.${ext}`)
      if (fs.existsSync(orphan)) {
        fs.unlinkSync(orphan)
        console.log(`  removed legacy ${path.basename(orphan)}`)
      }
    }
  }
}

function main() {
  if (!fs.existsSync(FONT_DIR)) {
    throw new Error(`字体目录不存在: ${FONT_DIR}`)
  }
  fs.mkdirSync(OUT_DIR, { recursive: true })

  console.log('parse charset.txt …')
  const buckets = parseCharsetByScript()
  if (buckets.length === 0)
    throw new Error('charset.txt 无有效字符')

  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'puhui-msdf-'))
  try {
    const sheets = buckets.map(b => runMsdfForBucket(b, tmpDir))
    packUnifiedAtlas(sheets)
  }
  finally {
    fs.rmSync(tmpDir, { recursive: true, force: true })
  }

  cleanupOrphans()
  console.log(`\n完成。共享图: ${SHARED_PNG}；json: ${SHARED_JSON}`)
  console.log(`  → ${OUT_DIR}`)
}

main()
