<template>
  <div class="flex flex-col grow">
    <div>
      <UButton @click="onAddLocation">Add Location</UButton>
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
    locations: IncLocation[]
  }>()
  const selectedLocations = ref([])
  
  const emit = defineEmits<{
    (e: 'locationSelected', locations: IncLocation[]): void
  }>()

  const onAddLocation = async () => {
    alert('not implemented')
  }

  watch(()=>selectedLocations.value, ()=>{
    emit('locationSelected', selectedLocations.value)
  })
</script>


<!-- const {data,error} = await useFetch('https://geocode.maps.co/search?street=400+Broad+St&city=Seattle&state=WA&postalcode=98109&country=US') -->
