<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>APP TENANTS</div>
        <TenantModal @updated="onNewTenant"/>
      </div>
    </template>
    <UTable
      :rows="tenants"
      :columns="[
        {key: 'action'},
        {key: 'name', label: 'Name', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'type', label: 'Type', sortable: true},
        {key: 'identifier', label: 'Identifier', sortable: true},
        // {key: 'subscriptions', label: 'Subscriptions', sortable: true},
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #name-data="{ row }">
        <NuxtLink :to="`/site-admin/app-tenant/${row.id}`">{{ row.name }}</NuxtLink>
      </template>
      <template #action-data="{ row }">
        <UButton @click="onSupport(row)">Support</UButton>
      </template>
    </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const tenants = ref([])
  const loadData = async () => {
    const result = await GqlAllTenants()
    tenants.value = result.tenants.nodes
  }
  loadData()

  const onSupport = async (tenant: Tenant) => {
    const result = await GqlBecomeSupport({
      tenantId: tenant.id
    })
    await supabase.auth.refreshSession()
    reloadNuxtApp({path: '/todo'})
  }

  const onNewTenant = async (createTenantInput: any) => {
    const result = await GqlCreateTenant(createTenantInput)
    await loadData()
  }
</script>
