
<script setup lang="ts">
import Message from 'vue-m-message'
import { useI18n } from 'vue-i18n'
import useUserStore from '@/store/modules/useUserStore.ts'
import useSettingStore from '@/store/modules/useSettingStore.ts'
import useHttp from '@/hooks/auto-imports/useHttp.ts'
import type { ResponseStruct } from '#/global'

const { t } = useI18n()
const isProduction: boolean = import.meta.env.MODE === 'production'
const userStore = useUserStore()
const settingStore = useSettingStore()
const router = useRouter()
const isFormSubmit = ref(false)
const needGoogle2fa = ref(false)
const captchaImage = ref('')
const google2faInputRef = ref<{ el: HTMLInputElement } | null>(null)

const form = reactive<{
  username: string
  password: string
  vcode: string
  google2fa_code: string
}>({
  username: isProduction ? '' : 'admin',
  password: isProduction ? '' : '123456',
  vcode: isProduction ? '' : '1234',
  google2fa_code: '',
})

const inputClass = '!bg-white !text-black !ring-gray-2 !focus-ring-[rgb(var(--ui-primary))] !placeholder-stone-4'

async function getCaptcha() {
  const res: ResponseStruct<{ code: string; image: string }> = await useHttp().get(
    `/admin/passport/captcha?t=${Date.now()}`
  )
  form.vcode = ''
  captchaImage.value = res.data.image
}

function validateField(event: Event) {
  const dom = event?.target as HTMLInputElement
  const isEmpty = !form[dom.name as keyof typeof form]?.trim()
  dom.classList.toggle('!ring-red-5', isEmpty)
}

function validateForm(): boolean {
  const requiredFields = ['username', 'password']
  
  // 需要 Google 2FA 时，同时需要验证码和 Google 2FA 码
  if (needGoogle2fa.value) {
    requiredFields.push('vcode', 'google2fa_code')
  } else if (isProduction) {
    requiredFields.push('vcode')
  }

  for (const key of requiredFields) {
    if (!form[key as keyof typeof form]?.trim()) {
      Message.error(t(`loginForm.${key}Placeholder`))
      return false
    }
  }
  return true
}

function buildSubmitData() {
  const data: any = {
    username: form.username,
    password: form.password,
  }
  
  // 需要 Google 2FA 时，同时提交验证码和 Google 2FA 码
  if (needGoogle2fa.value) {
    data.vcode = form.vcode
    data.google2fa_code = form.google2fa_code
  } else if (isProduction) {
    data.vcode = form.vcode
  }
  return data
}

async function handleLoginSuccess(userData: any) {
  if (userData?.verify_again === 'google2fa_code' && !needGoogle2fa.value) {
    needGoogle2fa.value = true
    // 切换到 Google 2FA 模式时，保留验证码，只清空 Google 2FA 码
    form.google2fa_code = ''
    // 如果验证码为空，重新获取
    if (!form.vcode && isProduction) {
      getCaptcha()
    }
    nextTick(() => google2faInputRef.value?.el?.focus())
    return
  }

  if (userData && !userData.verify_again) {
    const welcomePath = settingStore.getSettings('welcomePage').path ?? null
    const redirect = router.currentRoute.value.query?.redirect ?? undefined
    await router.push({ path: redirect ?? welcomePath ?? '/' })
  }

  needGoogle2fa.value = false
  form.google2fa_code = ''
  if (isProduction) getCaptcha()
}

function handleLoginError() {
  if (needGoogle2fa.value) {
    form.google2fa_code = ''
  }
  // 登录失败后刷新验证码
  if (isProduction) {
    getCaptcha()
  }
}

async function submit() {
  if (isFormSubmit.value || !validateForm())
    return

  isFormSubmit.value = true
  try {
    const userData = await userStore.login(buildSubmitData())
    await handleLoginSuccess(userData)
  }
  catch {
    handleLoginError()
  }
  finally {
    isFormSubmit.value = false
  }
}

onMounted(() => {
  if (isProduction) {
    getCaptcha()
  }
})

</script>

<template>
  <form class="mine-login-form" @submit.prevent="submit">
    <div class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.usernameLabel') }}
      </div>
      <m-input
        v-model="form.username"
        :class="inputClass"
        name="username"
        :placeholder="t('loginForm.usernamePlaceholder')"
        @blur="validateField"
      />
    </div>
    <div class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.passwordLabel') }}
      </div>
      <m-input
        v-model="form.password"
        :class="inputClass"
        name="password"
        type="password"
        :placeholder="t('loginForm.passwordPlaceholder')"
        @blur="validateField"
      />
    </div>
    <div v-if="isProduction" class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.codeLabel') }}
      </div>
      <m-input
        v-model="form.vcode"
        :class="inputClass"
        name="vcode"
        :placeholder="t('loginForm.codePlaceholder')"
        @blur="validateField"
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
    <div v-if="needGoogle2fa" class="mine-login-form-item">
      <div class="mine-login-form-item-title">
        {{ t('loginForm.google2faLabel') }}
      </div>
      <m-input
        ref="google2faInputRef"
        v-model="form.google2fa_code"
        :class="inputClass"
        name="google2fa_code"
        :placeholder="t('loginForm.google2fa_codePlaceholder')"
        :disabled="isFormSubmit"
        @blur="validateField"
      />
    </div>
    <div class="mine-login-form-item mt-2">
      <m-button
        type="submit"
        class="!bg-[rgb(var(--ui-primary))] !text-gray-1 !active-bg-[rgb(var(--ui-primary))] !hover-bg-[rgb(var(--ui-primary)/.75)]"
        :class="isFormSubmit ? 'loading' : ''"
      >
        <ma-svg-icon
          :name="isFormSubmit ? 'svg-spinners:ring-resize' : 'formkit:submit'"
        />
        {{ t('loginForm.loginButton') }}
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
