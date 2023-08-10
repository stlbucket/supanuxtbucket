<template>
  <UCard>
    <template #header>License Types</template>
    <UTable
      :rows="licenseTypes"
      :columns="[
        {key: 'issuedCount', label: '# issued'},
        {key: 'key', label: 'Key'},
        {key: 'permissions', label: 'Permissions'},
      ]"
    >
      <template #issuedCount-data="{ row }">
        {{ row.licenses.totalCount }}
      </template>
      <template #permissions-data="{ row }">
        <UBadge v-for="p in row.permissions">{{ p.permissionKey }}</UBadge>
      </template>
    </UTable>
    <!-- <pre>{{ licenseTypes }}</pre> -->
  </UCard>
</template>

<script lang="ts" setup>
  defineProps<{
    licenseTypes: []
  }>()
</script>
