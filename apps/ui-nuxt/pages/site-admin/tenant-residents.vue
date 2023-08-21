<template>
    <UCard>
      <template #header>
        <div class="flex justify-between">
          <div class="flex text-2xl">TENANT RESIDENTS</div>
          <div class="flex text-xs">Invitees may not yet be actual users</div>
        </div>
      </template>
      <div>
        <UInput v-model="searchTerm" />
      </div>
      <ResidentsList :residents="residents" @row-action="onRowAction" row-action-name="Support"/>
    </UCard>
</template>

<script lang="ts" setup>
  const client = useSupabaseClient()
  const residents = ref([])
  const searchTerm = ref()
  const loadData = async () => {
    const result = await GqlSearchResidents({
      searchTerm: searchTerm.value
    })
    residents.value = result.searchResidents.nodes || []
  }
  loadData()
  watch(()=>searchTerm.value, loadData)

  const onRowAction = async (resident: Resident) => {
    const result = await GqlBecomeSupport({
      tenantId: resident.tenantId
    })
    // console.log(result)
    await client.auth.refreshSession()
    reloadNuxtApp({path: `/admin/app-tenant-residencies/${resident.id}`})
  }
</script>