#!/usr/bin/env node
/**
 * 同步根目录 docs 下的文档到 website/public/docs 目录
 * 用于 Docsify 文档系统
 */
import { readdir, readFile, writeFile, mkdir, stat, rm } from 'fs/promises'
import { join, dirname, relative, extname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const rootDir = join(__dirname, '..')
const docsDir = join(rootDir, 'public', 'docs')
const sourceDocsDir = join(rootDir, '..', 'docs')

const ALLOWED_EXTENSIONS = ['.md', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp']

// 文档配置
const docSources = [
  { name: 'server', path: join(sourceDocsDir, 'server'), label: '后端服务' },
  { name: 'app', path: join(sourceDocsDir, 'app'), label: '移动端' },
  { name: 'web', path: join(sourceDocsDir, 'web'), label: '管理后台' },
  { name: 'website', path: join(sourceDocsDir, 'website'), label: '企业官网' }
]

// 文档排序配置
const sortConfig = {
  directories: {
    server: ['getting-started', 'development', 'features', 'permission'],
    app: ['开发指南.md', '移动端应用.md', '架构设计.md', '环境配置.md', '问题排查.md'],
    web: ['开发指南.md', '图标使用指南.md', '图表使用指南.md'],
    website: ['企业官网.md']
  },
  files: {
    'server/getting-started': ['开发指南.md', '快速开始.md'],
    'server/development': ['开发规范.md', '配置说明.md', 'AI辅助开发流程指南.md', 'AI开发提示词模板.md'],
    'server/features': ['核心功能.md', '代码生成器.md', '插件系统使用指南.md', 'WebSocket开发文档.md', '数据库迁移工具使用指南.md', 'IP地理位置查询服务使用指南.md', 'Hyperf监听器与异步操作指南.md'],
    'server/permission': ['权限系统使用文档.md', '用户部门与角色部门配合使用详解.md', 'Casbin权限规则表说明.md']
  }
}

// 目录名称映射（英文目录名 -> 中文显示名）
const dirNameMap = {
  'server': {
    'getting-started': '快速开始',
    'development': '开发指南',
    'features': '核心功能',
    'permission': '权限系统'
  },
  'app': {},
  'web': {},
  'website': {}
}

// 工具函数
const getStat = async (path) => {
  try {
    return await stat(path)
  } catch {
    return null
  }
}

const isDir = async (path) => {
  const stats = await getStat(path)
  return stats?.isDirectory() ?? false
}

const ensureDir = async (dir) => {
  try {
    await mkdir(dir, { recursive: true })
  } catch {
    // 目录已存在，忽略
  }
}

// 转换图片路径为绝对路径
const transformImagePaths = (content) => {
  return content
    .replace(/src="(\.\.\/|\.\/|)assets\/([^"]+)"/g, 'src="/docs/assets/$2"')
    .replace(/src="\/assets\/([^"]+)"/g, 'src="/docs/assets/$1"')
    .replace(/!\[([^\]]*)\]\((docs|\.\/docs|\.)\/assets\/([^)]+)\)/g, '![$1](/docs/assets/$3)')
}

// 清理目标目录（只保留 index.html）
const cleanDocsDir = async () => {
  try {
    const entries = await readdir(docsDir, { withFileTypes: true })
    for (const entry of entries) {
      if (entry.name !== 'index.html' && entry.name !== '.sync-timestamp') {
        const entryPath = join(docsDir, entry.name)
        await rm(entryPath, { recursive: true, force: true })
        console.log(`✓ 已删除: ${entry.name}${entry.isDirectory() ? '/' : ''}`)
      }
    }
  } catch {
    // 目录不存在或为空
  }
}

// 转换文档内链接路径（适配 Docsify）
const transformDocLinks = (content, relativePath) => {
  const currentDir = relativePath.split('/').slice(0, -1).join('/')
  const categories = ['server', 'app', 'web', 'website']
  
  return content.replace(/\]\(([^)]+\.md(?:#[^)]+)?)\)/g, (match, linkPath) => {
    if (linkPath.startsWith('/')) return match
    
    const [path, anchor] = linkPath.split('#')
    const anchorPart = anchor ? `#${anchor}` : ''
    
    let targetPath = path
    if (path.startsWith('../')) {
      const parts = currentDir.split('/').filter(Boolean)
      const upLevels = (path.match(/\.\.\//g) || []).length
      const remaining = path.replace(/\.\.\//g, '')
      const newParts = parts.slice(0, -upLevels)
      targetPath = newParts.length ? `${newParts.join('/')}/${remaining}` : remaining
    } else if (path.startsWith('./')) {
      targetPath = currentDir ? `${currentDir}/${path.slice(2)}` : path.slice(2)
    } else if (!path.includes('/')) {
      targetPath = currentDir ? `${currentDir}/${path}` : path
    }
    
    // 确保路径以文档分类开头
    if (!categories.some(cat => targetPath.startsWith(`${cat}/`))) {
      const category = currentDir.split('/')[0] || 'server'
      targetPath = `${category}/${targetPath}`
    }
    
    return `](${targetPath}${anchorPart})`
  })
}

// 复制文件（处理 Markdown 图片路径和链接路径）
const copyFile = async (src, dest) => {
  try {
    const ext = extname(src).toLowerCase()
    await ensureDir(dirname(dest))
    
    if (ext === '.md') {
      // Markdown 文件：文本模式，转换图片路径和链接路径
      let content = await readFile(src, 'utf-8')
      const relativePath = relative(sourceDocsDir, src)
      content = transformImagePaths(content)
      content = transformDocLinks(content, relativePath)
      await writeFile(dest, content, 'utf-8')
    } else {
      // 图片等二进制文件：直接复制
      const content = await readFile(src)
      await writeFile(dest, content)
    }
    
    console.log(`✓ 已同步: ${relative(sourceDocsDir, src)}`)
    return true
  } catch (error) {
    console.error(`✗ 复制失败: ${relative(sourceDocsDir, src)} - ${error.message}`)
    return false
  }
}

// 同步目录（直接覆盖）
const syncDirectory = async (sourceDir, targetDir) => {
  try {
    const entries = await readdir(sourceDir, { withFileTypes: true })
    for (const entry of entries) {
      const srcPath = join(sourceDir, entry.name)
      const destPath = join(targetDir, entry.name)
      if (entry.isDirectory()) {
        await syncDirectory(srcPath, destPath)
      } else if (entry.isFile() && ALLOWED_EXTENSIONS.includes(extname(entry.name).toLowerCase())) {
        await copyFile(srcPath, destPath)
      }
    }
  } catch (error) {
    console.error(`✗ 同步失败: ${relative(sourceDocsDir, sourceDir)} - ${error.message}`)
  }
}

// 扫描所有 Markdown 文件
const scanMarkdownFiles = async (dir, basePath) => {
  const files = []
  const entries = await readdir(dir, { withFileTypes: true })
  for (const entry of entries) {
    const fullPath = join(dir, entry.name)
    if (entry.isDirectory()) {
      files.push(...await scanMarkdownFiles(fullPath, basePath))
    } else if (entry.isFile() && extname(entry.name) === '.md') {
      const relativePath = relative(basePath, fullPath)
      files.push({
        path: relativePath.replace(/\.md$/, ''),
        name: entry.name.replace(/\.md$/, ''),
        relativePath
      })
    }
  }
  return files
}

// 排序工具
const sortByOrder = (items, order, getKey = (item) => item) => {
  return items.sort((a, b) => {
    const keyA = getKey(a)
    const keyB = getKey(b)
    const indexA = order.indexOf(keyA)
    const indexB = order.indexOf(keyB)
    
    if (indexA >= 0 && indexB >= 0) return indexA - indexB
    if (indexA >= 0) return -1
    if (indexB >= 0) return 1
    return String(keyA).localeCompare(String(keyB))
  })
}

// 生成侧边栏
const generateSidebar = async () => {
  const sidebar = []
  
  // 添加根目录 README 作为第一项
  sidebar.push('* [项目前言](README.md)')
  sidebar.push('')
  
  for (const source of docSources) {
    if (!(await isDir(source.path))) continue
    
    const files = await scanMarkdownFiles(source.path, source.path)
    if (files.length === 0) continue
    
    sidebar.push(`* ${source.label}文档`)
    
    // 按目录分组
    const grouped = files.reduce((acc, file) => {
      const dir = file.relativePath.split('/').slice(0, -1).join('/') || 'root'
      if (!acc[dir]) acc[dir] = []
      acc[dir].push(file)
      return acc
    }, {})
    
    const dirOrder = sortConfig.directories[source.name] || []
    const fileOrder = sortConfig.files || {}
    
    // 处理根目录文件
    const rootFiles = grouped['root'] || []
    const rootFileOrder = dirOrder.filter(item => item.endsWith('.md'))
    sortByOrder(rootFiles, rootFileOrder, file => `${file.name}.md`)
    rootFiles.forEach(file => {
      sidebar.push(`  * [${file.name}](${source.name}/${file.path}.md)`)
    })
    
    // 处理子目录
    const subDirs = Object.keys(grouped).filter(dir => dir !== 'root')
    const dirOrderWithoutFiles = dirOrder.filter(item => !item.endsWith('.md'))
    sortByOrder(subDirs, dirOrderWithoutFiles, dir => dir.split('/').pop())
    
    for (const dir of subDirs) {
      const dirName = dir.split('/').pop()
      // 获取目录显示名称（优先使用配置的 label，否则使用目录名）
      const dirLabel = dirNameMap[source.name]?.[dirName] || dirName
      sidebar.push(`  * ${dirLabel}`)
      const fileList = grouped[dir]
      const dirKey = `${source.name}/${dir}`
      const fileOrderForDir = fileOrder[dirKey] || []
      sortByOrder(fileList, fileOrderForDir, file => `${file.name}.md`)
      fileList.forEach(file => {
        sidebar.push(`    * [${file.name}](${source.name}/${file.path}.md)`)
      })
    }
  }
  return sidebar.join('\n')
}

// 转换 README 中的链接路径和图片路径
const transformReadmeLinks = (content) => {
  return content
    .replace(/\]\(docs\/([^)]+)\)/g, '](./$1)')
    .replace(/\]\(\.\/docs\/([^)]+)\)/g, '](./$1)')
    .replace(/\]\(\.\/docs\//g, '](./')
    .replace(/<img\s+([^>]*\s+)?src="(docs|\.\/docs|\.)\/assets\/([^"]+)"([^>]*)>/gi, '<img $1src="/docs/assets/$3"$4>')
    .replace(/!\[([^\]]*)\]\((docs|\.\/docs|\.)\/assets\/([^)]+)\)/g, '![$1](/docs/assets/$3)')
}

// 生成 README（使用根目录的 README.md）
const generateReadme = async () => {
  const rootReadmePath = join(rootDir, '..', 'README.md')
  const stats = await getStat(rootReadmePath)
  if (!stats) {
    throw new Error('根目录 README.md 不存在')
  }
  const content = await readFile(rootReadmePath, 'utf-8')
  return transformReadmeLinks(content)
}

// 主函数
const main = async () => {
  console.log('开始同步文档到 public/docs 目录...\n')
  await ensureDir(docsDir)
  console.log('清理旧文件...')
  await cleanDocsDir()
  
  // 同步 assets
  const assetsSourceDir = join(sourceDocsDir, 'assets')
  if (await isDir(assetsSourceDir)) {
    console.log('\n同步 assets 资源...')
    await syncDirectory(assetsSourceDir, join(docsDir, 'assets'))
  }
  
  // 同步文档
  for (const source of docSources) {
    if (!(await isDir(source.path))) {
      console.log(`⚠ 跳过: ${source.name} (不是目录)`)
      continue
    }
    console.log(`\n同步 ${source.name} 文档...`)
    await syncDirectory(source.path, join(docsDir, source.name))
  }
  
  // 生成侧边栏和 README
  console.log('\n生成侧边栏...')
  await writeFile(join(docsDir, '_sidebar.md'), await generateSidebar(), 'utf-8')
  console.log('✓ 已生成侧边栏')
  
  console.log('生成 README...')
  await writeFile(join(docsDir, 'README.md'), await generateReadme(), 'utf-8')
  console.log('✓ 已生成 README')
  
  // 生成时间戳文件，用于强制刷新搜索索引
  const timestamp = Date.now()
  await writeFile(join(docsDir, '.sync-timestamp'), String(timestamp), 'utf-8')
  
  console.log('\n✓ 文档同步完成!')
}

main().catch(console.error)
