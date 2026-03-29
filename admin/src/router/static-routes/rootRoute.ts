
import type { RouteRecordRaw } from 'vue-router'
import ucChildren from './ucChildren'

const rootRoutes: RouteRecordRaw[] = [
  {
    name: 'MineRootLayoutRoute',
    path: '/',
    component: () => import('@/layouts'),
  },
  {
    name: 'uc',
    path: '/uc',
    component: () => import('@/layouts/uc.tsx'),
    redirect: '/uc/index',
    children: ucChildren,
  },
  {
    name: 'login',
    path: '/login',
    component: () => import(('~/base/views/login/index.vue')),
    meta: {
      title: '登录',
      i18n: 'menu.login',
    },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'MineSystemError',
    component: () => import(('@/layouts/[...all].tsx')),
    meta: {
      hidden: true,
      i18n: 'menu.pageError',
    },
  },
]

export default rootRoutes
