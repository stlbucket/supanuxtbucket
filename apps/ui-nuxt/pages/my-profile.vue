<template>
  <div class="flex flex-col gap-2">
    <div class="flex justify-around">
      <div class="flex flex-col">
        <Myself />
      </div>
      <div class="flex">
        <MyResidents/>
      </div>
    </div>
    <UCard>
      <template #header>
        SUPABASE SESSION
      </template>
      <div class="flex">
        <pre class="text-xs flex max-w-lg flex-wrap">{{ JSON.stringify(supSession,null,2) }}</pre>
      </div>
    </UCard>
  </div>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const supUser = ref()
  const supSession = ref()

  const loadUser = async () => {
    try{
      const { data, error } = await supabase.auth.getSession()
      supUser.value = data.session?.user
      supSession.value = data.session //? { ...data.session, access_token: 'REMOVED'} : null
    } catch (e) {
      console.log('ERROR', e)
    }
  }
  loadUser()
</script>
