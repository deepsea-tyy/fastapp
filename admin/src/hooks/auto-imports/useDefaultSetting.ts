
import type { SystemSettings } from '#/global'

export default function useDefaultSetting(): SystemSettings.all {
  return inject('defaultSetting') as SystemSettings.all
}
