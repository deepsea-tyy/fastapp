<script setup lang="ts">
import sysCopyText from '$/ds/sysConfig/components/sysCopyText.vue'
import emptyImage from '$/ds/sysConfig/assets/empty.svg'
import SettingForm from '$/ds/sysConfig/components/configDetailsForm.vue'
import Create from '$/ds/sysConfig/components/create.vue'
import type { ConfigGroupListVo, ConfigVo } from '$/ds/sysConfig/api/configGroup.ts'
import { batchUpdate, details } from '$/ds/sysConfig/api/config.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import {formatLang} from "../../../../utils/common.ts";
import {useI18n} from 'vue-i18n'

const {t} = useI18n()

const { data = null } = defineProps<{
  data?: ConfigGroupListVo
}>()

const model = ref<ConfigVo[]>([])
const settingFormRef = ref()
// 获取配信详情
async function getDetail() {
  const res = await details(data!.code!)
  if (res.code === ResultCode.SUCCESS) {
    model.value = Array.isArray(res.data) ? res.data : [res.data]
  }
}

onMounted(() => {
  getDetail()
})

async function handleCreateSuccess() {
  await getDetail()
}

async function onDelete() {
  await getDetail()
}

// 更新操作
function edit(): Promise<any> {
  return new Promise((resolve, reject) => {
    batchUpdate(model.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {

    })
  })
}

defineExpose({
  settingFormRef,
  model,
  edit,
})
</script>

<template>
  <div class="relative w-full overflow-hidden p-6">
    <div class="relative overflow-hidden rounded">
      <el-descriptions
        class="relative w-full overflow-hidden"
        border
        :title="t('systemMenu.labels.basicInfo')"
        :column="1"
      >
        <el-descriptions-item :label="t('systemMenu.labels.appName')" label-align="right">
          {{ formatLang(data?.name) }}
        </el-descriptions-item>
        <el-descriptions-item :label="t('systemMenu.labels.appIdentifier')" label-align="right">
          <sysCopyText copyable>
            {{ data?.code }}
          </sysCopyText>
        </el-descriptions-item>
        <el-descriptions-item :label="t('systemMenu.labels.creationTime')" label-align="right">
          {{ data?.created_at }}
        </el-descriptions-item>
      </el-descriptions>
    </div>
    <div v-if="model.length > 0" class="relative mt-10 overflow-hidden rounded">
      <el-descriptions
        class="relative w-full overflow-hidden"
        border
        :title="t('systemMenu.labels.configInfo')"
        :column="1"
      >
        <template #extra>
          <Create type="primary" :data="data" @create-success="handleCreateSuccess" />
        </template>
      </el-descriptions>
      <SettingForm ref="settingFormRef" v-model="model" @on-delete="onDelete" />
    </div>
    <div v-else class="text-align-center">
      <el-empty :image="emptyImage" />
      <Create type="primary" size="large" :data="data" @create-success="handleCreateSuccess" />
    </div>
  </div>
</template>

<style scoped lang="scss">
:deep(.el-descriptions__body .el-descriptions__table.is-bordered .el-descriptions__cell){
  border: none;
  word-break: break-all;
  overflow-wrap: break-word;

}
:deep(.el-descriptions__label.el-descriptions__cell.is-bordered-label){
  background: transparent;
  vertical-align: top;
}
:deep(.el-descriptions__label){
  width: 120px;
}
</style>
