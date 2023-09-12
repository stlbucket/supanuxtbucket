<template>
  <div class="flex flex-col">
    <div>
      <LocationModal
        @new-location="onNewLocation"
        v-if="showNew"
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
      :ui="{
        thead: `${showHeaders ? '' : 'hidden'}`
      }"
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
        <UButton
          v-if="showDelete"
          @click="onDeleteLocation(row)"
        >Delete</UButton>
      </template>
    </UTable>
  </div>
</template>

<script lang="ts" setup>
  const props = withDefaults(defineProps<{
    locations: ALocation[],
    preSelected: ALocation[],
    showHeaders?: boolean,
    showNew?: boolean,
    showDelete?: boolean
  }>(), {
    showHeaders: true,
    showNew: true,
    showDelete: true
  })
  const selectedLocations: Ref<ALocation[]> = ref([])
  
  const emit = defineEmits<{
    (e: 'locationSelected', locations: ALocation[]): void
    (e: 'newLocation', LocationInfo: LocationInfo): void,
    (e: 'updateLocation', LocationInfo: LocationInfo): void    
    (e: 'deleteLocation', LocationInfo: LocationInfo): void        
  }>()

  const onNewLocation = async (locationInfo: LocationInfo) => {
    emit('newLocation', locationInfo)
  }

  const onUpdateLocation = async (locationInfo: LocationInfo) => {
    emit('updateLocation', locationInfo)
  }

  const onDeleteLocation = async (locationInfo: LocationInfo) => {
    const result = confirm('Are you sure you want to delete?')
    
    emit('updateLocation', locationInfo)
  }

  watch(()=>selectedLocations.value, ()=>{
    emit('locationSelected', selectedLocations.value)
  })
  
  onMounted(()=>{
    selectedLocations.value = props.preSelected || []
  })
</script>
