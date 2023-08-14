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
        :app-user-tenancy="residency"
        @revoke-license="onRevokeLicense"
        @grant-license="onGrantLicense"
      />
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const componentKey = ref(1)
  const route = useRoute()
  const residency = ref()
  const subscriptions: Ref<any[]> = ref([])

  const loadData = async () => {
    const result = await GqlResidencyById({
      residencyId: route.params.id,
    })
    residency.value = result.residencyById
    subscriptions.value = result.tenantSubscriptions.nodes
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
      residencyId: residency.value.id
    })
    await loadData()
    componentKey.value += 1
  }

  const onBlockResidency = async () => {
    const result = await GqlBlockResidency({
      residencyId: residency.value.id
    })
    await loadData()
  }

  const onUnblockResidency = async () => {
    const result = await GqlUnblockResidency({
      residencyId: residency.value.id
    })
    await loadData()
  }
</script>
