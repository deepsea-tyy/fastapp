<i18n lang="yaml">
en:
  change:
    info: Modify info
    password: Modify password
  changeInfo:
    nicknameLabel: Nick name
    signedLabel: Signed
    nicknamePlaceholder: please input nickname
    signedPlaceholder: please input signed
    avatarLabel: Avatar
    old_passwordLabel: Old password
    new_passwordLabel: New password
    new_password_confirmationLabel: Confirm password
    old_passwordPlaceholder: please input old password
    new_passwordPlaceholder: please input new password
    new_password_confirmationPlaceholder: please input confirm password
zh_CN:
  change:
    info: 修改信息
    password: 修改密码
  changeInfo:
    nicknameLabel: 昵称
    signedLabel: 个人签名
    nicknamePlaceholder: 请输入昵称
    signedPlaceholder: 请输入个人签名
    avatarLabel: 头像
    old_passwordLabel: 旧密码
    new_passwordLabel: 新密码
    new_password_confirmationLabel: 确认密码
    old_passwordPlaceholder: 请输入旧密码
    new_passwordPlaceholder: 请输入新密码
    new_password_confirmationPlaceholder: 请输入确认密码
zh_TW:
  change:
    info: 修改資料
    password: 修改密碼
  changeInfo:
    nicknameLabel: 昵稱
    signedLabel: 個人簽名
    nicknamePlaceholder: 請輸入昵稱
    signedPlaceholder: 請輸入個人簽名
    avatarLabel: 頭像
    old_passwordLabel: 舊密碼
    new_passwordLabel: 新密碼
    new_password_confirmationLabel: 確認密碼
    old_passwordPlaceholder: 請輸入舊密碼
    new_passwordPlaceholder: 請輸入新密碼
    new_password_confirmationPlaceholder: 請輸入確認密碼
</i18n>

<script setup lang="ts">
import type { MineRoute } from '#/global'
import { useI18n } from 'vue-i18n'
import { useMessage } from '@/hooks/useMessage.ts'
import { formatFileUrl, parseFilePath } from '@/utils/common.ts'

const route = useRoute() as MineRoute.routeRecord
const { t } = useI18n({ useScope: 'local' })
const { t: gt } = useI18n()

const msg = useMessage()
const userStore = useUserStore()
const selected = ref('userinfo')
const isSubmitting = ref(false)

const tabOptions = reactive([
  { label: t('change.info'), value: 'userinfo' },
  { label: t('change.password'), value: 'password' },
])

const profileForm = reactive({
  nickname: userStore.getUserInfo().nickname,
  signed: userStore.getUserInfo().signed,
})

const avatar = ref<string>(formatFileUrl(userStore.getUserInfo().avatar))

const passwordForm = reactive({
  old_password: '',
  new_password: '',
  new_password_confirmation: '',
})

function update(data: Record<string, any>) {
  return useHttp().post('/admin/permission/update', data)
}

async function submitProfile() {
  isSubmitting.value = true
  const response: any = await update({
    nickname: profileForm.nickname,
    signed: profileForm.signed,
    avatar: parseFilePath(avatar.value) ?? '',
  })
  if (response.code === 200) {
    msg.success(gt('crud.updateSuccess'))
    userStore.getUserInfo().nickname = profileForm.nickname
    userStore.getUserInfo().signed = profileForm.signed
    userStore.getUserInfo().avatar = avatar.value ?? ''
  }
  isSubmitting.value = false
}

async function submitPassword() {
  isSubmitting.value = true
  const response: any = await update(passwordForm)
  if (response.code === 200) {
    msg.success(gt('crud.updateSuccess'))
    passwordForm.old_password = ''
    passwordForm.new_password = ''
    passwordForm.new_password_confirmation = ''
  }
  isSubmitting.value = false
}
</script>

<template>
  <div class="h-full bg-gray-1 dark-bg-dark-6">
    <div
      class="h-[55px] flex items-center bg-white px-3 dark-bg-dark-8 dark-b-b-dark-4 b-b-1 b-b-solid b-b-gray-2"
    >
      <div class="flex items-center gap-x-2">
        <ma-svg-icon v-if="route.meta?.icon" :name="route.meta?.icon ?? ''" size="20" />
        {{ route.meta?.title ?? '未知' }}
      </div>
    </div>
    <div class="mine-uc-layout-content">
      <div class="mine-card w-full lg:w-6/12">
        <m-tabs v-model="selected" :options="tabOptions" class="text-sm" />

        <form v-show="selected === 'userinfo'" class="mine-form" @submit.prevent="submitProfile">
          <div class="mine-form-item">
            <div class="mine-form-item-title">
              {{ t('changeInfo.avatarLabel') }}
            </div>
            <ma-upload-image v-model="avatar" />
          </div>
          <div class="mine-form-item">
            <div class="mine-form-item-title">
              {{ t('changeInfo.nicknameLabel') }}
            </div>
            <m-input
              v-model="profileForm.nickname"
              name="nickname"
              :placeholder="t('changeInfo.nicknamePlaceholder')"
            />
          </div>
          <div class="mine-form-item">
            <div class="mine-form-item-title">
              {{ t('changeInfo.signedLabel') }}
            </div>
            <m-textarea
              v-model="profileForm.signed"
              :placeholder="t('changeInfo.signedPlaceholder')"
            />
          </div>
          <m-button
            type="submit"
            class="mt-5 !bg-[rgb(var(--ui-primary))] !text-gray-1"
            :class="{ loading: isSubmitting }"
          >
            {{ t('change.info') }}
          </m-button>
        </form>

        <form v-show="selected === 'password'" class="mine-form" @submit.prevent="submitPassword">
          <div class="mine-form-item">
            <div class="mine-form-item-title">
              {{ t('changeInfo.old_passwordLabel') }}
            </div>
            <m-input
              v-model="passwordForm.old_password"
              type="password"
              name="old_password"
              :placeholder="t('changeInfo.old_passwordPlaceholder')"
            />
          </div>
          <div class="mine-form-item">
            <div class="mine-form-item-title">
              {{ t('changeInfo.new_passwordLabel') }}
            </div>
            <m-input
              v-model="passwordForm.new_password"
              type="password"
              name="new_password"
              :placeholder="t('changeInfo.new_passwordPlaceholder')"
            />
          </div>
          <div class="mine-form-item">
            <div class="mine-form-item-title">
              {{ t('changeInfo.new_password_confirmationLabel') }}
            </div>
            <m-input
              v-model="passwordForm.new_password_confirmation"
              type="password"
              name="new_password_confirmation"
              :placeholder="t('changeInfo.new_password_confirmationPlaceholder')"
            />
          </div>
          <m-button
            type="submit"
            class="mt-5 !bg-[rgb(var(--ui-primary))] !text-gray-1"
            :class="{ loading: isSubmitting }"
          >
            {{ t('change.password') }}
          </m-button>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.mine-form-item-title {
  @apply text-left text-sm mt-3 mb-1.5;
}
</style>
