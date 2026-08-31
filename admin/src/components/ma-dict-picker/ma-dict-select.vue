
<script setup lang="ts">
import type { Dictionary } from '#/global'
import { useI18nGlobal } from '@/utils/i18n.ts'
import { isFunction } from 'radash'

defineOptions({ name: 'MaDictSelect' })

const {
  dictName = '',
  data = [],
  transScope = 'global',
} = defineProps<{
  // 字典名称
  dictName?: string
  // 字典数据
  data?: Dictionary[] | (() => Dictionary[])
  // 翻译范围
  transScope?: 'global' | 'local'
}>()

const dictStore = useDictStore()
const { t } = useI18nGlobal()

// 源数据
const sourceData = computed<Dictionary[] | null>(() => {
  return dictName === '' ? (isFunction(data) ? data() : data) : dictStore.find(dictName)
})

// 翻译后的选项列表（依赖 locale，语言切换时自动重新计算）
const translatedOptions = computed(() => {
  const list = sourceData.value
  if (!list) return []
  return list.map(item => {
    const label = item.i18n ? t(item.i18n) : item.label
    if (item.options) {
      return {
        ...item,
        _label: label,
        options: item.options.map(sub => ({
          ...sub,
          _label: sub.i18n ? t(sub.i18n) : sub.label,
        })),
      }
    }
    return { ...item, _label: label }
  })
})

const model = defineModel<any>()
</script>

<template>
  <el-select v-model="model" v-bind="$attrs">
    <!-- 默认插槽 -->
    <slot name="default">
      <template v-if="translatedOptions.length">
        <template v-for="item in translatedOptions" :key="item.value ?? item.label">
          <!-- 分组选项 -->
          <el-option-group
            v-if="item.options"
            :label="item._label"
            :disabled="item.disabled"
          >
            <el-option
              v-for="sub in item.options"
              :key="sub.value"
              :value="sub.value"
              :label="sub._label"
              :disabled="sub.disabled"
            >
              <!-- option 插槽 -->
              <template v-if="$slots.optionDefault">
                <slot name="optionDefault" :option="sub" />
              </template>
            </el-option>
          </el-option-group>

          <!-- 普通选项 -->
          <el-option
            v-else
            :value="item.value"
            :label="item._label"
            :disabled="item.disabled"
          >
            <!-- option 插槽 -->
            <template v-if="$slots.optionDefault">
              <slot name="optionDefault" :option="item" />
            </template>
          </el-option>
        </template>
      </template>
    </slot>

    <!-- 其他具名插槽 -->
    <template
      v-for="slot in Object.keys($slots).filter(s => s !== 'default' && s !== 'optionDefault')"
      :key="slot"
      #[slot]="slotProps"
    >
      <slot :name="slot" v-bind="slotProps" />
    </template>
  </el-select>
</template>

<style scoped lang="scss">
</style>
