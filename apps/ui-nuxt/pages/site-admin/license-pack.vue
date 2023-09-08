<template>
  <div class="flex flex-col gap-2">
    <div class="flex gap-2">
      <UButton 
        v-for="lp in licensePacks" 
        :color="lp.key === selectedLicensePack?.key ? 'blue' : 'green'"
        @click="onSelectLicensePack(lp)"
      >{{ lp.key }}</UButton>
    </div>
    <UCard v-if="selectedLicensePack">
      <div class="flex flex-col gap-3">
          <LicensePack :licensePack="selectedLicensePack" />
        </div>
    </UCard>
  </div>
</template>

<script lang="ts" setup>
  const licensePacks: Ref<LicensePack[]> = ref([])
  const selectedLicensePack: Ref<LicensePack | undefined> = ref()

  const loadData = async () => {
    const result = await GqlAllLicensePacks()
    licensePacks.value = result.licensePacks.nodes
    selectedLicensePack.value = licensePacks.value[0]
  }
  loadData()

  const onSelectLicensePack = async (licensePack: LicensePack) => {
    selectedLicensePack.value = licensePack
  }
</script>

<!-- <template>
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

</script> -->
