<template>
  <UCard>
    <template #header>
      <div class="flex text-xl justify-center">License Types</div>
    </template>
    <div class="flex flex-col" v-for="lt in licenseTypes || []">
      <div class="flex justify-between bg-gray-800 p-1 rounded">
        <div class="text-xl">{{ lt.key }}</div>
        <div class="">{{ lt.licenses.totalCount }} issued</div>
      </div>
      <div class="pt-1 pb-2 px-1">
        <UBadge class="flex m-1" v-for="p in lt.permissions">{{ p.permissionKey }}</UBadge>
      </div>
    </div>
  </UCard>
  <!-- <UCard>
    <template #header>
      <div class="text-xs">LICENSE TYPES</div>
    </template>
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
        <div class="flex flex-wrap">
          <UBadge class="flex m-1" v-for="p in row.permissions">{{ p.permissionKey }}</UBadge>
        </div>
      </template>
    </UTable>
  </UCard> -->
</template>


<script lang="ts" setup>
  defineProps<{
    licenseTypes: LicenseType[]
  }>()
</script>
