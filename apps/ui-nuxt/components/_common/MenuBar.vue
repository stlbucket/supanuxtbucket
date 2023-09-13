
<template>
  <UCard :ui="{
    base: `overflow-hidden grow items-start`
  }">
    <div class="flex grow p-0 justify-between md:px-2 md:py-3 dark:bg-gray-700">
      <div class="flex">
        <UButton 
          :icon="`${navCollapsed ? 'i-heroicons-bars-4' : 'i-heroicons-arrow-left-on-rectangle'}`"
          size="xs"
          color="white" 
          square 
          variant="solid" 
          :title="`${navCollapsed ? 'Expand Menu' : 'Collapse Menu'}`"
          @click="onToggleCollapsed"
        />
      </div>
      <div class="hidden md:flex text-xl hover:bg-sky-700 focus:cursor-pointer" @click="navigateTo('/')">SupaNuxtPhile</div>
      <div class="flex basis-2/3 gap-3">
        <Auth />
        <ColorMode />
      </div>
    </div>    
  </UCard>
</template>

<script lang="ts" setup>
  const appStateStore = useAppStateStore()

  const navCollapsed = computed(() => {
    return appStateStore.navCollapsed
  })

  const onToggleCollapsed = async () => {
    appStateStore.setNavCollapsed(!appStateStore.navCollapsed)
  }

  const minWidthValue = computed(() => {
    return appStateStore.screenWidth
  })

  onMounted(() => {
    appStateStore.setScreenWidth(useScreenWidth())
  })

</script>