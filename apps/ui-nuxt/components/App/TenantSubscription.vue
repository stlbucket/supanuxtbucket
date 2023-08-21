<template>
  <LicensePack :license-pack="subscription.licensePack" />
</template>

<script lang="ts" setup>
  const props = defineProps<{
    subscription: TenantSubscription
  }>()
</script>