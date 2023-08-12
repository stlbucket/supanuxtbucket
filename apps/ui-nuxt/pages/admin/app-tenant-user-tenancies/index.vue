<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="flex text-2xl">TENANT USERS</div>
        <div class="flex text-xs">Invitees may not yet be app users</div>
      </div>
      <ResidencyModal @new-app-user-tenancy="onNewResidency"/>
    </template>
    <AppUserTenancies :tenancies="tenancies"/>
  </UCard>
</template>

<script lang="ts" setup>
  const tenancies = ref([])
  const loadData = async () => {
    const result = await GqlTenantAppUserTenancies()
    tenancies.value = result.tenantAppUserTenancies.nodes || []
  }
  loadData()

  const onNewResidency = async (email: string) => {
    const result = await GqlInviteUser({
      email: email
    })
    navigateTo(`/admin/app-tenant-user-tenancies/${result.inviteUser.residency.id}`)
  }
</script>