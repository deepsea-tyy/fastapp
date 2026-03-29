
import type { Directive, DirectiveBinding } from 'vue'
import hasRole from '@/utils/permission/hasRole'

export const role = {
  mounted(el: HTMLElement, binding: DirectiveBinding<string | string[]>) {
    const { value } = binding
    if (value) {
      hasRole(value) || el.parentNode?.removeChild(el)
    }
    else {
      throw new Error(
        '[Directive: role]: please provide a value, like v-role="[\'superAdmin\',\'other\']"',
      )
    }
  },
} as Directive
