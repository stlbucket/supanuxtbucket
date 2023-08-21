<template>
  <UCard>
    <template #header>
      <div class="flex flex-col pb-3">
        <div class="flex-1">License Pack Key</div>
        <div class="flex-1 text-2xl">{{ licensePack.key }}</div>
      </div>
      <LicensePackLicenseTypeList :license-pack-license-types="licensePack.licensePackLicenseTypes" />
    </template>
  </UCard>  
</template>

<script lang="ts" setup>
  defineProps<{
    licensePack: LicensePack
  }>()
</script>
