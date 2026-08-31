
<script setup lang="ts">
import type { Dictionary } from '#/global'
import { useI18n } from 'vue-i18n'
import { isFunction } from 'radash'

defineOptions({ name: 'MaDictRadio' })

const {
  dictName = '',
  data = [],
  renderMode = 'normal',
  transScope = 'global',
} = defineProps<{
  // 字典名称
  dictName?: string
  // 字典数据
  data?: Dictionary[] | (() => Dictionary[])
  // 渲染模式：`normal: el-radio` | `button: el-radio-button`
  renderMode?: 'normal' | 'button'
  // 翻译范围
  transScope?: 'global' | 'local'
}>()
const dictStore = useDictStore()
const dictionaryData = computed<Dictionary[] | null>(() => {
  return dictName === '' ? (isFunction(data) ? data() : data) : dictStore.find(dictName)
})

const { t } = useI18n()

const modelValue = defineModel<any>()

// 类型转换：确保值与字典值类型一致（el-radio-group 使用严格相等比较）
const model = computed({
  get: () => {
    const value = modelValue.value
    if (value == null || !dictionaryData.value?.length) return value

    const dictValueType = typeof dictionaryData.value[0].value
    const valueType = typeof value

    // 类型一致则直接返回
    if (dictValueType === valueType) return value

    // 字典值为数字，转换 modelValue 为数字
    if (dictValueType === 'number') {
      const num = Number(value)
      return isNaN(num) ? value : num
    }

    // 字典值为字符串，转换 modelValue 为字符串
    if (dictValueType === 'string') return String(value)

    return value
  },
  set: (val) => {
    modelValue.value = val
  },
})
</script>

<template>
  <el-radio-group v-model="model" v-bind="$attrs">
    <slot name="default">
      <template v-if="dictionaryData">
        <component
          v-for="item in dictionaryData"
          :key="item.value"
          :is="renderMode === 'normal' ? 'el-radio' : 'el-radio-button'"
          :value="item.value"
          :disabled="item.disabled"
        >
          <slot name="optionDefault">
            {{ item?.i18n ? t(item.i18n) : item.label }}
          </slot>
        </component>
      </template>
    </slot>
  </el-radio-group>
</template>

<style scoped lang="scss">

</style>
