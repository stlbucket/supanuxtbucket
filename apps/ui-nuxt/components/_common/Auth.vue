<template>
  <div v-if="!supUser" class="flex">
    <UInput placeholder="Your Email address" v-model="email" data-1p-ignore></UInput>
    <UButton @click="handleLogin">Send Magic Link</UButton>
  </div>
  <div v-else class="flex grow items-center justify-around gap-2">
    <div class="hidden md:flex text-sm">{{ supUser.user_metadata.tenant_name }}</div>
    <div v-if="showExitSupportMode"><UButton color="yellow" @click="exitSupportMode">Exit Support Mode</UButton></div>
    <div class="text-xs"><NuxtLink to="/my-profile">{{ supUser.user_metadata.display_name }}</NuxtLink></div>
    <div>
      <UButton
        @click="handleLogout"
        icon="i-heroicons-arrow-left-on-rectangle"
        size="xs"
        color="white" 
        square 
        variant="solid" 
        title="Logout"
      ></UButton>
    </div>
  </div>
</template>

<script lang="ts" setup>
  const route = useRoute();
  
  const supUser = useSupabaseUser()
  const supabase = useSupabaseClient()
  const email = ref('')
  const appStateStore = useAppStateStore()

  const handleLogin = async () => {
    const { error } = await supabase.auth.signInWithOtp({
      email: email.value,
      options: {
        emailRedirectTo: 'http://localhost:3025/authenticated',
      }
    })
    if (error) {
      alert(error.message)
    } else {
      alert('Check your email inbox for the magic link!')
    }
  }
  const handleLogout = async () => {
    navigateTo('/logout')
    // const { error } = await supabase.auth.signOut()
    // if (error) {
    //   alert(error.message)
    // }
    // supUser.value = null
    // reloadNuxtApp({
    //   path: '/',
    //   force: true
    // })
  }
  const showExitSupportMode = computed(() => {
    return !(!supUser.value?.user_metadata.actual_resident_id)
  })
  const exitSupportMode = async () => {
    const { data, error } = await GqlExitSupportMode()
    if (error) alert(error.toString())
    await supabase.auth.refreshSession()
    reloadNuxtApp({
      path: '/site-admin/tenant',
      force: true
    })    
  }
  const loggedIn = computed(() => {
    return appStateStore.loggedIn
  })
</script>