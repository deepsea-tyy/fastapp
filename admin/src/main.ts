
import App from './App.vue'
import MineBootstrap from './bootstrap'

const app = createApp(App)

MineBootstrap(app).then(() => {
  app.mount('#app')
}).catch((err) => {
  console.error('start fail', err)
})
