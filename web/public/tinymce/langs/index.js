// utils/langs/index.js
export function loadLang(lang) {
  // 使用相对路径动态导入对应语言文件
  return import(`../langs/${lang}.js`) // 使用相对路径和语言代码
    .catch(() => {
      // 如果加载失败，默认加载中文（zh_CN）
      return import('./zh_CN.js')
    })
}
