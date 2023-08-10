<template>
  <UCard>
    <template #header>
      <div class="menu-bar">
        <div>DEMO TENANCIES</div>
        <div><UIcon name="i-heroicons-shield-exclamation"/><span class="text-xs border-2"> Look here for more info about this component: /supabase/seed.sql</span></div>
      </div>
    </template>
    <UTable
      :rows="tenancies"
      :columns="[
        {key: 'actions'},
        {key: 'email', label: 'Email', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'appTenantName', label: 'Tenant', sortable: true},
      ]"
      :sort="{ column: 'email', direction: 'asc'}"
    >
      <template #actions-data="{ row }">
        <UButton @click="handleLogin(row)">Login</UButton>
      </template>
    </UTable>
  </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const tenancies = ref([])
  const loadTenancies = async () => {
    const result = await GqlDemoAppUserTenancies()
    tenancies.value = result.tenancies.nodes || []
  }
  loadTenancies()

  // const handleLogin = async (appUserTenancy: AppUserTenancy) => {
  //   const { error } = await supabase.auth.signInWithOtp({
  //     email: appUserTenancy.email,
  //     options: {
  //       emailRedirectTo: 'http://localhost:3025'
  //     }
  //   })
  //   if (error) {
  //     alert(error.message)
  //   }
  //   alert('Check your email inbox for the magic link!')
  //   navigateTo('http://localhost:54324/monitor', {external: true})
  // }
</script>