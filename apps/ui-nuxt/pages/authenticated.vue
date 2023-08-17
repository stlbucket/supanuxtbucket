<template>
  <div class="text-4xl">LOGGING IN</div>
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
      await appStateStore.setLoggedIn(true)

      setTimeout(()=>{
        reloadNuxtApp({
          path: '/tools/todo'
        })
      }, 1000)
    } else {
      reloadNuxtApp({
        path: '/'
      })
    }
  }
  loadUser()
</script>
