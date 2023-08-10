<template>
  <UCard>
    <template #header>
      <div class="flex pb-3">
        <div class="flex-1">{{ application.name }}</div>
        <div class="flex-1">{{ application.key }}</div>
      </div>
      <LicenseTypeList :license-types="application.licenseTypes" />
    </template>
  </UCard>  
</template>

<script lang="ts" setup>
  defineProps<{
    application: Application
  }>()
</script>
