<template>
  <Residents 
    title="MY APP USER TENANCIES" 
    :residents="residents"
    rowActionName="Assume"
    @rowAction="assumeResident"
  >
  </Residents>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const residents = ref([])
  const loadData = async () => {
    const result = await GqlMyResidents()
    residents.value = result.myResidentsList || []
  }
  loadData()

  const assumeResident = async (row: any) => {
    const { data, error } = await GqlAssumeResident({
      residentId: row.id
    })
    if (error) alert(error.toString())

    await supabase.auth.refreshSession()
    reloadNuxtApp({path: '/todo'})
  }
</script>