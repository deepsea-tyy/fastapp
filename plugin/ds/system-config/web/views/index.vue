<script setup lang="ts">
import sysPageBar from '$/ds/system-config/components/sysPageBar.vue'
import sysCopyText from '$/ds/system-config/components/sysCopyText.vue'
import emptyImage from '$/ds/system-config/assets/empty.svg'
import detail from './configDetails.vue'
import type { ConfigGroupListVo } from '$/ds/system-config/api/configGroup.ts'
import { deleteByIds, page } from '$/ds/system-config/api/configGroup.ts'
import type { TransType } from '@/hooks/auto-imports/useTrans.ts'
import type { UseDialogExpose } from '@/hooks/useDialog.ts'
import type { UseDrawerExpose } from '@/hooks/useDrawer.ts'

import useDialog from '@/hooks/useDialog.ts'
import useDrawer from '@/hooks/useDrawer.ts'
import { useMessage } from '@/hooks/useMessage.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import ConfigForm from '$/ds/system-config/views/groupForm.vue'
import Create from '$/ds/system-config/components/create.vue'
import {formatLang} from "../../../../utils/common.ts";

const formRef = ref()
const drawerRef = ref()
const defaultList: Ref<ConfigGroupListVo[]> = ref([])
const i18n = useTrans() as TransType
const t = i18n.globalTrans
const msg = useMessage()

// 弹窗配置
const maDialog: UseDialogExpose = useDialog({
  alignCenter: true,
  width: '40%',
  // 保存数据
  ok: ({ formType }, okLoadingState: (state: boolean) => void) => {
    console.log(formType)
    okLoadingState(true)
    if (['add', 'edit'].includes(formType)) {
      const elForm = formRef.value.maForm.getElFormRef()
      // 验证通过后
      elForm.validate().then(() => {
        switch (formType) {
          // 新增
          case 'add':
            formRef.value.add().then(async (res: any) => {
              res.code === ResultCode.SUCCESS ? msg.success(t('crud.createSuccess')) : msg.error(res.message)
              await getList()
              maDialog.close()
            }).catch((err: any) => {
              msg.alertError(err.message)
            })
            break
          // 修改
          case 'edit':
            formRef.value.edit().then(async (res: any) => {
              res.code === 200 ? msg.success(t('crud.updateSuccess')) : msg.error(res.message)
              await getList()
              maDialog.close()
            }).catch((err: any) => {
              msg.alertError(err.message)
            })
            break
        }
      }).catch()
    }
    okLoadingState(false)
  },
})

// 定义按钮配置数组
const buttons = [
  {
    text: t('systemMenu.systemConfig.addGroup'),
    type: 'primary', // 按钮类型
    show: true, // 是否显示
    action: () => {
      maDialog.setTitle(t('systemMenu.systemConfig.addConfig'))
      maDialog.open({ formType: 'add' })
    },
  },
]

// 抽屉配置
const maDrawer: UseDrawerExpose = useDrawer({

  ok: () => {
    const elForm = drawerRef.value.settingFormRef?.maForm.getElFormRef()
    if (!elForm) {
      maDrawer.close()
      return
    }
    // 验证通过后
    elForm.validate().then(() => {
      drawerRef.value.edit().then(async (res: any) => {
        res.code === 200 ? msg.success(t('crud.updateSuccess')) : msg.error(res.message)
        await getList()
        maDrawer.close()
      }).catch((err: any) => {
        msg.alertError(err.message)
      })
    })
  },
  cancel: () => {
    // 关闭抽屉
    getList()
    maDrawer.close()
  },
})

// 获取list数据
async function getList() {
  const res = await page({})
  if (res.code === ResultCode.SUCCESS) {
    defaultList.value = res.data
  }
}

// 生命周期函数
onMounted(async () => {
  await getList()
})

function handleCreateSuccess() {
  getList()
}

// 删除事件
function handleDelete(item: ConfigGroupListVo) {
  msg.confirm(t('systemMenu.confirmationMessages.deleteDataSource')).then(() => {
    deleteByIds([item.id as number]).then((res: any) => {
      res.code === ResultCode.SUCCESS ? msg.success(t('crud.deleteDataSource')) : msg.error(res.message)
      getList()
    })
  })
}
</script>

<template>
  <div class="mine-layout mt-3">
    <!-- 使用牛马页面bar组件 -->
    <sysPageBar
      :title="t('systemMenu.systemConfig.name')"
      :description="t('systemMenu.systemConfig.description')"
      :show-buttons="true"
      :buttons="buttons"
    />
    <div class="mine-layout p-[12px] pt-3">
      <div v-if="defaultList.length > 0" class="grid grid-cols-1 w-full gap-[10px] lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2">
        <!-- 内容 -->
        <div
          v-for="(item, key) in defaultList"
          :key="key"
          class="oc-disturb-card crontab_box crontab_box h-200px rounded-md p-4"
        >
          <div class="flex items-center text-base font-medium leading-5">
            <div class="flex-1 overflow-hidden text-ellipsis whitespace-nowrap">
              {{ formatLang(item.name) }}
            </div>
          </div>
          <div class="mt-2 flex items-center text-xs text-[#515461] font-normal leading-5">
            <ma-svg-icon class="mr-[4px]" :name="item.icon ?? ''" :size="15" />
            <span class="mx-[8px]">|</span>
            <span class="overflow-hidden truncate text-ellipsis">{{ item.remark }}</span>
          </div>
          <div class="mt-4 h-[90px] flex-1 text-sm text-[#55585c] leading-5">
            <template v-if="item.info && item.info.length > 0">
              <div v-for="(items, key) in item.info.slice(0, 3)" :key="key" class="overflow-hidden text-ellipsis whitespace-nowrap">
                <el-tooltip :content="items.key" effect="light">
                  <span class="mr-2 text-[#85878a]">{{ formatLang(items.name) }}</span>
                </el-tooltip>
                <sysCopyText copyable>
                  {{ items.value }}
                </sysCopyText>
              </div>
            </template>
            <template v-else>
              <div class="flex flex-col items-center justify-center gap-[12px]">
                <Create type="primary" form-type="add" :data="item" @create-success="handleCreateSuccess" />
              </div>
            </template>
          </div>
          <div class="flex items-center justify-between">
            <el-button
              class="h-0 font-normal !p-0"
              type="primary"
              text
              @click="() => {
                maDrawer.setTitle(formatLang(item.name))
                maDrawer.open({ formType: 'add', data: item })
              }"
            >
              {{ t('systemMenu.systemConfig.viewDetails') }}
            </el-button>
            <el-dropdown>
              <el-button text class="h-0 font-normal">
                <ma-svg-icon name="i-si:more-square-horiz-fill" />
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item
                    @click="() => {
                      maDialog.setTitle(t('systemMenu.systemConfig.editConfig'))
                      maDialog.open({ formType: 'edit', data: item })
                    }"
                  >
                    {{ t('systemMenu.systemConfig.editConfig') }}
                  </el-dropdown-item>
                  <el-dropdown-item divided @click="handleDelete(item)">
                    {{ t('systemMenu.systemConfig.deleteContent') }}
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </div>
      <div v-else class="h-50vh flex flex-col items-center justify-center gap-[12px]">
        <el-empty :image="emptyImage" />
        <el-button
          type="primary"
          @click="() => {
            maDialog.setTitle(t('systemMenu.systemConfig.addConfig'))
            maDialog.open({ formType: 'add' })
          }"
        >
          {{ t('systemMenu.systemConfig.addGroup') }}
        </el-button>
      </div>
    </div>
    <component :is="maDialog.Dialog">
      <template #default="{ formType, data }">
        <ConfigForm ref="formRef" :form-type="formType" :data="data" />
      </template>
    </component>
    <component :is="maDrawer.Drawer">
      <template #default="{ data }">
        <detail ref="drawerRef" :data="data" />
      </template>
    </component>
  </div>
</template>

<style scoped lang="scss">
.crontab_box{
  background-color: white;
  background-image: url("$/ds/system-config/assets/bg.png");
  background-repeat: no-repeat;
  background-position: 100% 0;
}

.dark .crontab_box{
  --un-bg-opacity: 1;
  background-color: rgb(24 24 24 / var(--un-bg-opacity));
}
</style>
