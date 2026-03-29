
import type { Directive, DirectiveBinding } from 'vue'
import hasAuth from '@/utils/permission/hasAuth'

export const auth = {
  mounted(el: HTMLElement, binding: DirectiveBinding<string | string[]>) {
    const { value } = binding
    if (value) {
      hasAuth(value) || el.parentNode?.removeChild(el)
    }
    else {
      throw new Error(
        '[Directive: auth]: please provide a value, like v-auth="[\'user:add\',\'user:edit\']"',
      )
    }
  },
} as Directive
