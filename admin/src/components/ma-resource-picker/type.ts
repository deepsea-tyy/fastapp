import type { DialogEmits } from 'element-plus'
import type { MTabsOptionItems } from '@/components/m-basic-ui/components/tab/type.ts'

export interface Resource {
  id?: number
  storage_mode?: number
  origin_name?: string
  object_name?: string
  hash?: string
  mime_type?: string
  storage_path?: string
  suffix?: string
  size_byte?: number
  size_info?: string
  url?: string
  normalized?: number
}

export interface FileType extends MTabsOptionItems<string> {
  value: string
  label: string | (() => string)
  suffix: string
}

export interface ResourcePanelProps {
  multiple?: boolean
  limit?: number
  pageSize?: number
  showAction?: boolean
  defaultFileType?: string
}

export interface ResourcePanelEmits {
  cancel: () => void
  confirm: (value: Resource[]) => void
}

export interface ResourcePickerProps extends ResourcePanelProps {
  visible: boolean
}

export type ResourcePickerEmits = ResourcePanelEmits & DialogEmits
