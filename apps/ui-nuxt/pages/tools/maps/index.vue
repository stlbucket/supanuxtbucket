<template>
  <div class="flex gap-2">
    <div class="flex flex-col gap-1.5 max-w-[50%] min-w-[50%] min-h-[300px] max-h-[300px]">
      <LocationList 
        :locations="locations" 
        @locationSelected="onLocationSelected" 
        :preSelected="[]"
        @new-location="onNewLocation"
        @update-location="onUpdateLocation"
      />
    </div>
    <div class="flex min-w-[30%] min-h-[300px] max-h-[300px] grow z-1">
      <MarkerMap :locations="markedLocations" />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const locations: Ref<ALocation[]> = ref([])
  const markedLocations: Ref<ALocation[]> = ref([])

  const loadData = async () => {
    const result = await GqlAllLocations()
    locations.value = result.locations.nodes.reduce((a: ALocation[],l: ALocation) => {
      const existing = a.find((al: ALocation) => al.name === l.name)
      return existing ? a : [...a, l]
    }, [])
  }
  loadData()

  const onLocationSelected = async (locations: ALocation[]) => {
    markedLocations.value = locations
  }

  const onNewLocation = async(locationInfo: LocationInfo) => {
    const result = await GqlCreateLocation({
      locationInfo: locationInfo
    })
    await loadData()
  }

  const onUpdateLocation = async(locationInfo: LocationInfo) => {
    const result = await GqlUpdateLocation({
      locationInfo: locationInfo
    })
    await loadData()
  }
</script>
