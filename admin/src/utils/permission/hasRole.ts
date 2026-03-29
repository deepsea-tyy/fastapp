
import hasIncludesByArray from '../hasIncludesByArray'

export default function hasRole(value: string | string[], whetherCheckRouteMeta: boolean = false): boolean {
  if (!value) {
    return false
  }

  const roles = useUserStore().getRoles()

  if (!roles) {
    return false
  }

  if (roles.includes('SuperAdmin')) {
    return true
  }

  let values: string[]
  if (whetherCheckRouteMeta) {
    const meta = (useRoute()?.meta?.role ?? []) as string[]
    values = (Array.isArray(value) ? value.push(...meta) : [value, ...meta]) as string[]
  }
  else {
    values = Array.isArray(value) ? value : [value]
  }

  return hasIncludesByArray(roles, values)
}
