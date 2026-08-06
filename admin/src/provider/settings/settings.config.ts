import type { SystemSettings } from '#/global'

/**
 * 项目默认配置（修改此文件即可调整后台 UI 默认值）
 * 重新构建或刷新后生效；设置弹框内的修改仅当前会话有效，不写入 localStorage
 */
const globalConfigSettings: SystemSettings.all = {
  // 应用全局
  app: {
    // 颜色模式：light 浅色 | dark 深色
    colorMode: 'light',
    // 默认语言包：zh_CN | zh_TW | en 等
    useLocale: 'zh_CN',
    // 免登录校验的路由 name 列表
    whiteRoute: ['login'],
    // 页面切换动画：ma-fade | ma-slide-right | ma-slide-left | ma-slide-down | ma-slide-up
    pageAnimate: 'ma-slide-right',
    // 是否开启全屏水印
    enableWatermark: true,
    // 主题色（十六进制）
    primaryColor: '#3790ff',
    // 是否显示工具栏区域（工具栏 + 标签栏）
    showBars: true,
    // 水印文字，字符串或字符串数组（多行）
    watermarkText: '',
  },

  // 欢迎页（默认首页标签）
  welcomePage: {
    // 路由 name，需与路由表一致
    name: 'menu:index',
    // 路由 path
    path: '/index',
    // 显示标题
    title: '创作中枢',
    // 菜单/标签图标（iconify 名称）
    icon: 'icon-park-outline:jewelry',
  },

  // 子侧栏（经典/混合布局菜单栏）
  subAside: {
    // 是否显示菜单图标
    showIcon: true,
    // 是否显示菜单标题
    showTitle: true,
    // 是否固定子侧栏（不随 hover 收起）
    fixedAsideState: false,
    // 是否显示折叠按钮
    showCollapseButton: true,
  },

  // 顶部标签栏
  tabbar: {
    // 是否显示标签栏
    enable: false,
    // 标签样式：rectangle 默认 | card 卡片
    mode: 'rectangle',
  },

  // 顶部工具栏：顺序即显示顺序
  toolBars: [
    // search 搜索
    { name: 'search', show: false },
    // notification 通知
    { name: 'notification', show: false },
    // translate 语言切换
    { name: 'translate', show: true },
    // fullscreen 全屏
    { name: 'fullscreen', show: true },
    // switchMode 颜色模式快捷切换
    { name: 'switchMode', show: true },
  ],

  // 底部版权
  copyright: {
    // 是否显示底部版权（路由 meta 可单独覆盖）
    enable: true,
    // 网站运行起始年份或区间
    dates: useDayjs().format('YYYY'),
    // 公司名称
    company: import.meta.env.VITE_APP_TITLE,
    // 官网链接
    website: '',
    // 备案号
    putOnRecord: 'ICP备xxx',
  },
}

export default globalConfigSettings
