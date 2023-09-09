<template>
  <div class="flex gap-2">
    <div class="flex flex-col gap-1.5 max-w-[50%] min-w-[50%] min-h-[300px] max-h-[300px]">
      <LocationList :locations="locations" @locationSelected="onLocationSelected" />
    </div>
    <div class="flex min-w-[30%] min-h-[300px] max-h-[300px] grow z-1">
      <MarkerMap :locations="markedLocations" />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const locations = ref([])
  const markedLocations: Ref<IncLocation[]> = ref([])

  const loadData = async () => {
    const result = await GqlAllLocations()
    locations.value = result.locations.nodes.reduce((a,l) => {
      const existing = a.find((al: IncLocation) => al.name === l.name)
      return existing ? a : [...a, l]
    }, [])
  }
  loadData()

  const onLocationSelected = async (locations: IncLocation[]) => {
    markedLocations.value = locations
  }
</script>
