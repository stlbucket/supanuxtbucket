<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="text-3xl">INCIDENTS</div>
        <IncidentModal @new="onNewIncident" />
      </div>
      <div>
        <UInput v-model="searchTerm" data-1p-ignore />
      </div>
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
  const searchTerm = ref()

  const loadData = async () => {
    const result = await GqlSearchIncidents({
      searchTerm: searchTerm.value,
      isTemplate: true
    })
    incidents.value = result.searchIncidents.nodes
  }
  loadData()

  watch(()=>searchTerm.value, loadData)

  const onNewIncident = async (incidentInfo: IncidentInfo) => {
    const result = await GqlCreateIncident({
      name: incidentInfo.name,
      description: incidentInfo.description,
      tags: incidentInfo.tags ?? [],
      isTemplate: true
    })
    navigateTo(`/incidents/${result.incident.id}`)
  }
</script>