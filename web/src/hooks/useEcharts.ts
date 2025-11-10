import useEcharts from '@/components/ma-echarts'
import { useColorMode } from '@vueuse/core'

const colorMode = useColorMode()

function themeMode() {
  return colorMode.value === 'dark' ? 'mineDark' : 'default'
}

export {
  themeMode,
  useEcharts,
}
