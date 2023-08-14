<template>
    <div class="flex">
      <div>
        <MyResidents/>
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
    try{
      const { data, error } = await supabase.auth.getSession()
      supUser.value = data.session?.user
    } catch (e) {
      console.log('ERROR', e)
    }
  }
  loadUser()
</script>
