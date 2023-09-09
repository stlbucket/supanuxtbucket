<template>
  <div class="flex grow flex-col">
    <LMap
      ref="map"
      :zoom="zoom"
      :center="focusCenter"
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
          @update:latLng="onUpdateMarker"
        />
    </LMap>
  </div>
</template>

<script lang="ts" setup>
  // import { ref } from 'vue'
  const props = defineProps<{
    locations?: IncLocation[]
  }>()

  const zoom = ref(10)

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

  const focusCenter = computed(() => {
    if (locs.value.length > 0) {
      const lat = (locs.value.reduce((s,l) => { return s+l.coordinates[0]}, 0))/locs.value.length
      const lon = (locs.value.reduce((s,l) => { return s+l.coordinates[1]}, 0))/locs.value.length
      return [lat,lon]
    } else {
      return [47.6205131, -122.34930359883187]
    }
  })

  const onUpdateMarker = async(marker: any) => {
    console.log(JSON.stringify(marker,null,2))
  }
</script>

<style>
body {
  margin: 0;
}
.leaflet-container {
  z-index: 0 !important;
}
</style>
