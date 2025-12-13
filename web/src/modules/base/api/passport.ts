
import type { ResponseStruct } from '#/global'

export interface Google2faSecretVo {
  google2fa: string
  qrcode: string
}

/**
 * Get Google 2FA Secret and QR Code
 */
export function getGoogle2faSecret(): Promise<ResponseStruct<Google2faSecretVo>> {
  return useHttp().get('/admin/passport/google2fa/qrcode')
}

/**
 * Enable Google 2FA (Bind)
 * @param secret - Google 2FA secret key
 * @param code - 6-digit verification code
 */
export function enableGoogle2fa(secret: string, code: string): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/passport/google2fa/bind', { google2fa: secret, google2fa_code: code })
}

/**
 * Disable Google 2FA (Unbind)
 * @param code - 6-digit verification code
 */
export function disableGoogle2fa(code: string): Promise<ResponseStruct<null>> {
  return useHttp().post('/admin/passport/google2fa/unbind', { google2fa_code: code })
}

