<template>
  <div class="flex flex-col grow">
    <UCard :ui="{
      header: {
        padding: 'py-4 px-4'
      }
    }">
      <template #header>
        MY RESIDENCIES
      </template>
      <div class="flex">
        <ResidentsList
          title="MY APP USER TENANCIES" 
          :residents="residents"
          row-action-name="Assume"
          @row-action="assumeResidency"
          disable-sort
        >
        </ResidentsList>
      </div>
    </UCard>
  </div>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const residents = ref([])
  const loadData = async () => {
    const result = await GqlMyProfileResidencies()
    residents.value = result.myProfileResidenciesList || []
  }
  loadData()

  const assumeResidency = async (row: Resident) => {
    const { data, error } = await GqlAssumeResident({
      residentId: row.id
    })
    if (error) alert(error.toString())

    await supabase.auth.refreshSession()
    reloadNuxtApp({path: '/my-profile', force: true})
  }
</script>