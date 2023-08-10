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
          <UButton @click="handleSave" :disabled="saveAppTenantDisabled">Save</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    appTenant?: any
  }>()

  const showModal = ref(false)

  const formData = ref({
    name: '',
    email: ''
  })

  onMounted(() => {
    formData.value = {
      name: props.appTenant?.name || '',
      email: props.appTenant?.email || ''
    }
  })

  const emit = defineEmits<{
    (e: 'new', appTenant: AppTenant): void
    (e: 'updated', appTenant: AppTenant): void
  }>()

  const handleSave = async () => {
    showModal.value = false
    emit('updated', {
      ...props.appTenant,
      ...formData.value
    })
  }

  const saveAppTenantDisabled = computed(() => {
    return (!formData.value.name) || (formData.value.name.length < 4)
  })
</script>