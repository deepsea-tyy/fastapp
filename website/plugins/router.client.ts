export default defineNuxtPlugin(() => {
  // 确保客户端路由正常工作
  if (process.client) {
    const router = useRouter()
    
    // 监听路由错误
    router.onError((error) => {
      console.error('Router error:', error)
    })
  }
})

