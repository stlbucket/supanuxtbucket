<template>
  <UButton @click="showModal = true">{{ location ? 'Edit' : 'New' }}</UButton>
  <UModal v-model="showModal">
    <UCard :ui="{ divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
      <template #header>
        Location
      </template>
      <div class="flex flex-col gap-">
        <UFormGroup name="name" label="Name">
          <UInput placeholder="name" v-model="formData.name" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="address1" label="Address 1">
          <UInput placeholder="address1" v-model="formData.address1" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="address2" label="Address 2">
          <UInput placeholder="address2" v-model="formData.address2" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="city" label="City">
          <UInput placeholder="city" v-model="formData.city" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="state" label="State">
          <UInput placeholder="state" v-model="formData.state" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="postalcode" label="Postal Code">
          <UInput placeholder="postalcode" v-model="formData.postalcode" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="country" label="Country">
          <UInput placeholder="country" v-model="formData.country" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="lat" label="Lat">
          <UInput placeholder="lat" v-model="formData.lat" type="text" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="lon" label="Lon">
          <UInput placeholder="lon" v-model="formData.lon" type="text" data-1p-ignore/>
        </UFormGroup>
      </div>
      <template #footer>
        <div class="flex gap-1">
          <UButton @click="showModal = false">Cancel</UButton>
          <UButton @click="handleSave" :disabled="saveLocationDisabled">Save</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    location?: ALocation
  }>()

  const showModal = ref(false)

  const formData: Ref<LocationInfo> = ref({
    id: undefined,
    name: '',
    address1: '',
    address2: '',
    city: '',
    state: '',
    postalcode: '',
    country: '',
    lat: '',
    lon: ''
  })

  onMounted(() => {
    if (props.location) {
      formData.value = {
      id: props.location.id,
      name: props.location.name,
      address1: props.location.address1,
      address2: props.location.address2,
      city: props.location.city,
      state: props.location.state,
      postalcode: props.location.postalcode,
      country: props.location.country,
      lat: props.location.lat,
      lon: props.location.lon
      } as unknown as LocationInfo
    }
  })

  const emit = defineEmits<{
    (e: 'new', LocationInfo: LocationInfo): void,
    (e: 'updated', LocationInfo: LocationInfo): void    
  }>()

  const handleSave = async () => {
    showModal.value = false
    if (props.location) {
      emit('updated', {
        id: props.location.id,
        ...formData.value
      } as LocationInfo)
    } else {
      emit('new', formData.value)
    }
  }

  const saveLocationDisabled = computed(() => {
    return false
    // return (!formData.value.name) || (formData.value.name.length < 4)
  })
</script>