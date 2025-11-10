

import { useI18n } from 'vue-i18n'
import type { ComposerTranslation } from 'vue-i18n'

export function useLocalTrans(key: any | null = null): string | ComposerTranslation | any {
  const { t } = useI18n({
    inheritLocale: true,
    useScope: 'local',
  })
  return key === null ? t as ComposerTranslation : t(key) as string
}
