<template>
    <UCard>
      <template #header>
        <div class="flex justify-between">
          <div class="flex text-2xl">APP USER TENANCIES</div>
          <div class="flex text-xs">Invitees may not yet be actual users</div>
        </div>
      </template>
      <ResidentsList :residents="residents"/>
    </UCard>
</template>

<script lang="ts" setup>
  const residents = ref([])
  const loadResidents = async () => {
    const result = await GqlAllResidents()
    residents.value = result.residents.nodes || []
  }
  loadResidents()

  const onNew = async () => {
    alert('not implemented')
  }
</script>