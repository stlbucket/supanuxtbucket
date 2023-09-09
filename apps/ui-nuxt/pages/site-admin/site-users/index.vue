<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="flex text-2xl">SITE USERS</div>
        <div class="flex text-xs">Users who have actually joined the system - not including invitees</div>
      </div>
    </template>
    <div>
      <UInput v-model="searchTerm" data-1p-ignore />
    </div>
    <UTable
      :rows="profiles"
      :columns="[
        {key: 'email', label: 'Email', sortable: true},
        {key: 'firstName', label: 'First Name', sortable: true},
        {key: 'lastName', label: 'Last Name', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #email-data="{ row }">
        <NuxtLink :to="`/site-admin/site-users/${row.id}`">{{ row.email }}</NuxtLink>
      </template>
    </UTable>
  </UCard>  
</template>

<script lang="ts" setup>
  const profiles = ref([])
  const searchTerm = ref()
  const loadData = async () => {
    const result = await GqlSearchProfiles({
      searchTerm: searchTerm.value
    })
    profiles.value = result.searchProfiles.nodes
  }
  loadData()
  watch(()=>searchTerm.value, loadData)
</script>
