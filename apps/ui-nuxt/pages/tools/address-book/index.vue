<template>
  <UCard>
    <template #header>
      <div class="flex flex-col gap-2">
        <div class="flex justify-between">
          <div>ADDRESS BOOK</div>
          <UButton @click="onLeave" v-if="abUsers.length">Leave</UButton>
          <UButton @click="onJoin" v-else>Join</UButton>
        </div>
      </div>
    </template>
    <UTable
      v-if="abUsers.length"
      :rows="abUsers"
      :columns="[
        {key: 'action'},
        {key: 'email', label: 'Email', sortable: true},
        {key: 'name', label: 'Name', sortable: true},
        {key: 'phone', label: 'Phone', sortable: true},
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #action-data="{ row }">
        <UButton @click="onInviteUser(row)" :disabled="!row.canInvite" title="Admin users can send invitations to users not yet in their organization.">Invite</UButton>
      </template>
      <template #name-data="{ row }">
        {{ row.fullName }}
      </template>
    </UTable>
    <template #footer>
      <div class="text-xs flex p-1">If you join the address book, you will be visible to others who have also joined; and they to you.</div>
      <div class="text-xs flex p-1">This is just a helper for finding and inviting other members and could perhaps be refactored to a full application with more advanced features.</div>
      <div class="text-xs flex p-1">You can still invite user via email even if they are not published here.</div>
      <div class="text-xs flex p-1">Only app-admin users can invite other users.</div>
    </template>
  </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const user = ref()
  const abUsers = ref([])
  const loadData = async () => {
    const result = await GqlGetAbListings()
    abUsers.value = result.getAbListings.nodes
    user.value = (await supabase.auth.getUser()).data.user
  }
  loadData()

  const onJoin = async () => {
    const result = await GqlJoinAddressBook()
    await loadData()
  }
  const onLeave = async () => {
    const result = await GqlLeaveAddressBook()
    await loadData()
  }
  const onInviteUser = async (row: any) => {
    const url = `/api/invite-user`
    const { data, pending, error, refresh } = await useFetch(url, {
      method: 'POST',
      body: {
        email: row.email
      }
    })

    if (error.value) {
      alert(error.value.data.message)
    } else {
      alert(`${data.value?.inviteResult.data.user?.email} has been invited`)
    }


    // const result = await GqlInviteUser({
    //   email: row.email
    // })
    // navigateTo('/admin/app-tenant-residencies')
  }
</script>
