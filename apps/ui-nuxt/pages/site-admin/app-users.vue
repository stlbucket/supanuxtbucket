<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="flex text-2xl">AUTH USERS</div>
        <div class="flex text-xs">Users who have actually joined the system - not including invitees</div>
      </div>
    </template>
    <UTable
      :rows="profiles"
      :columns="[
        {key: 'email', label: 'Email', sortable: true},
        {key: 'firstName', label: 'First Name', sortable: true},
        {key: 'lastName', label: 'Last Name', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'licenses', sortable: true}
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #licenses-data="{ row }">
        {{ `${row.tenancies.length} Tenanc${row.tenancies.length > 1 ? 'ies' : 'y'}` }}
      </template>
    </UTable>
  </UCard>  
</template>

<script lang="ts" setup>
  const profiles = ref([])
  const loadData = async () => {
    const result = await GqlAllAppUsers()
    profiles.value = result.allAppUsers.nodes
  }
  loadData()
</script>
