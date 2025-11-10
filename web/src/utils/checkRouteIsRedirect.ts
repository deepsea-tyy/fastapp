
import type { MineRoute } from '#/global'

export default function checkRouteIsRedirect(route: MineRoute.routeRecord, type: 'redirect' | 'component' = 'redirect'): boolean {
  if (type === 'redirect' && route.redirect && route?.meta?.type === 'M') {
    return true
  }

  return !!(route.component && route.path)
}
