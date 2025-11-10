
import type { RouteRecordRaw } from 'vue-router'

const welcomeRoute: RouteRecordRaw = {
  name: 'welcome',
  path: '/welcome',
  meta: {
    title: '欢迎页',
    i18n: 'menu.welcome',
    icon: 'icon-park-outline:jewelry',
  },
  component: () => import('~/base/views/welcome/index.vue'),
}

export default welcomeRoute
