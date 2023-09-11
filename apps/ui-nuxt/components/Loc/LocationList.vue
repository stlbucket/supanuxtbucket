<template>
  <div class="flex flex-col grow">
    <div>
      <LocationModal
        @new-location="onNewLocation"
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
    <template #name-data="{ row }">
        <UPopover mode="hover">
          {{ row.name }}
          <template #panel>
            <pre>{{ JSON.stringify(row,null,2) }}</pre>
          </template>
        </UPopover>        
      </template>
      <template #loc-data="{ row }">
        <UPopover mode="hover">
          {{ row.address1 }}
          <template #panel>
            <pre>{{ JSON.stringify(row,null,2) }}</pre>
          </template>
        </UPopover>        
      </template>
      <template #action-data="{ row }">
        <LocationModal
          :location="row"
          @update-location="onUpdateLocation"
        ></LocationModal>
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
    (e: 'newLocation', LocationInfo: LocationInfo): void,
    (e: 'updateLocation', LocationInfo: LocationInfo): void    
  }>()

  const onNewLocation = async (locationInfo: LocationInfo) => {
    emit('newLocation', locationInfo)
  }

  const onUpdateLocation = async (locationInfo: LocationInfo) => {
    emit('updateLocation', locationInfo)
  }

  watch(()=>selectedLocations.value, ()=>{
    emit('locationSelected', selectedLocations.value)
  })
  
  onMounted(()=>{
    selectedLocations.value = props.preSelected || []
  })
</script>
