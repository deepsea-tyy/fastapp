

import type { Dictionary, ProviderService } from '#/global'
import type { App } from 'vue'

const dictionary: Record<string, Dictionary[]> = {}
async function getDictionary() {
  const data = import.meta.glob('./data/**.{ts,js}')
  const pluginData = import.meta.glob('../../plugins/*/*/dictionary/**.{ts,js}')
  const allData = { ...data, ...pluginData }
  for (const dic in allData) {
    const d: any = await allData[dic]()
    const name: string | undefined = dic.match(/\/(data|plugins\/.*\/dictionary)\/(.*)\.(ts|js)/)?.[2] ?? undefined
    if (name) {
      dictionary[name] = d.default
    }
  }
}

const provider: ProviderService.Provider = {
  name: 'dictionary',
  async init() {
    await getDictionary()
  },
  setProvider(app: App) {
    app.config.globalProperties.$dictionary = dictionary
  },
  getProvider(): any {
    return useGlobal().$dictionary
  },
}

export default provider as ProviderService.Provider
