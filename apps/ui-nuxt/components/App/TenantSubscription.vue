<template>
  <UCard>
    <template #header>
      <div class="text-2xl">{{ subscription.licensePackKey }}</div>
    </template>
    <LicensePack :license-pack="subscription.licensePack" />
  </UCard>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    subscription: TenantSubscription
  }>()
</script>