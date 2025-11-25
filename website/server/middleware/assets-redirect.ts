export default defineEventHandler((event) => {
  const url = event.node.req.url
  
  // 如果请求的是 /assets/ 路径，重定向到 /docs/assets/
  if (url && url.startsWith('/assets/') && !url.startsWith('/docs/assets/')) {
    const newUrl = url.replace('/assets/', '/docs/assets/')
    return sendRedirect(event, newUrl, 301)
  }
})

