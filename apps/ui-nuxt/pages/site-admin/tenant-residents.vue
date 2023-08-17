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
      <ResidentsList :residents="residents" show-support-action/>
    </UCard>
</template>

<script lang="ts" setup>
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

</script>