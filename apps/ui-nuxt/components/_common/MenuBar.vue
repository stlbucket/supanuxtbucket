
<template>
  <div class="flex justify-between px-2 py-3 bg-gray-700">
    <UButton
      :icon="`${navCollapsed ? 'i-heroicons-bars-4' : 'i-heroicons-arrow-left-on-rectangle'}`"
      size="sm"
      color="primary"
      square variant="outline"
      @click="onToggleCollapsed"
    />

    <div class="text-3xl hover:bg-sky-700 focus:cursor-pointer" @click="navigateTo('/')">SupaNuxtPhile</div>
    <div class="flex basis-2/3 gap-3">
      <Auth />
      <ColorMode />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const appStateStore = useAppStateStore()

const navCollapsed = computed(() => {
    return appStateStore.navCollapsed
  })

  const onToggleCollapsed = async () => {
    appStateStore.setNavCollapsed(!appStateStore.navCollapsed)
  }
</script>