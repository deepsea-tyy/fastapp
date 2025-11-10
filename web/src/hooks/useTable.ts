import { useTable as useMaTable } from '@/components/ma-table'
import type { MaTableExpose } from '@/components/ma-table'

export default function useTable(refName: string): Promise<MaTableExpose> {
  return useMaTable(refName)
}
