
<script setup lang="tsx">
import type { MaProTableExpose, MaProTableOptions, MaProTableSchema } from '@/components/ma-pro-table'
import type { Ref } from 'vue'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import { deleteByIds, page } from '$/ds/kefu/api/kefuConversation.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import useDrawer from '@/hooks/useDrawer.ts'
import getSearchItems from './data/getSearchItems.tsx'
import getTableColumns from './data/getTableColumns.tsx'
import Detail from './components/detail.vue'


defineOptions({ name: 'kefu:kefuConversation' })

const proTableRef = ref<MaProTableExpose>() as Ref<MaProTableExpose>
const formRef = ref()
const setFormRef = ref()
const selections = ref<any[]>([])
const i18n = useTrans() as TransType
const t = i18n.globalTrans
const msg = useMessage()
const detail = ref()

const drawerDetail: UseDrawerExpose = useDrawer({
  size: '80%',
  closeOnClickModal: true
})

// 参数配置
const options = ref<MaProTableOptions>({
  // 表格距离底部的像素偏移适配
  adaptionOffsetBottom: 161,
  header: {
    mainTitle: () => t('kefu.KefuConversation'),
    subTitle: '',
  },
  // 表格参数
  tableOptions: {
    on: {
      // 表格选择事件
      onSelectionChange: (selection: any[]) => selections.value = selection,
    },
  },
  // 搜索参数
  searchOptions: {
    fold: true,
    text: {
      searchBtn: () => t('crud.search'),
      resetBtn: () => t('crud.reset'),
      isFoldBtn: () => t('crud.searchFold'),
      notFoldBtn: () => t('crud.searchUnFold'),
    },
  },
  // 搜索表单参数
  searchFormOptions: { labelWidth: '90px' },
  // 请求配置
  requestOptions: {
    api: page,
  },
})
// 架构配置
const schema = ref<MaProTableSchema>({
  // 搜索项
  searchItems: getSearchItems(t),
  // 表格列
  tableColumns: getTableColumns(drawerDetail, formRef, t),
})

// 批量删除
function handleDelete() {
  const ids = selections.value.map((item: any) => item.id)
  msg.confirm(t('crud.delMessage')).then(async () => {
    const response = await deleteByIds(ids)
    if (response.code === ResultCode.SUCCESS) {
      msg.success(t('crud.delSuccess'))
      await proTableRef.value.refresh()
    }
  })
}
</script>

<template>
  <div class="mine-layout pt-3">
    <MaProTable ref="proTableRef" :options="options" :schema="schema">

      <template #toolbarLeft>
        <el-button
          v-auth="['kefu:kefuConversation:delete']"
          type="danger"
          plain
          :disabled="selections.length < 1"
          @click="handleDelete"
        >
          {{ t('crud.delete') }}
        </el-button>
      </template>
    </MaProTable>

    <component :is="drawerDetail.Drawer">
      <template #default="{ data }">
        <Detail ref="detail" :data="data" />
      </template>
    </component>
  </div>
</template>

<style scoped lang="scss">

</style>
