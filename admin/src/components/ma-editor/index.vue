<script setup lang="ts">
import {reactive, ref, watch, computed} from 'vue'
import useSettingStore from '@/store/modules/useSettingStore'
import {uploadLocal} from '@/utils/uploadLocal'
import type {TransType} from '@/hooks/auto-imports/useTrans.ts'

import Editor from '@tinymce/tinymce-vue'
import tinymce from 'tinymce/tinymce'

Window.tinymce = tinymce // 全局声明（关键步骤）

// 导入核心组件
import 'tinymce/models/dom'
import 'tinymce/themes/silver'
import 'tinymce/icons/default'

import pluginList from './tinymce/pluginList.ts'
import {formatImagePath} from "@/utils/common.ts";

defineOptions({name: 'MaEditor'})
const settingStore = useSettingStore()


const i18n = useTrans() as TransType
const t = i18n.globalTrans

const props = defineProps({
  menubar: {type: Boolean, default: true},
  modelValue: {type: String},
  height: {type: Number, default: 400},
  min_height: {type: Number, default: 400},
  width: {type: String, default: '100%'},
  id: {type: String, default: () => 'tinymce' + new Date().getTime().toString()},
  toolbar: {
    type: [String, Array],
    default: "code undo redo restoredraft | paste pastetext | alignleft aligncenter alignright alignjustify outdent indent formatpainter | \
    fullscreen preview | forecolor backcolor bold italic underline strikethrough link codesample | blockquote subscript superscript removeformat | \
    table tablecellborderstyle | styles codeformat fontfamily fontsize | bullist numlist | charmap pagebreak insertdatetime | image resource"
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const content = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  },
});

const resourceVisible = ref(false)
const appBaseUrl = import.meta.env.VITE_APP_ROOT_BASE

const userStore = useUserStore()
const lang = userStore.getLanguage()

const initConfig = reactive({
  license_key: import.meta.env.VITE_TINYMCE_KEY || 'gpl',
  menubar: props.menubar, // 菜单栏显隐
  language_url: `${appBaseUrl}tinymce/langs/${lang}.js`,
  language: lang,
  skin_url: appBaseUrl + (settingStore.colorMode === 'dark' ? 'tinymce/skins/ui/tinymce-5-dark' : 'tinymce/skins/ui/tinymce-5'),
  height: props.height,
  min_height: props.min_height,
  width: props.width,
  toolbar_mode: 'wrap',
  plugins: pluginList,
  toolbar: props.toolbar,
  branding: false,
  // content_css: appBaseUrl + (settingStore.colorMode === 'dark' ? 'tinymce/skins/content/tinymce-5-dark' : 'tinymce/skins/content/tinymce-5'),
  content_css: `${appBaseUrl}tinymce/skins/content/default/content.css`,
  font_size_formats: '12px 14px 16px 18px 20px 22px 24px 26px 28px 30px 32px 34px 36px 38px 40px',
  font_size_input_default_unit: 'px',
  content_style: `body { font-family: Microsoft YaHei; } .tox-tinymce { isolation: isolate }`,
  placeholder: t('form.pleaseInput', {'msg': t('common.content')}),
  images_upload_handler: async (blobInfo: any, success: Function) => {
    try {
      const formData = new FormData()
      formData.append('file', blobInfo.blob())
      const result = await uploadLocal({file: blobInfo.blob()})

      if (!result || result.code !== 200) throw new Error('上传错误')

      const url = formatImagePath(result.data?.url)
      success(url)
      return url
    } catch (error) {
      console.error('上传图片失败', error)
      throw error
    }
  },
  setup: (editor: any) => {
    editor.on('init', () => {
      editor.getBody().style.fontSize = '14px';
    })
    editor.ui.registry.addButton('resource', {
      text: t('common.resourcePicker'),
      icon: 'folder',
      onAction: () => resourceVisible.value = true
    })
  }
})

const editorKey = ref(new Date().getTime())

function handleResourceConfirm(resources: any[]) {
  if (!resources || resources.length === 0) return

  let mediaContent = ''
  resources.forEach(resource => {
    const url = formatImagePath(resource.url || resource)
    if (typeof url === 'string') {
      // 图片文件
      if (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.bmp') ||
          url.endsWith('.jpeg') || url.endsWith('.svg') || url.endsWith('.gif')) {
        mediaContent += `<img src="${url}" width="100%" alt=""/>`
      }
      // 视频文件
      else if (url.endsWith('.mp4') || url.endsWith('.webm') || url.endsWith('.ogg') ||
               url.endsWith('.avi') || url.endsWith('.mov') || url.endsWith('.wmv')) {
        mediaContent += `<video src="${url}" width="100%" controls>
        </video>`
      }
    }
  })

  content.value = content.value ? content.value + mediaContent : mediaContent
}

watch(
    () => content.value,
    val => emit('change', val)
)
</script>
<template>
  <div style="width: 100%;">
    <Editor :key="editorKey" v-model="content" :init="initConfig" :id="props.id"></Editor>
    <MaResourcePicker v-model:visible="resourceVisible" :multiple="true" @confirm="handleResourceConfirm"/>
  </div>
</template>

<!-- css 隔离 -->
<style>
/* 提升所有下拉菜单层级 */
.tox-tinymce-aux {
  z-index: 9999 !important;
}

/* 隐藏 upgrade 按钮 */
.tox-promotion {
  width: 0 !important;
  padding: 0 !important;
  margin: 0 !important;
  border: 0 !important;
}
</style>
