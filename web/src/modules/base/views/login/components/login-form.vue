
<script setup lang="ts">
import Message from 'vue-m-message'
import { useI18n } from 'vue-i18n'
import useUserStore from '@/store/modules/useUserStore.ts'
import useSettingStore from '@/store/modules/useSettingStore.ts'
import useHttp from '@/hooks/auto-imports/useHttp.ts'
import type { ResponseStruct } from '#/global'

const { t } = useI18n()
const isProduction: boolean = import.meta.env.MODE === 'production'
const isDev = !isProduction
const userStore = useUserStore()
const settingStore = useSettingStore()
const router = useRouter()
const isFormSubmit = ref(false)
const isValidState = ref(true)

// 从环境变量读取验证码配置
const env = import.meta.env
const captchaEnable = env.VITE_LOGIN_CAPTCHA_ENABLE === 'true' || env.VITE_LOGIN_CAPTCHA_ENABLE === true
const captchaType = (env.VITE_LOGIN_CAPTCHA_TYPE || 'captcha') as 'captcha' | 'google2fa'

const codeType = ref<string>(captchaType) // captcha 或 google2fa
const captchaImage = ref('')
const form = reactive<{
  username: string
  password: string
  code: string
  google2fa: string
}>({
  username: isProduction ? '' : 'admin',
  password: isProduction ? '' : '123456',
  code: isProduction ? '' : '1234',
  google2fa: '',
})

// 获取平台验证码图片
async function getCaptcha() {

  // 添加时间戳防止缓存
  const timestamp = Date.now()
  const res: ResponseStruct<{
    code: string,
    image: string
  }> = await useHttp().get(`/admin/passport/captcha?t=${timestamp}`)
  // 清空验证码输入框
  form.code = ''
  captchaImage.value =  res.data.image
}


// 初始化时获取验证码
onMounted(() => {
  if (captchaEnable && codeType.value === 'captcha') {
    getCaptcha()
  }
})

function easyValidate(event: Event) {
  const dom = event?.target as HTMLInputElement
  if (form[dom.name] === undefined || form[dom.name] === '') {
    dom.classList.add('!ring-red-5')
    Message.error(t(`loginForm.${dom.name}Placeholder`))
    isValidState.value = false
  }
  else {
    dom.classList.remove('!ring-red-5')
    isValidState.value = true
  }
}

async function submit() {
  const currentCodeType = codeType.value
  const requiredFields = ['username', 'password']

  // 根据配置决定是否需要验证码
  if (captchaEnable) {
    if (currentCodeType === 'captcha') {
      requiredFields.push('code')
    }
    else if (currentCodeType === 'google2fa') {
      requiredFields.push('google2fa')
    }
  }

  requiredFields.forEach((key) => {
    if (form[key] === undefined || form[key] === '') {
      Message.error(t(`loginForm.${key}Placeholder`))
      isValidState.value = false
    }
  })
  if (!isValidState.value) {
    return false
  }

  isFormSubmit.value = true
  const submitData: any = {
    username: form.username,
    password: form.password,
  }

  // 根据配置决定是否添加验证码
  if (captchaEnable && currentCodeType) {
    submitData.type = currentCodeType
    if (currentCodeType === 'captcha') {
      submitData.code = form.code
    } else if (currentCodeType === 'google2fa') {
      submitData.google2fa = form.google2fa
    }
  }

  userStore.login(submitData).then(async (userData: any) => {
    const welcomePath = settingStore.getSettings('welcomePage').path ?? null
    const redirect = router.currentRoute.value.query?.redirect ?? undefined
    if (userData) {
      await router.push({ path: redirect ?? welcomePath ?? '/' })
    }
    isFormSubmit.value = false
    // 登录成功后刷新验证码
    if (captchaEnable && codeType.value === 'captcha') {
      getCaptcha()
    }
  }).catch(() => {
    isFormSubmit.value = false
    // 登录失败后刷新验证码
    if (captchaEnable && codeType.value === 'captcha') {
      getCaptcha()
    }
  })
}
</script>

<template>
  <form class="mine-login-form" @submit.prevent="submit">
    <div class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.usernameLabel') }}
      </div>
      <m-input
        v-model="form.username"
        class="!bg-white !text-black !ring-gray-2 !focus-ring-[rgb(var(--ui-primary))] !placeholder-stone-4"
        name="username"
        :placeholder="t('loginForm.usernamePlaceholder')"
        @blur="easyValidate"
      />
    </div>
    <div class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.passwordLabel') }}
      </div>
      <m-input
        v-model="form.password"
        class="!bg-white !text-black !ring-gray-2 !focus-ring-[rgb(var(--ui-primary))] !placeholder-stone-4"
        name="password"
        type="password"
        :placeholder="t('loginForm.passwordPlaceholder')"
        @blur="easyValidate"
      />
    </div>
    <div v-if="captchaEnable && codeType === 'captcha'" class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.codeLabel') }}
      </div>
      <m-input
        v-model="form.code"
        class="!bg-white !text-black !ring-gray-2 !focus-ring-[rgb(var(--ui-primary))] !placeholder-stone-4"
        name="code"
        :placeholder="t('loginForm.codePlaceholder')"
        @blur="easyValidate"
      >
        <template #suffix>
          <div class="ml-0.5 w-30 flex items-center justify-center text-sm">
            <img
              :src="captchaImage"
              alt="验证码"
              class="h-9 w-30 rounded cursor-pointer"
              @click="getCaptcha"
            />
          </div>
        </template>
      </m-input>
    </div>
    <div v-if="captchaEnable && codeType === 'google2fa'" class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.google2faLabel') }}
      </div>
      <m-input
        v-model="form.google2fa"
        class="!bg-white !text-black !ring-gray-2 !focus-ring-[rgb(var(--ui-primary))] !placeholder-stone-4"
        name="google2fa"
        :placeholder="t('loginForm.google2faPlaceholder')"
        maxlength="6"
        @blur="easyValidate"
      />
    </div>
    <div class="mine-login-form-item mt-2">
      <m-button
        type="submit"
        class="!bg-[rgb(var(--ui-primary))] !text-gray-1 !active-bg-[rgb(var(--ui-primary))] !hover-bg-[rgb(var(--ui-primary)/.75)]"
        :class="{
          // 'py-3': userStore.getLanguage() === 'en',
          loading: isFormSubmit,
        }"
      >
        <ma-svg-icon name="formkit:submit" /> {{ t('loginForm.loginButton') }}
      </m-button>
    </div>
  </form>
</template>

<style scoped lang="scss">
.loading {
  @apply cursor-wait;

  background-color: rgb(var(--ui-primary) / 45%) !important;
}
</style>
