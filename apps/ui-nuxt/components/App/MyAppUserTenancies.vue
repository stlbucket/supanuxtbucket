<template>
  <AppUserTenancies 
    title="MY APP USER TENANCIES" 
    :tenancies="tenancies"
    rowActionName="Assume"
    @rowAction="assumeAppUserTenancy"
  >
  </AppUserTenancies>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const tenancies = ref([])
  const loadData = async () => {
    const result = await GqlMyAppUserTenancies()
    tenancies.value = result.myAppUserTenanciesList || []
  }
  loadData()

  const assumeAppUserTenancy = async (row: any) => {
    const { data, error } = await GqlAssumeAppUserTenancy({
      appUserTenancyId: row.id
    })
    if (error) alert(error.toString())

    await supabase.auth.refreshSession()
    reloadNuxtApp({path: '/todo'})
  }
</script>