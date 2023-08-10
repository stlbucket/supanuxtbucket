<template>
  <UButton @click="showModal = true">New</UButton>
  <UModal v-model="showModal">
    <UCard :ui="{ divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
      <template #header>
        Invite a new user
      </template>
      <div class="flex flex-col gap-2">
        <UFormGroup name="email" label="Email">
          <UInput placeholder="email" v-model="formData.email" type="email" class="flex"/>
        </UFormGroup>
      </div>
      <template #footer>
        <div class="buttons">
          <UButton @click="showModal = false">Cancel</UButton>
          <UButton @click="handleSave" :disabled="saveAppUserTenancyDisabled">Save</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()

  const showModal = ref(false)

  const formData = ref({
    email: ''
  })

  onMounted(() => {
    formData.value = {
      email: ''
    }
  })

  const emit = defineEmits<{
    (e: 'newAppUserTenancy', email: string): void
  }>()

  const handleSave = async () => {
    showModal.value = false
    emit('newAppUserTenancy', formData.value.email)
  }

  const saveAppUserTenancyDisabled = computed(() => {
    return false
    // return (!formData.value.name) || (formData.value.name.length < 4)
  })
</script>