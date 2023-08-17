<template>
  <UCard>
    <template #header>
      INCIDENTS 
    </template>
    <UTable
      :rows="incidents"
      :columns="[
        {key: 'name', label: 'Name'},
        {key: 'status', label: 'Status'}
      ]"
    >
      <template #name-data="{row}">
        <NuxtLink :to="`/incidents/${row.id}`">{{ row.name }}</NuxtLink>
      </template>
    </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const incidents: Ref<any[]> = ref([])

  const loadData = async () => {
    const result = await GqlAllIncidents()
    incidents.value = result.incidents.nodes
  }
  loadData()
</script>