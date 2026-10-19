/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_LOGO?: string
  readonly VITE_APP_DESKTOP?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
