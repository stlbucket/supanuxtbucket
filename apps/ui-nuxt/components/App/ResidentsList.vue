<template>
  <UTable
    :rows="residents"
    :columns="columns"
    :sort="{ column: 'tenantName', direction: 'asc' }"
  >
    <template #email-data="{ row }">
      <NuxtLink :to="`/admin/app-tenant-residencies/${row.id}`">{{ row.email }}</NuxtLink>
    </template>
    <template #action-data="{ row }">
        <UButton v-if="rowActionName" @click="handleRowAction(row)">{{rowActionName}}</UButton>
      </template>
  </UTable>
</template>

<script lang="ts" setup>

  const props = defineProps<{
    residents: Resident[]
    rowActionName?: string
    showEmail?: boolean
    showDisplayName?: boolean
  }>()

  const emit = defineEmits<{
    (e: 'rowAction', row: Resident): void
  }>()

  const handleRowAction = async (row: Resident) => {
    emit('rowAction', row)
  }

  const columns = computed(()=>{
    return [
      {key: 'action'},
      {key: 'displayName', label: 'Display Name', sortable: true},
      {key: 'email', label: 'Email', sortable: true},
      {key: 'status', label: 'Status', sortable: true},
      {key: 'tenantName', label: 'Tenant', sortable: true},
    ]
    .filter(c => c.key !== 'displayName' || props.showDisplayName )
    .filter(c => c.key !== 'email'  || props.showEmail)
  })

</script>