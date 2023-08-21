<template>
  <UTable
    :rows="residents"
    :columns="[
      {key: 'action'},
      {key: 'displayName', label: 'Display Name', sortable: true},
      // {key: 'email', label: 'Email', sortable: true},
      {key: 'status', label: 'Status', sortable: true},
      {key: 'tenantName', label: 'Tenant', sortable: true},
    ]"
    :sort="{ column: 'tenantName', direction: 'asc' }"
  >
    <template #email-data="{ row }">
      <NuxtLink :to="`/admin/app-tenant-residencies/${row.id}`">{{ row.email }}</NuxtLink>
    </template>
    <template #action-data="{ row }">
        <UButton v-if="rowActionName" @click="handleRowAction(row)">{{rowActionName}}</UButton>
        <!-- <UButton @click="onSupport(row)" v-if="showSupportAction">Support</UButton> -->
      </template>
  </UTable>
</template>

<script lang="ts" setup>

  defineProps<{
    residents: Resident[]
    rowActionName?: string
    showSupportAction?: boolean
  }>()

  const emit = defineEmits<{
    (e: 'rowAction', row: Resident): void
  }>()

  const handleRowAction = async (row: Resident) => {
    emit('rowAction', row)
  }


</script>