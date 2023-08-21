<template>
  <UButton @click="showModal = true">New</UButton>
  <UModal v-model="showModal">
    <UCard :ui="{ divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
      <template #header>
        Edit App Tenant
      </template>
      <div class="flex flex-col gap-2">
        <UFormGroup name="name" label="Name">
          <UInput placeholder="name" v-model="formData.name" type="text" class="flex"/>
        </UFormGroup>
        <UFormGroup name="email" label="Admin Email">
          <UInput placeholder="admin email" v-model="formData.email" type="text" class="flex"/>
        </UFormGroup>
      </div>
      <template #footer>
        <div class="buttons">
          <UButton @click="showModal = false">Cancel</UButton>
          <UButton @click="handleSave" :disabled="saveTenantDisabled">Save</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script lang="ts" setup>
  const props = defineProps<{
  }>()

  const showModal = ref(false)

  const formData: Ref<NewTenantInfo> = ref({
    name: '',
    email: ''
  })

  onMounted(() => {
    formData.value = {
      name: '',
      email: ''
    }
  })

  const emit = defineEmits<{
    (e: 'new', newTenantInfo: NewTenantInfo): void
  }>()

  const handleSave = async () => {
    showModal.value = false
    emit('new', formData.value)
  }

  const saveTenantDisabled = computed(() => {
    return (!formData.value.name) || (formData.value.name.length < 4)
  })
</script>