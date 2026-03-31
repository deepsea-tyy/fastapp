<script setup lang="tsx">
import type { MaProTableExpose, MaProTableOptions, MaProTableSchema } from '@/components/ma-pro-table'
import type { Ref } from 'vue'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'

import { page, generate, deleteByIds } from '$/ds/sysCms/api/appPageContentSync.ts'
import getSearchItems from './data/getSearchItems.tsx'
import getTableColumns from './data/getTableColumns.tsx'
import { useMessage } from '@/hooks/useMessage.ts'
import { ResultCode } from '@/utils/ResultCode.ts'

defineOptions({ name: 'ds:sysCms:app_page_content_sync' })

const proTableRef = ref<MaProTableExpose>() as Ref<MaProTableExpose>
const selections = ref<any[]>([])
const i18n = useTrans() as TransType
const t = i18n.globalTrans
const msg = useMessage()

// 参数配置
const options = ref<MaProTableOptions>({
  adaptionOffsetBottom: 161,
  header: {
    mainTitle: () => t('admin.AppPageContentSync'),
  },
  tableOptions: {
    on: {
      // 表格选择事件
      onSelectionChange: (selection: any[]) => selections.value = selection,
      onSortChange: (sort: any) => {
        proTableRef.value.setRequestParams({ order_by: sort.prop, order_by_direction: sort.order === 'ascending' ? 'asc' : 'desc' }, true)
      },
    },
  },
  searchOptions: {
    fold: true,
    text: {
      searchBtn: () => t('crud.search'),
      resetBtn: () => t('crud.reset'),
      isFoldBtn: () => t('crud.searchFold'),
      notFoldBtn: () => t('crud.searchUnFold'),
    },
  },
  searchFormOptions: { labelWidth: '90px' },
  requestOptions: {
    api: page,
  },
})

// 架构配置
const schema = ref<MaProTableSchema>({
  searchItems: getSearchItems(t),
  tableColumns: getTableColumns(t, proTableRef),
})

// 生成文件
async function handleGenerate() {
  try {
    const response = await generate()
    if (response.code === ResultCode.SUCCESS) {
      msg.success('文件生成成功')
      proTableRef.value.refresh()
    } else {
      msg.error(response.message || '文件生成失败')
    }
  } catch (error: any) {
    msg.alertError(error)
  }
}

// 批量删除
function handleDelete() {
  const ids = selections.value.map((item: any) => item.id)
  msg.confirm(t('crud.delMessage')).then(async () => {
    const response = await deleteByIds(ids)
    if (response.code === ResultCode.SUCCESS) {
      msg.success(t('crud.delSuccess'))
      proTableRef.value.refresh()
    }
  })
}
</script>

<template>
  <div class="mine-layout pt-3">
    <MaProTable ref="proTableRef" :options="options" :schema="schema">
      <template #actions>
        <el-button
          v-auth="['ds:sysCms:app_page_content_sync:generate']"
          type="primary"
          @click="handleGenerate"
        >
          {{ t('admin.AppPageContentSyncFields.generate') }}
        </el-button>
      </template>

      <template #toolbarLeft>
        <el-button
          v-auth="['ds:sysCms:app_page_content_sync:delete']"
          type="danger"
          plain
          :disabled="selections.length < 1"
          @click="handleDelete"
        >
          {{ t('crud.delete') }}
        </el-button>
      </template>
    </MaProTable>
  </div>
</template>

<style scoped lang="scss">
</style>

