<template>logging out...</template>

<script lang="ts" setup>
  const supabase = useSupabaseClient()

  const handleLogout = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) {
      alert(error.message)
    }
    reloadNuxtApp({
      path: '/',
      force: true
    })
  }
  handleLogout()
</script>