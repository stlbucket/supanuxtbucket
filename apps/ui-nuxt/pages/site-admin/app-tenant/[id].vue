<template>
  <UCard v-if="tenant">
    <template #header>
      <div class="flex justify-between">
        <div class="text-3xl">{{ tenant.name }}</div>
        <div class="flex gap-2">
          <UButton v-if="tenant.status === 'ACTIVE'" @click="onDeactivateTenant" color="red">Deactivate</UButton>
          <UButton v-if="tenant.status === 'INACTIVE'" @click="onActivateTenant" color="yellow">Activate</UButton>
        </div>
      </div>
    </template>
    <div class="flex justify-start gap-5">
      <div class="flex flex-col gap-1 bg-cyan-700 p-3">
        <div class="flex text-xs">Status</div>
        <div class="flex">{{ tenant.status }}</div>
      </div>
      <div class="flex flex-col gap-1 bg-cyan-700 p-3">
        <div class="flex text-xs">Type</div>
        <div class="flex">{{ tenant.type }}</div>
      </div>
      <div class="flex flex-col gap-1 bg-cyan-700 p-3">
        <div class="flex text-xs"># Residents</div>
        <div class="flex">{{ tenant.residents.totalCount }}</div>
      </div>
    </div>
    <UCard>
      <template #header>
        SUBSCRIPTIONS
      </template>
      <UTable
        :rows="tenant.tenantSubscriptions"
        :columns="[
          {key: 'licensePackKey', label: 'Key'},
          {key: 'licenseCount', label: '# Licenses'}
        ]"
      >
        <template #licenseCount-data="{row}">
          {{ row.licenses.totalCount }}
        </template>
      </UTable>
    </UCard>
  </UCard>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const tenant = ref()

  const loadData = async () => {
    const result = await GqlTenantById({
      tenantId: route.params.id,
    })
    tenant.value = result.tenant
  }
  loadData()

  const onDeactivateTenant = async () => {
    const result = await GqlDeactivateTenant({
      tenantId: tenant.value.id
    })
    await loadData()
  }

  const onActivateTenant = async () => {
    const result = await GqlActivateTenant({
      tenantId: tenant.value.id
    })
    await loadData()
  }
  </script>
