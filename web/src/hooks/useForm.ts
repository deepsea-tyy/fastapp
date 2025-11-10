import { useForm as useMaForm } from '@/components/ma-form'
import type { MaFormExpose } from '@/components/ma-form'

export default function useForm(refName: string): Promise<MaFormExpose> {
  return useMaForm(refName)
}
