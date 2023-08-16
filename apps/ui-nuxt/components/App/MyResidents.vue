<template>
  <ResidentsList 
    title="MY APP USER TENANCIES" 
    :residents="residents"
    rowActionName="Assume"
    @rowAction="assumeResidency"
  >
  </ResidentsList>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const residents = ref([])
  const loadData = async () => {
    const result = await GqlMyResidents()
    residents.value = result.myResidentsList || []
  }
  loadData()

  const assumeResidency = async (row: any) => {
    const { data, error } = await GqlAssumeResident({
      residentId: row.id
    })
    if (error) alert(error.toString())

    await supabase.auth.refreshSession()
    reloadNuxtApp({path: '/todo'})
  }
</script>