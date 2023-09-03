<template>
  <div class="flex grow flex-col">
    <LMap
      ref="map"
      :zoom="zoom"
      :center="[47.6205131, -122.34930359883187]"
    >
      <LTileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution="&amp;copy; <a href=&quot;https://www.openstreetmap.org/&quot;>OpenStreetMap</a> contributors"
        layer-type="base"
        name="OpenStreetMap"
      />
        <l-marker v-for="l in locs" 
          :lat-lng="l.coordinates" 
          draggable
        />
    </LMap>
  </div>
</template>

<script lang="ts" setup>
  // import { ref } from 'vue'
  const props = defineProps<{
    locations?: IncLocation[]
  }>()

  const zoom = ref(12)
  // const coordinates = ref({})

  // const loadData = async () => {
  //   const {data,error} = await useFetch('https://geocode.maps.co/search?street=400+Broad+St&city=Seattle&state=WA&postalcode=98109&country=US')

  //   if (error) {
  //     console.log(error)
  //   }
  //   const location = data.value[0]
  //   coordinates.value = [location.lat, location.lon]
  //   console.log(JSON.stringify(coordinates.value,null,2))
  // }
  // loadData()

  const locs = computed(() => {
    return (props.locations || []).map(l => {
      return {
        ...l,
        coordinates: [Number(l.lat), Number(l.lon)]
      }
    })
  })

  onMounted(()=> {
    console.log(JSON.stringify(locs.value,null,2))
  })
</script>

<style>
body {
  margin: 0;
}
.leaflet-container {
  z-index: 0 !important;
}
</style>
