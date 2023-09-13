<template>
  <UCard>
    <template #header>
      <div class="flex pb-3">
        <div class="flex-1">{{ application.name }}</div>
        <div class="flex-1">{{ application.key }}</div>
      </div>
      <div class="md:hidden flex flex-col">
        <LicenseTypeListSmall :license-types="application.licenseTypes || []" />
      </div>
      <div class="hidden md:flex">
        <LicenseTypeList :license-types="application.licenseTypes || []" />
      </div>
    </template>
  </UCard>  
</template>

<script lang="ts" setup>
  defineProps<{
    application: Application
  }>()
</script>
