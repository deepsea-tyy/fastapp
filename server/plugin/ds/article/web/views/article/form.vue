<script setup lang="ts">
import type { ArticleVo } from '$/ds/article/api/article.ts'
import { create, save } from '$/ds/article/api/article.ts'
import getFormItems from './data/getFormItems.tsx'
import type { MaFormExpose } from '@/components/ma-form'
import useForm from '@/hooks/useForm.ts'
import useFormResponsive from '@/hooks/useFormResponsive.ts'
import { ResultCode } from '@/utils/ResultCode.ts'
import { processUrl } from '@/utils/common.ts'

const { formType = 'add', data = null } = defineProps<{
  formType: 'add' | 'edit'
  data?: ArticleVo | null
}>()

const t = useTrans().globalTrans
const maFormRef = ref<MaFormExpose>()
const formModel = ref<ArticleVo>({})

useForm('maFormRef').then((form: MaFormExpose) => {
  if (formType === 'edit' && data) {
    Object.keys(data).map((key: string) => {
      formModel.value[key] = data[key]
    })
  }
  form.setItems(getFormItems(formType, t, formModel.value))
})

// 响应式布局
useFormResponsive(maFormRef, {
  xsLabelPosition: 'top',
  smLabelPosition: 'right',
  lgLabelPosition: 'right',
  lgLabelWidth: '120px',
})

/**
 * 处理多语言对象数组中的图片路径
 */
function processLangImagePath(field: any): any {
  if (!field || !Array.isArray(field)) {
    return field
  }
  
  return field.map((item: any) => {
    if (item && typeof item === 'object' && item.text) {
      return {
        ...item,
        text: processUrl(item.text)
      }
    }
    return item
  })
}

// 创建操作
function add(): Promise<any> {
  return new Promise((resolve, reject) => {
    // 处理封面图片路径
    if (formModel.value.cover) {
      formModel.value.cover = processLangImagePath(formModel.value.cover)
    }
    // 处理视频路径
    if (formModel.value.video) {
      formModel.value.video = processLangImagePath(formModel.value.video)
    }
    
    create(formModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {

    })
  })
}

// 更新操作
function edit(): Promise<any> {
  return new Promise((resolve, reject) => {
    // 处理封面图片路径
    if (formModel.value.cover) {
      formModel.value.cover = processLangImagePath(formModel.value.cover)
    }
    // 处理视频路径
    if (formModel.value.video) {
      formModel.value.video = processLangImagePath(formModel.value.video)
    }
    
    save(formModel.value.id as number, formModel.value).then((res: any) => {
      res.code === ResultCode.SUCCESS ? resolve(res) : reject(res)
    }).catch((err) => {

    })
  })
}

defineExpose({
  add,
  edit,
  maForm: maFormRef,
})
</script>

<template>
  <ma-form ref="maFormRef" v-model="formModel" />
</template>

<style scoped lang="scss">

</style>
