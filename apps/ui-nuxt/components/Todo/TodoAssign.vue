<template>
  <UButton icon="i-heroicons-user" size="2xs" square variant="outline" title="Close" @click="handleBeginAssign"/>
  <UModal v-model="showModal">
    <UCard :ui="{ divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
      <template #header>
        Assign Todo
      </template>
      <div class="flex flex-col gap-3">
        <UFormGroup name="assignedTo" label="Assigned to">
          <USelect v-model="assignedAppUserTenancyId" :options="appUserTenancies" option-attribute="name" />    
        </UFormGroup>
      </div>
      <template #footer>
        <div class="buttons">
          <UButton @click="showModal = false">Cancel</UButton>
          <UButton @click="handleSave">Save</UButton>
        </div>
      </template>
    </UCard>
  </UModal>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todo?: any
  }>()

  const showModal = ref(false)

  const assignedAppUserTenancyId = ref()

  const appUserTenancies = ref()

  const defaultFormData = {
    name: '',
    description: ''
  }
  const formData = ref(defaultFormData)

  onMounted(() => {
    formData.value = {
      name: props.todo?.name || '',
      description: props.todo?.description || ''
    }
  })

  const emit = defineEmits<{
    (e: 'assigned', appUserTenancyId: string): void
  }>()

  const handleBeginAssign = async () => {
    const result = await GqlAppTenantAppUserTenancies()
    appUserTenancies.value = result.appTenantAppUserTenancies.nodes.map(n => {
      return {
        name: n.displayName,
        value: n.id
      }
    })
    assignedAppUserTenancyId.value = props.todo.owner.id
    showModal.value = true
  }

  const handleSave = async () => {
    emit('assigned', assignedAppUserTenancyId.value)
    showModal.value = false
  }
</script>