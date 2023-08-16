<template>
  <UCard>
    <template #header>
      <div class="text-3xl">SUBSCRIPTIONS</div>
    </template>
    <TenantSubscription v-for="s in tenantSubscriptions" :subscription="s"/>
  </UCard>  
</template>

<script lang="ts" setup>
  const tenantSubscriptions = ref([])
  const loadData = async () => {
    const user = await useSupabaseClient().auth.getUser()
    const result = await GqlTenantSubscriptions({
      tenantId: user.data.user?.user_metadata.tenant_id
    })
    tenantSubscriptions.value = result.tenantSubscriptions.nodes.map((ats:any) => {
      return {
        ...ats,
        tenantName: ats.tenant.name
      }
    })
  }
  loadData()
</script>
