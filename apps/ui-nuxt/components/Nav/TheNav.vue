<template>
  <UCard>
    <template #header>
      <UButton
        :icon="`${navCollapsed ? 'i-heroicons-arrow-right-on-rectangle' : 'i-heroicons-arrow-left-on-rectangle'}`"
        size="sm"
        color="primary"
        square variant="outline"
        @click="onToggleCollapsed"
      />
    </template>
    <div v-if="showNav.tools">
      <div v-if="!navCollapsed">Tools</div>
      <ToolsNav />
    </div>
    <div v-if="showNav.tenantAdmin">
      <div v-if="!navCollapsed">Tenant Admin</div>
      <TenantAdminNav />    
    </div>
    <div v-if="showNav.siteAdmin">
      <div v-if="!navCollapsed">Site Admin</div>
      <SiteAdminNav />    
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const appStateStore = useAppStateStore()

  const showNav = ref({
    all: false,
    todo: false,
    addressBook: false,
    tools: false,
    zstorm: false,
    zstormAdmin: false,
    tenantAdmin: false,
    siteAdmin: false
  })

  const load = async () => {
    showNav.value.all = user.value ? true : false
    showNav.value.tools = useHasPermission(user, 'p:address-book') || useHasPermission(user, 'p:discussions') || useHasPermission(user, 'p:todo')
    showNav.value.siteAdmin = useHasPermission(user, 'p:app-admin-super')
    showNav.value.tenantAdmin = useHasPermission(user, 'p:app-admin') || useHasPermission(user, 'p:app-admin-super')
    showNav.value.zstorm = useHasPermission(user, 'p:zstorm') || useHasPermission(user, 'p:zstorm-admin')
    showNav.value.zstormAdmin = useHasPermission(user, 'p:zstorm-admin')
  }
  load()

  watch(() => user.value, () => {
    load()
  })

  const navCollapsed = computed(() => {
    return appStateStore.navCollapsed
  })

  const onToggleCollapsed = async () => {
    appStateStore.setNavCollapsed(!appStateStore.navCollapsed)
  }
</script>