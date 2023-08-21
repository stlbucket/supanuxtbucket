<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>APP TENANT SUPPORT</div>
        <TenantModal @new="onNewTenant"/>
      </div>
    </template>
    <div>
      <UInput v-model="searchTerm" />
    </div>
    <UTable
      :rows="tenants"
      :columns="[
        {key: 'action'},
        {key: 'name', label: 'Name', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'type', label: 'Type', sortable: true},
        {key: 'identifier', label: 'Identifier', sortable: true},
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #action-data="{ row }">
        <UButton @click="onSupport(row)">Support</UButton>
      </template>
    </UTable>
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
