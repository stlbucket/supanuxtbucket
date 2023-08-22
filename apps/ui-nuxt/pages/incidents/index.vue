<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="text-3xl">INCIDENTS</div>
        <IncidentModal @new="onNewIncident" />
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

  const loadData = async () => {
    const result = await GqlAllIncidents()
    incidents.value = result.incidents.nodes
  }
  loadData()

  const onNewIncident = async (incidentInfo: IncidentInfo) => {
    const result = await GqlCreateIncident({
      name: incidentInfo.name,
      description: incidentInfo.description,
      tags: incidentInfo.tags ?? []
    })
    navigateTo(`/incidents/${result.incident.id}`)
  }
</script>