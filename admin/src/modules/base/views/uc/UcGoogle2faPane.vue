<i18n lang="yaml">
en:
  google2faStatus: Google 2FA Status
  google2faEnabled: Enabled
  google2faDisabled: Disabled
  enableGoogle2fa: Enable Google 2FA
  disableGoogle2fa: Disable Google 2FA
  google2faSecret: Secret Key
  google2faEnableSuccess: Google 2FA enabled successfully
  google2faDisableSuccess: Google 2FA disabled
  google2faCodeError: Invalid verification code
  scanQrcode: Please scan the QR code with Google Authenticator or other compatible apps
  enterCodeToEnable: Please enter the verification code to enable Google 2FA
  enterCodeToDisable: Please enter the verification code to disable Google 2FA
  copySecret: Copy Secret Key
  copySuccess: Copied successfully
zh_CN:
  google2faStatus: Google 2FA 状态
  google2faEnabled: 已启用
  google2faDisabled: 未启用
  enableGoogle2fa: 启用 Google 2FA
  disableGoogle2fa: 禁用 Google 2FA
  google2faSecret: 密钥
  google2faEnableSuccess: Google 2FA 启用成功
  google2faDisableSuccess: Google 2FA 已禁用
  google2faCodeError: 验证码错误
  scanQrcode: 请使用 Google Authenticator 或其他兼容应用扫描二维码
  enterCodeToEnable: 请输入验证码以启用 Google 2FA
  enterCodeToDisable: 请输入验证码以禁用 Google 2FA
  copySecret: 复制密钥
  copySuccess: 复制成功
zh_TW:
  google2faStatus: Google 2FA 狀態
  google2faEnabled: 已啟用
  google2faDisabled: 未啟用
  enableGoogle2fa: 啟用 Google 2FA
  disableGoogle2fa: 禁用 Google 2FA
  google2faSecret: 密鑰
  google2faEnableSuccess: Google 2FA 啟用成功
  google2faDisableSuccess: Google 2FA 已禁用
  google2faCodeError: 驗證碼錯誤
  scanQrcode: 請使用 Google Authenticator 或其他兼容應用掃描二維碼
  enterCodeToEnable: 請輸入驗證碼以啟用 Google 2FA
  enterCodeToDisable: 請輸入驗證碼以禁用 Google 2FA
  copySecret: 複製密鑰
  copySuccess: 複製成功
</i18n>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { useMessage } from '@/hooks/useMessage.ts'
import { disableGoogle2fa, enableGoogle2fa, getGoogle2faSecret } from '~/base/api/passport.ts'
import type { Google2faSecretVo } from '~/base/api/passport.ts'

defineOptions({ name: 'UcGoogle2faPane' })

const { t } = useI18n({ useScope: 'local' })

const userStore = useUserStore()
const msg = useMessage()

const isEnabled = computed(() => userStore.getUserInfo()?.is_google2fa === 1)

const loading = ref(false)
const enableSetup = ref(false)
const secretData = ref<Google2faSecretVo | null>(null)
const enableCode = ref('')
const disableCode = ref('')

watch(isEnabled, (on) => {
  if (on) {
    enableSetup.value = false
    secretData.value = null
    enableCode.value = ''
  }
  else {
    disableCode.value = ''
  }
})

async function fetchSecret() {
  try {
    loading.value = true
    const response = await getGoogle2faSecret()
    if (response.code === 200)
      secretData.value = response.data
  }
  catch (error: any) {
    msg.error(error?.msg || '获取密钥失败')
  }
  finally {
    loading.value = false
  }
}

async function startEnableSetup() {
  enableSetup.value = true
  enableCode.value = ''
  if (!secretData.value)
    await fetchSecret()
}

async function handleEnable() {
  if (!enableCode.value || enableCode.value.length !== 6) {
    msg.warning(t('enterCodeToEnable'))
    return
  }
  if (!secretData.value?.google2fa) {
    msg.error('密钥未获取，请重试')
    return
  }
  try {
    loading.value = true
    const response = await enableGoogle2fa(secretData.value.google2fa, enableCode.value)
    if (response.code === 200) {
      msg.success(t('google2faEnableSuccess'))
      enableSetup.value = false
      enableCode.value = ''
      secretData.value = null
      await userStore.requestUserInfo()
    }
  }
  catch (error: any) {
    msg.error(error?.msg || t('google2faCodeError'))
  }
  finally {
    loading.value = false
  }
}

async function handleDisable() {
  if (!disableCode.value || disableCode.value.length !== 6) {
    msg.warning(t('enterCodeToDisable'))
    return
  }
  try {
    loading.value = true
    const response = await disableGoogle2fa(disableCode.value)
    if (response.code === 200) {
      msg.success(t('google2faDisableSuccess'))
      disableCode.value = ''
      await userStore.requestUserInfo()
    }
  }
  catch (error: any) {
    msg.error(error?.msg || t('google2faCodeError'))
  }
  finally {
    loading.value = false
  }
}

function copySecret() {
  if (!secretData.value?.google2fa)
    return
  navigator.clipboard.writeText(secretData.value.google2fa).then(() => {
    msg.success(t('copySuccess'))
  }).catch(() => {
    msg.error('复制失败')
  })
}

</script>

<template>
  <div class="uc-google2fa-pane uc-form">
    <div class="info-list">
      <li class="!b-none">
        <div class="desc-item">
          <div class="desc-label">
            {{ t('google2faStatus') }}
          </div>
          <div class="desc-value">
            <el-tag :type="isEnabled ? 'success' : 'warning'">
              {{ isEnabled ? t('google2faEnabled') : t('google2faDisabled') }}
            </el-tag>
          </div>
        </div>
      </li>
    </div>

    <template v-if="!isEnabled">
      <div v-if="!enableSetup" class="mt-6">
        <m-button
          type="primary"
          :loading="loading"
          @click="startEnableSetup"
        >
          {{ t('enableGoogle2fa') }}
        </m-button>
      </div>

      <div v-else class="uc-google2fa-pane__block">
        <div v-if="secretData" class="uc-google2fa-pane__section">
          <div class="uc-google2fa-pane__hint">
            {{ t('scanQrcode') }}
          </div>
          <div class="uc-google2fa-pane__qrcode">
            <img :src="secretData.qrcode" alt="QR Code" class="w-48 h-48">
          </div>
        </div>
        <div v-else class="uc-google2fa-pane__loading">
          <el-skeleton :rows="3" animated />
        </div>

        <template v-if="secretData">
          <div class="uc-google2fa-pane__section">
            <div class="uc-google2fa-pane__hint">
              {{ t('google2faSecret') }}
            </div>
            <div class="uc-google2fa-pane__secret-row">
              <el-input
                :model-value="secretData.google2fa"
                readonly
                class="flex-1"
              />
              <m-button @click="copySecret">
                {{ t('copySecret') }}
              </m-button>
            </div>
          </div>
          <div class="uc-google2fa-pane__section">
            <div class="uc-google2fa-pane__hint">
              {{ t('enterCodeToEnable') }}
            </div>
            <el-input
              v-model="enableCode"
              :disabled="loading"
              :maxlength="6"
              placeholder="请输入6位验证码"
              clearable
              @input="enableCode = enableCode.replace(/\D/g, '')"
            />
          </div>
          <m-button
            type="primary"
            class="mt-2"
            :loading="loading"
            :disabled="!enableCode || enableCode.length !== 6"
            @click="handleEnable"
          >
            {{ t('enableGoogle2fa') }}
          </m-button>
        </template>
      </div>
    </template>

    <div v-else class="uc-google2fa-pane__block">
      <div class="uc-google2fa-pane__section">
        <div class="uc-google2fa-pane__hint">
          {{ t('enterCodeToDisable') }}
        </div>
        <el-input
          v-model="disableCode"
          :disabled="loading"
          :maxlength="6"
          placeholder="请输入6位验证码"
          clearable
          @input="disableCode = disableCode.replace(/\D/g, '')"
        />
      </div>
      <m-button
        type="danger"
        class="mt-2"
        :loading="loading"
        :disabled="!disableCode || disableCode.length !== 6"
        @click="handleDisable"
      >
        {{ t('disableGoogle2fa') }}
      </m-button>
    </div>
  </div>
</template>

<style scoped lang="scss">
.uc-form {
  @apply w-full max-w-xl py-1;
}

.info-list {
  @apply w-full;

  & li {
    @apply b-t-1 b-t-gray-2 b-t-solid pr-2.5 dark-b-t-dark-4 py-4 text-sm hover-bg-gray-50 dark-hover-bg-dark-5;

    .desc-item {
      @apply w-full lg:w-6/12 flex items-center justify-between text-stone-8 dark-text-stone-3;

      .desc-label {
        @apply w-6/12 lg:w-5/12 pl-2 lg:pl-3 truncate;
      }

      .desc-value {
        @apply w-6/12 lg:w-7/12 text-left truncate;
      }
    }
  }
}

.uc-google2fa-pane__block {
  @apply mt-6 w-full space-y-4;
}

.uc-google2fa-pane__section {
  @apply space-y-2;
}

.uc-google2fa-pane__hint {
  @apply text-sm text-gray-6 dark-text-gray-4;
}

.uc-google2fa-pane__qrcode {
  @apply flex justify-center p-4 bg-white rounded;
}

.uc-google2fa-pane__secret-row {
  @apply flex items-center gap-2;
}

.uc-google2fa-pane__loading {
  @apply py-4;
}
</style>
