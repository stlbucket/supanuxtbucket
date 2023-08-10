<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const appStateStore = useAppStateStore()
  const collapsed = computed(() => {
    return appStateStore.navCollapsed
  })

  const links = computed(() => {
    return [
      {
          label: 'App Users',
          icon: 'i-heroicons-users',
          to: '/admin/app-tenant-user-residents',
          title: 'App Users',
        },
        {
          label: 'Subscriptons',
          icon: 'i-heroicons-newspaper',
          to: '/admin/app-tenant-subscriptions',
          title: 'Subscriptons',
        },
      ]
      .map((l: any) => {
        return {
          ...l,
          label: collapsed.value ? '' : l.label
        }
      })
      .filter((l:any) => useHasPermission(user, l.permissionKey))
  })
</script>