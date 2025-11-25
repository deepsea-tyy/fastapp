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

// 常量
const ALLOWED_EXTENSIONS = ['.md', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp']
const IMAGE_EXTENSIONS = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp']

// 要同步的文档目录
const docSources = [
  { name: 'server', path: join(sourceDocsDir, 'server'), label: '后端服务' },
  { name: 'app', path: join(sourceDocsDir, 'app'), label: '移动端' },
  { name: 'web', path: join(sourceDocsDir, 'web'), label: '前端' },
  { name: 'website', path: join(sourceDocsDir, 'website'), label: '企业官网' }
]

// 工具函数
const ensureDir = async (dir) => {
  try {
    await mkdir(dir, { recursive: true })
  } catch {
    // 目录已存在，忽略错误
  }
}

const isDirectory = async (path) => {
  try {
    const stats = await stat(path)
    return stats.isDirectory()
  } catch {
    return false
  }
}

// 转换 Markdown 中的图片路径为绝对路径
const transformImagePaths = (content) => {
  return content.replace(
    /src="(\.\.\/|\.\/|)assets\/([^"]+)"/g,
    'src="/docs/assets/$2"'
  ).replace(
    /src="\/assets\/([^"]+)"/g,
    'src="/docs/assets/$1"'
  )
}

// 清理目标目录（保留 index.html）
const cleanDocsDir = async () => {
  try {
    const entries = await readdir(docsDir, { withFileTypes: true })
    await Promise.all(
      entries
        .filter(entry => entry.name !== 'index.html')
        .map(async (entry) => {
          const entryPath = join(docsDir, entry.name)
          await rm(entryPath, { recursive: true, force: true })
          console.log(`✓ 已清理: ${entry.name}${entry.isDirectory() ? '/' : ''}`)
        })
    )
  } catch {
    // 目录不存在或为空，忽略错误
  }
}

// 复制文件内容（处理 Markdown 图片路径转换）
const copyFileContent = async (src, dest) => {
  try {
    let content = await readFile(src, 'utf-8')
    
    // Markdown 文件转换图片路径
    if (extname(src).toLowerCase() === '.md') {
      content = transformImagePaths(content)
    }
    
    await ensureDir(dirname(dest))
    await writeFile(dest, content, 'utf-8')
    return true
  } catch (error) {
    console.error(`✗ 复制失败: ${relative(sourceDocsDir, src)} - ${error.message}`)
    return false
  }
}

// 同步目录
const syncDirectory = async (sourceDir, targetDir) => {
  try {
    const entries = await readdir(sourceDir, { withFileTypes: true })
    
    for (const entry of entries) {
      const srcPath = join(sourceDir, entry.name)
      const relativePath = relative(sourceDir, srcPath)
      const destPath = join(targetDir, relativePath)
      
      if (entry.isDirectory()) {
        await syncDirectory(srcPath, destPath)
      } else if (entry.isFile()) {
        const ext = extname(entry.name).toLowerCase()
        if (ALLOWED_EXTENSIONS.includes(ext)) {
          await copyFileContent(srcPath, destPath)
          console.log(`✓ 已同步: ${relativePath}`)
        }
      }
    }
  } catch (error) {
    console.error(`✗ 同步失败: ${relative(sourceDocsDir, sourceDir)} - ${error.message}`)
  }
}

// 扫描目录获取所有 Markdown 文件
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

// 生成侧边栏
const generateSidebar = async () => {
  const sidebar = []
  
  for (const source of docSources) {
    try {
      if (!(await isDirectory(source.path))) continue
      
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
      
      // 输出分组
      for (const [dir, fileList] of Object.entries(grouped)) {
        if (dir !== 'root') {
          sidebar.push(`  * ${dir.split('/').pop()}`)
        }
        const indent = dir === 'root' ? '  ' : '    '
        fileList
          .sort((a, b) => a.name.localeCompare(b.name))
          .forEach(file => {
            sidebar.push(`${indent}* [${file.name}](${source.name}/${file.path}.md)`)
          })
      }
    } catch (error) {
      console.error(`✗ 无法访问 ${source.name}: ${error.message}`)
    }
  }
  
  return sidebar.join('\n')
}

// 生成 README
const generateReadme = () => `# FastApp 文档

欢迎使用 FastApp 开发文档！

## 📚 文档分类

${docSources.map(s => `- [${s.label}文档](./${s.name}/README.md)`).join('\n')}

## 🚀 快速开始

选择您需要的文档分类开始阅读。

## 📖 使用说明

- 使用左侧导航栏浏览文档
- 使用顶部搜索框搜索文档内容
- 文档支持代码高亮和 Markdown 语法
`

// 主函数
const main = async () => {
  console.log('开始同步文档到 public/docs 目录...\n')
  
  await ensureDir(docsDir)
  console.log('清理旧文件...')
  await cleanDocsDir()
  
  // 同步 assets 目录
  const assetsSourceDir = join(sourceDocsDir, 'assets')
  if (await isDirectory(assetsSourceDir)) {
    console.log('\n同步 assets 资源...')
    await syncDirectory(assetsSourceDir, join(docsDir, 'assets'))
  }
  
  // 同步文档文件
  await Promise.all(
    docSources.map(async (source) => {
      if (!(await isDirectory(source.path))) {
        console.log(`⚠ 跳过: ${source.name} (不是目录)`)
        return
      }
      console.log(`\n同步 ${source.name} 文档...`)
      await syncDirectory(source.path, join(docsDir, source.name))
    })
  )
  
  // 生成侧边栏和 README
  console.log('\n生成侧边栏...')
  await writeFile(join(docsDir, '_sidebar.md'), await generateSidebar(), 'utf-8')
  console.log('✓ 已生成侧边栏')
  
  console.log('生成 README...')
  await writeFile(join(docsDir, 'README.md'), generateReadme(), 'utf-8')
  console.log('✓ 已生成 README')
  
  console.log('\n✓ 文档同步完成!')
}

main().catch(console.error)


