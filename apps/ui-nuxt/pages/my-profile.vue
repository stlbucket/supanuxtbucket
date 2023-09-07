<template>
    <div class="flex">
      <div class="flex flex-col">
        <Myself />
        <MyResidents/>
      </div>
      <div class="flex">
        <UCard>
          <template #header>
            SUPABASE USER
          </template>
          <pre class="text-xs">{{ JSON.stringify(supUser,null,2) }}</pre>
        </UCard>
      </div>
    </div>
    <UCard>
          <template #header>
            SUPABASE SESSION
          </template>
          <pre class="text-xs">{{ JSON.stringify(supSession,null,2) }}</pre>
        </UCard>
</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()
  const supUser = ref()
  const supSession = ref()

  const loadUser = async () => {
    try{
      const { data, error } = await supabase.auth.getSession()
      supUser.value = data.session?.user
      supSession.value = data.session
    } catch (e) {
      console.log('ERROR', e)
    }
  }
  loadUser()
</script>
