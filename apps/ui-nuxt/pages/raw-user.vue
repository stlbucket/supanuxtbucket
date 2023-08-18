<template>
  <pre>{{ JSON.stringify(user,null,2) }}</pre>
</template>

<script lang="ts" setup>
const user = useSupabaseUser()
</script>