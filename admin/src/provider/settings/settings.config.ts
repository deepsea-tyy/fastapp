
import type { SystemSettings } from '#/global'

// eslint-disable-next-line ts/ban-ts-comment
// @ts-expect-error
const globalConfigSettings: SystemSettings.all = {
  app: {
    // 是否开启水印，默认为 false
    enableWatermark: true,
    // 水印文字，可以是字符串或字符串数组（多行显示）
    watermarkText: 'fastapp', // 单行：'fastapp'
    // watermarkText: ['fastapp', '内部系统'], // 多行：使用数组
  },
}

export default globalConfigSettings
