<template>
  <UTable
    :rows="tenancies"
    :columns="[
      {key: 'actions'},
      {key: 'email', label: 'Email', sortable: true},
      {key: 'status', label: 'Status', sortable: true},
      {key: 'appTenantName', label: 'Tenant', sortable: true},
    ]"
    :sort="{ column: 'appTenantName', direction: 'asc' }"
  >
    <template #email-data="{ row }">
      <NuxtLink :to="`/admin/app-tenant-user-tenancies/${row.id}`">{{ row.email }}</NuxtLink>
    </template>
    <template #actions-data="{ row }">
      <UButton v-if="rowActionName" @click="handleRowAction(row)">{{rowActionName}}</UButton>
    </template>
  </UTable>
</template>

<script lang="ts" setup>
  defineProps<{
    tenancies: AppUserTenancy[]
    rowActionName?: string
  }>()

  const emit = defineEmits<{
    (e: 'rowAction', row: AppUserTenancy): void
  }>()

  const handleRowAction = async (row: AppUserTenancy) => {
    emit('rowAction', row)
  }
</script>