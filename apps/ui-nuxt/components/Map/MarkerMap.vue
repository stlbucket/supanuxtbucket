<template>
  <div class="flex grow flex-col">
    <LMap
      ref="map"
      :zoom="zoom"
      :center="[47.608013, -122.335167]"
    >
      <LTileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution="&amp;copy; <a href=&quot;https://www.openstreetmap.org/&quot;>OpenStreetMap</a> contributors"
        layer-type="base"
        name="OpenStreetMap"
      />
      <l-marker :lat-lng="coordinates" draggable> </l-marker>
    </LMap>
  </div>
</template>

<script setup>
  import { ref } from 'vue'
  const zoom = ref(12)
  const coordinates = ref({})

  const loadData = async () => {
    const {data,error} = await useFetch('https://geocode.maps.co/search?street=1300+Elliot+Ave&city=Seattle&state=WA&postalcode=98119&country=US')

    if (error) {
      console.log(error)
    }
    const location = data.value[0]
    coordinates.value = [location.lat, location.lon]
    console.log(JSON.stringify(coordinates.value,null,2))
  }
  loadData()

</script>

<style>
body {
  margin: 0;
}
</style>
