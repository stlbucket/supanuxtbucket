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
        label: 'Incident Types',
        icon: 'i-heroicons-arrows-pointing-in',
        to: '/incident-types',
        title: 'Incident Types',
        // permissionKey: ['p:incidents']
      }
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