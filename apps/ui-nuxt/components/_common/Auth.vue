<template>
  <UCard class="card">
    <div v-if="!supUser" class="login">
      <UInput placeholder="Your Email address" v-model="email"></UInput>
      <UButton @click="handleLogin">Send Magic Link</UButton>
    </div>
    <div v-else class="card">
      <div class="menu-bar">
        <div v-if="showExitSupportMode"><UButton color="yellow" @click="exitSupportMode">Exit Support Mode</UButton></div>
        <div class="text-sm"><NuxtLink to="/my-profile">{{ supUser.user_metadata.display_name }}</NuxtLink></div>
        <div>
          <UButton @click="handleLogout">Logout</UButton>
        </div>
        <div class="text-sm">{{ supUser.user_metadata.app_tenant_name }}</div>
      </div>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const supUser = useSupabaseUser()
  const supabase = useSupabaseClient()
  const email = ref('')

  const handleLogin = async () => {
    const { error } = await supabase.auth.signInWithOtp({
      email: email.value,
      options: {
        emailRedirectTo: 'http://localhost:3025/my-profile',
      }
    })
    if (error) {
      alert(error.message)
    } else {
      alert('Check your email inbox for the magic link!')
    }
  }
  const handleLogout = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) {
      alert(error.message)
    }
    supUser.value = null
    reloadNuxtApp({
      path: '/',
      force: true
    })
  }
  const showExitSupportMode = computed(() => {
    return !(!supUser.value?.user_metadata.actual_resident_id)
  })
  const exitSupportMode = async () => {
    const { data, error } = await GqlExitSupportMode()
    if (error) alert(error.toString())
    await supabase.auth.refreshSession()
    reloadNuxtApp({
      path: '/site-admin/app-tenant',
      force: true
    })    
  }
</script>