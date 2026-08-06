import App from './App.vue'
import MineBootstrap from './bootstrap'
//离线图标使用
/*import {downloadAndInstall, icons} from '@/iconify'

for (const item of icons) {
    try {
        await downloadAndInstall(item.prefix)
    } catch {
        console.log(`Icon collection '${item.prefix}' offline data not found, will load from network`)
    }
}*/

const app = createApp(App)

MineBootstrap(app).then(() => {
    app.mount('#app')
}).catch((err) => {
    console.error('start fail', err)
})
