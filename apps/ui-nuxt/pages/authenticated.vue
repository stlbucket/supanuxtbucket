<template>
  <pre>{{ JSON.stringify(session,null,2) }}</pre>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const appStateStore = useAppStateStore()
  const session = ref()

  const loadUser = async () => {
    try{
      const { data, error } = await supabase.auth.getSession()
      session.value = data.session
      if (data.session) {
        appStateStore.setLoggedIn(true)
        navigateTo('/todo')
      } else {
        navigateTo('/')
      }
    } catch (e) {
      console.log('ERROR', e)
    }
  }
  loadUser()
</script>
