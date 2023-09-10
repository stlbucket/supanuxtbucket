<template>
  <div class="flex flex-col grow">
    <div>
      <LocationModal
        @new="onNewLocation"
      ></LocationModal>
    </div>
    <UTable
      :rows="locations"
      :columns="[
        {key: 'name', label: 'Name'},
        {key: 'loc', label: 'Location'},
        {key: 'action'}
      ]"
      selectable
      v-model="selectedLocations"
    >
      <template #loc-data="{ row }">
        <UPopover mode="hover">
          {{ row.address1 }}
          <template #panel>
            <pre>{{ JSON.stringify(row,null,2) }}</pre>
          </template>
        </UPopover>        
      </template>
      <template #action-data="{ row }">
        <UButton>Delete</UButton>
      </template>
    </UTable>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    locations: ALocation[],
    preSelected: ALocation[]
  }>()
  const selectedLocations: Ref<ALocation[]> = ref([])
  
  const emit = defineEmits<{
    (e: 'locationSelected', locations: ALocation[]): void
  }>()

  const onNewLocation = async (locationInfo: LocationInfo) => {
    alert(JSON.stringify(locationInfo,null,2))
  }

  watch(()=>selectedLocations.value, ()=>{
    emit('locationSelected', selectedLocations.value)
  })
  
  onMounted(()=>{
    selectedLocations.value = props.preSelected || []
  })
</script>
