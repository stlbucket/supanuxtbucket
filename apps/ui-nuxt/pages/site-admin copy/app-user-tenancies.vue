<template>
    <UCard>
      <template #header>
        <div class="flex justify-between">
          <div class="flex text-2xl">APP USER TENANCIES</div>
          <div class="flex text-xs">Invitees may not yet be actual users</div>
        </div>
      </template>
      <AppUserTenancies :tenancies="tenancies"/>
    </UCard>
</template>

<script lang="ts" setup>
  const tenancies = ref([])
  const loadTenancies = async () => {
    const result = await GqlAllAppUserTenancies()
    tenancies.value = result.allAppUserTenancies.nodes || []
  }
  loadTenancies()

  const onNew = async () => {
    alert('not implemented')
  }
</script>