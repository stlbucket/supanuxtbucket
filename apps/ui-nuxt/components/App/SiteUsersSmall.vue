<template>
  <div v-for="p in profiles" class="flex flex-col">
    <div class="flex"><NuxtLink :to="`/site-admin/site-users/${p.id}`">{{ p.email }}</NuxtLink></div>
    <div class="flex">{{ p.firstName }} {{ p.lastName }}</div>
    <div class="flex">{{ p.status }}</div>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    profiles: any[]
  }>()
</script>
