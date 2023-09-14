<template>
    <USlideover
      :modelValue="showNav.all"
      side="left"
      :ui="{
        width: 'w-screen max-w-[300px]'
      }"
      :preventClose="false"
    >
      <UCard
        class="flex grow flex-col"
      >
        <UButton 
          icon="i-heroicons-bars-4"
          size="xs"
          color="white" 
          square 
          variant="solid" 
          title="Close Menu"
          @click="onToggleCollapsed"
        />
        <div class="flex flex-col grow">
          <div v-if="showNav.todo">
            <div v-if="showNav.all">Todo</div>
            <TodoNav />
          </div>
          <div v-if="showNav.tools">
            <div v-if="showNav.all">Tools</div>
            <ToolsNav />
          </div>
          <div v-if="showNav.tenantAdmin">
            <div v-if="showNav.all">Admin</div>
            <TenantAdminNav />    
          </div>
          <div v-if="showNav.siteAdmin">
            <div v-if="showNav.all">Site Admin</div>
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
    showNav.value.tools = useHasPermission(user, 'p:address-book') || useHasPermission(user, 'p:discussions') || useHasPermission(user, 'p:todo')
    showNav.value.siteAdmin = useHasPermission(user, 'p:app-admin-super')
    showNav.value.tenantAdmin = useHasPermission(user, 'p:app-admin')
    showNav.value.todo = useHasPermission(user, 'p:todo')
  }
  load()

  watch(() => user.value, () => {
    load()
  })

  const onToggleCollapsed = async () => {
    appStateStore.toggleNavCollapsed()
  }

  watch(() => appStateStore.navCollapsed, () => showNav.value.all = !appStateStore.navCollapsed)
</script>