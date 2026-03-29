

import { useI18n } from 'vue-i18n'
import type { ComposerTranslation } from 'vue-i18n'

export interface TransType {
  globalTrans: ComposerTranslation
  localTrans: ComposerTranslation
}

export function useTrans(key: any | null = null): TransType | string | any {
  const global = useI18n()
  const local = useI18n({
    inheritLocale: true,
    useScope: 'local',
  })

  if (key === null) {
    return {
      localTrans: local.t,
      globalTrans: global.t,
    }
  }
  else {
    return global.te(key) ? global.t(key) : local.te(key) ? local.t(key) : key
  }
}
