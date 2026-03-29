

export default [
  {
    name: 'uc:index',
    path: '/uc/index',
    component: () => import(('~/base/views/uc/index.vue')),
    meta: {
      title: '首页',
      icon: 'heroicons:user-circle',
      i18n: 'menu.uc:index',
    },
  },
  {
    name: 'uc:google2fa',
    path: '/uc/google2fa',
    component: () => import(('~/base/views/uc/google2fa.vue')),
    meta: {
      title: 'Google 2FA 设置',
      icon: 'heroicons:shield-check',
      i18n: 'menu.uc:google2fa',
    },
  },
]
