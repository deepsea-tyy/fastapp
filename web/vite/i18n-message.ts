
import VueI18nPlugin from '@intlify/unplugin-vue-i18n/vite'

export default function createI18nMessage() {
  return VueI18nPlugin({
    include: [
      './src/locales/**',
      './src/modules/**/locales/**',
      './src/plugins/*/**/locales/**',
    ],
  })
}
