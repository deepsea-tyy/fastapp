

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
]
