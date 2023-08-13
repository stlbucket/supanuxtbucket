<template>
    <div class="flex">
      <div>
        <MyAppUserTenancies />
      </div>
      <div>
        <Myself />
      </div>
      <div>
      </div>
    </div>
    <pre>{{ JSON.stringify(supUser,null,2) }}</pre>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const supUser = ref()

  const loadUser = async () => {
    const { data, error } = await supabase.auth.refreshSession()
    // const { data, error } = await supabase.auth.getUser()
    supUser.value = data.user
    await useGqlHeaders(useRequestHeaders(['cookie']))
  }
  loadUser()
</script>
