<template>
  <UTabs
    :items="tabItems"
  >
    <template #activeSubscriptions="{ item }">
      <UCard>
        <!-- <template #header>
          <div class="text-3xl">ACTIVE SUBSCRIPTIONS</div>
        </template> -->
        <TenantSubscription
          v-if="activeSubscriptions.length > 0"
          v-for="s in activeSubscriptions" 
          :subscription="s"
        />
        <div v-else class="flex grow justify-center">NO ACTIVE SUBSCRIPTIONS</div>
      </UCard>  
    </template>

    <template #inactiveSubscriptions="{ item }">
      <UCard>
        <!-- <template #header>
          <div class="text-3xl">INACTIVE SUBSCRIPTIONS</div>
        </template> -->
        <TenantSubscription 
          v-if="inactiveSubscriptions.length > 0"
          v-for="s in inactiveSubscriptions" 
          :subscription="s"
        />
        <div v-else class="flex grow justify-center">NO INACTIVE SUBSCRIPTIONS</div>
      </UCard>  
    </template>
  </UTabs>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const tenantSubscriptions = ref([])

  const tabItems = ref([
    {
      slot: 'activeSubscriptions',
      label: 'Active Subscriptions',
    }, 
    {
      slot: 'inactiveSubscriptions',
      label: 'Inactive Subscriptions',
    }
  ])

  const loadData = async () => {
    const result = await GqlTenantSubscriptions({
      tenantId: user.value?.user_metadata.tenant_id
    })
    tenantSubscriptions.value = result.tenantSubscriptions.nodes.map((ats:any) => {
      return {
        ...ats,
        tenantName: ats.tenant.name
      }
    })
  }
  loadData()

  const activeSubscriptions = computed(()=> {
    return tenantSubscriptions.value.filter((s:TenantSubscription) => String(s.status) === 'ACTIVE')
  })

  const inactiveSubscriptions = computed(()=> {
    return tenantSubscriptions.value.filter((s:TenantSubscription) => String(s.status) === 'INACTIVE')
  })
  </script>
