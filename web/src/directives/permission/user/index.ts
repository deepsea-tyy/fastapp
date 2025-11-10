
import type { Directive, DirectiveBinding } from 'vue'
import hasUser from '@/utils/permission/hasUser'

export const user = {
  mounted(el: HTMLElement, binding: DirectiveBinding<string | string[]>) {
    const { value } = binding
    if (value) {
      hasUser(value) || el.parentNode?.removeChild(el)
    }
    else {
      throw new Error(
        '[Directive: user]: please provide a value, like v-user="[\'张三\',\'李四\']"',
      )
    }
  },
} as Directive
