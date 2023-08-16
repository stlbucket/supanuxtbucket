<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="flex text-2xl">APP USERS</div>
        <div class="flex text-xs">Invitees may not yet be app users</div>
      </div>
      <ResidentModal @new-resident="onNewResident"/>
    </template>
    <ResidentsList :residents="residents"/>
  </UCard>
</template>

<script lang="ts" setup>
  const residents = ref([])
  const loadData = async () => {
    const result = await GqlAllResidents()
    residents.value = result.residents.nodes || []
  }
  loadData()

  const onNewResident = async (email: string) => {
    const result = await GqlInviteUser({
      email: email
    })
    navigateTo(`/admin/app-tenant-residencies/${result.inviteUser.resident.id}`)
  }
</script>