<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="flex text-2xl">APP USERS</div>
        <div class="flex text-xs">Invitees may not yet be app users</div>
      </div>
      <ResidentModal @new-resident="onNewResident"/>
    </template>
    <ResidentsList 
      :residents="residents"
      show-display-name
      show-email
    />
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

    const url = `/api/invite-user`
    const { data, pending, error, refresh } = await useFetch(url, {
      method: 'POST',
      body: {
        email: email
      }
    })

    if (error.value) {
      alert(error.value.data.message)
    } else {
      alert(`${data.value?.inviteResult.data.user?.email} has been invited`)
    }

    // const result = await GqlInviteUser({
    //   email: email
    // })
    // navigateTo(`/admin/app-tenant-residencies/${result.inviteUser.resident.id}`)
  }
</script>