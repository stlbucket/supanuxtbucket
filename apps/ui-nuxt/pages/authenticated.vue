<template>
  <pre>{{ JSON.stringify(session,null,2) }}</pre>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const appStateStore = useAppStateStore()
  const session = ref()

  const loadUser = async () => {
  const { data, error } = await supabase.auth.getSession()
    session.value = data.session
    if (data.session) {
      appStateStore.setLoggedIn(true)
      reloadNuxtApp({
        path: '/tools/todo'
      })
    } else {
      reloadNuxtApp({
        path: '/'
      })
    }
  }
  loadUser()
</script>
