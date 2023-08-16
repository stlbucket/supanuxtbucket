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
        label: 'Address Book',
        icon: 'i-heroicons-book-open',
        to: {name: 'address-book'},
        title: 'Address Book',
        permissionKey: ['p:address-book']
      },
      {
        label: 'Todo',
        icon: 'i-heroicons-clipboard-document-list',
        to: '/todo',
        title: 'Todo',
        permissionKey: ['p:todo']
      },
      {
        label: 'Discussions',
        icon: 'i-heroicons-user-group',
        to: '/discussions',
        title: 'Discussions',
        permissionKey: ['p:discussions']
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