const useHasPermission = (user: any, permissionKey?: string | string[]): boolean => {
  if (!permissionKey || permissionKey.length === 0) return true
  const userPermissions = user.value?.user_metadata?.permissions || []
  if (Array.isArray(permissionKey)) {
    return permissionKey.some(p => userPermissions.includes(p))
  } else {
    return userPermissions.includes(permissionKey)
  }
}

export { useHasPermission }