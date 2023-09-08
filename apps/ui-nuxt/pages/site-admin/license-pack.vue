<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="text-2xl">LICENSE PACKS</div>
        <UButton @click="onNew">New</UButton>
      </div>
    </template>
      <div class="flex flex-col gap-3">
        <LicensePack v-for="lp in licensePacks" :license-pack="lp" />
      </div>
  </UCard>  
</template>

<script lang="ts" setup>
  const licensePacks = ref([])
  const loadData = async () => {
    const result = await GqlAllLicensePacks()
    licensePacks.value = result.licensePacks.nodes
  }
  loadData()

  const onNew = async () => {
    alert('not implemented')
  }

</script>
