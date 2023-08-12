<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div>ADDRESS BOOK</div>
        <UButton @click="onLeave" v-if="abUsers.length">Leave</UButton>
        <UButton @click="onJoin" v-else>Join</UButton>
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
  const onInviteUser = async (row) => {
    const result = await GqlInviteUser({
      email: row.email
    })
    navigateTo('/admin/app-tenant-user-tenancies')
  }
</script>
