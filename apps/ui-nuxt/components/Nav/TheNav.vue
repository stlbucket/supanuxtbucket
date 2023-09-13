<template>
    <USlideover 
      :modelValue="!navCollapsed"
      side="left"
      :ui="{
        width: 'w-screen max-w-[300px]'
      }"
    >
      <UCard
        class="flex grow flex-col"
      >
        <UButton @click="onToggleCollapsed">X</UButton>
        <div class="flex flex-col grow">
          <div v-if="showNav.todo">
            <div v-if="!navCollapsed">Todo</div>
            <TodoNav />
          </div>
          <div v-if="showNav.tools">
            <div v-if="!navCollapsed">Tools</div>
            <ToolsNav />
          </div>
          <div v-if="showNav.tenantAdmin">
            <div v-if="!navCollapsed">Admin</div>
            <TenantAdminNav />    
          </div>
          <div v-if="showNav.siteAdmin">
            <div v-if="!navCollapsed">Site Admin</div>
            <SiteAdminNav />    
          </div>
        </div>
      </UCard>
    </USlideover>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const appStateStore = useAppStateStore()

  const showNav = ref({
    all: false,
    todo: false,
    addressBook: false,
    tools: false,
    tenantAdmin: false,
    siteAdmin: false,
    incidents: false,
    incidentsAdmin: false
  })

  const load = async () => {
    showNav.value.all = user.value ? true : false
    showNav.value.tools = useHasPermission(user, 'p:address-book') || useHasPermission(user, 'p:discussions') || useHasPermission(user, 'p:todo')
    showNav.value.siteAdmin = useHasPermission(user, 'p:app-admin-super')
    showNav.value.tenantAdmin = useHasPermission(user, 'p:app-admin')
    showNav.value.todo = useHasPermission(user, 'p:todo')
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