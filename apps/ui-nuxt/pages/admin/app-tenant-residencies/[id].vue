<template>
  <UCard v-if="residency"
    :ui="{
      body: {
        base: 'flex flex-col gap-10'
      }
    }"
  >
    <template #header>
      <div class="flex justify-between">
        <div class="text-3xl">App User Tenancy</div>
        <div class="flex gap-2">
          <UButton v-if="residency.status !== 'BLOCKED_INDIVIDUAL' && residency.status !== 'BLOCKED_TENANT'" @click="onBlockResidency" color="red">Block</UButton>
          <UButton v-if="residency.status === 'BLOCKED_INDIVIDUAL'" @click="onUnblockResidency" color="yellow">Unblock</UButton>
        </div>
      </div>
    </template>
    <div class="flex justify-around">
      <div class="flex flex-col gap-1 p-3">
        <div class="flex text-xs">Email</div>
        <div class="flex">{{ residency.email }}</div>
      </div>
      <div class="flex flex-col gap-1 p-3">
        <div class="flex text-xs">Display Name</div>
        <div class="flex">{{ residency.displayName }}</div>
      </div>
      <div class="flex flex-col gap-1 p-3">
        <div class="flex text-xs">Status</div>
        <div class="flex">{{ residency.status }}</div>
      </div>
    </div>
    <div class="flex flex-col gap-1 grow" :key="componentKey">
      <div class="text-2xl">User Licenses by Application</div>
      <div class="text-sm">Users have one scoped license per application and any number of unscoped licenses</div>
      <LicenseAssignment 
        v-for="s in subscriptions"
        :license-pack="s.licensePack" 
        :resident="residency"
        @revoke-license="onRevokeLicense"
        @grant-license="onGrantLicense"
      />
    </div>
    <!-- <div class="flex">
      <div class="flex">
        <pre>{{ JSON.stringify(residency,null,2) }}</pre>
      </div>
      <div class="flex">
        <pre>{{ JSON.stringify(subscriptions,null,2) }}</pre>
      </div>
    </div> -->
  </UCard>
</template>

<script lang="ts" setup>
  const componentKey = ref(1)
  const route = useRoute()
  const residency = ref()
  const subscriptions: Ref<any[]> = ref([])

  const loadData = async () => {
    const result = await GqlResidentById({
      residentId: route.params.id,
    })
    residency.value = result.resident

    const subscriptionsResult = await GqlTenantSubscriptions({
      tenantId: residency.value.tenantId
    })
    subscriptions.value = subscriptionsResult.tenantSubscriptions.nodes
  }
  loadData()

  const onRevokeLicense = async (license:any) => {
    const result = await GqlRevokeUserLicense({
      licenseId: license.id
    })
    await loadData()
  }

  const onGrantLicense = async (licenseTypeKey: string) => {
    const result = await GqlGrantUserLicense({
      licenseTypeKey: licenseTypeKey,
      residentId: residency.value.id
    })
    await loadData()
    componentKey.value += 1
  }

  const onBlockResidency = async () => {
    const result = await GqlBlockResident({
      residentId: residency.value.id
    })
    await loadData()
  }

  const onUnblockResidency = async () => {
    const result = await GqlUnblockResident({
      residentId: residency.value.id
    })
    await loadData()
  }
</script>
