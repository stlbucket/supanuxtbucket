<template>
  <UCard>
    <template #header>
      <div class="menu-bar">
        <div>DEMO TENANCIES</div>
        <div><UIcon name="i-heroicons-shield-exclamation"/><span class="text-xs border-2"> Look here for more info about this component: /supabase/seed.sql</span></div>
      </div>
    </template>
    <UTable
      :rows="residents"
      :columns="[
        {key: 'actions'},
        {key: 'email', label: 'Email', sortable: true},
        {key: 'status', label: 'Status', sortable: true},
        {key: 'tenantName', label: 'Tenant', sortable: true},
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
  const residents = ref([])
  const loadResidents = async () => {
    const result = await GqlDemoResidents()
    residents.value = result.residents.nodes || []
  }
  loadResidents()

  // const handleLogin = async (resident: Resident) => {
  //   const { error } = await supabase.auth.signInWithOtp({
  //     email: resident.email,
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