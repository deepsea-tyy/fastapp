
export default function isSuperAdmin() {
  return useUserStore().getRoles().includes('SuperAdmin')
}
