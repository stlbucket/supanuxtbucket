<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>APP TENANT SUPPORT</div>
        <TenantModal @new="onNewTenant"/>
      </div>
    </template>
    <div>
      <div class="flex flex-col">
        <div class="text-xs">SEARCH TERM</div>
        <UInput v-model="searchTerm" data-1p-ignore />
      </div>
    </div>
    <div class="hidden md:flex">
      <TenantList :tenants="tenants" @support="onSupport"/>
    </div>
    <div class="flex md:hidden">
      <TenantListSmall :tenants="tenants" @support="onSupport"/>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const tenants = ref([])
  const searchTerm = ref()
  const loadData = async () => {
    const result = await GqlSearchTenants({
      searchTerm: searchTerm.value
    })
    tenants.value = result.searchTenants.nodes
  }
  loadData()
  watch(()=>searchTerm.value, loadData)

  const onSupport = async (tenant: Tenant) => {
    const result = await GqlBecomeSupport({
      tenantId: tenant.id
    })
    // console.log(result)
    await supabase.auth.refreshSession()
    reloadNuxtApp({path: '/tools/todo'})
  }

  const onNewTenant = async (createTenantInput: NewTenantInfo) => {
    const result = await GqlCreateTenant(createTenantInput)
    await loadData()
  }
</script>
