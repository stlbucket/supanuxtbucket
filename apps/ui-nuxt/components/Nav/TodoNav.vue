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
        label: 'Todo',
        icon: 'i-heroicons-clipboard-document-list',
        to: '/tools/todo',
        title: 'Todo',
        permissionKey: ['p:todo']
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