<template>
  <UButton @click="showModal = true">{{ incident ? 'Edit' : 'New' }}</UButton>
  <UModal v-model="showModal">
    <UCard :ui="{ divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
      <template #header>
        Incident
      </template>
      <div class="flex flex-col gap-2">
        <UFormGroup name="name" label="Name">
          <UInput placeholder="name" v-model="formData.name" type="text" class="flex" data-1p-ignore/>
        </UFormGroup>
        <UFormGroup name="description" label="Description" class="min-h-[200px]">
          <UTextarea placeholder="description" v-model="formData.description" type="text" class="flex"/>
        </UFormGroup>
      </div>
      <template #footer>
        <div class="flex gap-1">
          <UButton @click="showModal = false">Cancel</UButton>
          <UButton @click="handleSave" :disabled="saveIncidentDisabled">Save</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    incident?: Incident
  }>()

  const showModal = ref(false)

  const formData: Ref<IncidentInfo> = ref({
    name: '',
    description: ''
  })

  onMounted(() => {
    formData.value = {
      name: props.incident?.name ?? '',
      description: props.incident?.description ?? ''
    }
  })

  const emit = defineEmits<{
    (e: 'new', IncidentInfo: IncidentInfo): void,
    (e: 'updated', IncidentInfo: IncidentInfo): void    
  }>()

  const handleSave = async () => {
    showModal.value = false
    if (props.incident) {
      emit('updated', {
        id: props.incident.id,
        ...formData.value
      } as IncidentInfo)
    } else {
      emit('new', formData.value)
    }
  }

  const saveIncidentDisabled = computed(() => {
    return (!formData.value.name) || (formData.value.name.length < 4)
  })
</script>