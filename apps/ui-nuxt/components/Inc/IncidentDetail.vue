<template>
  <div class="flex flex-col grow p-2 gap-2">
    <div class="flex justify-between">
      <div class="flex justify-start gap-10">
        <div class="flex gap-2">
          <IncidentModal
            :incident="incident"
            @updated="onUpdated"
          />
          <UButton color="red" @click="onDelete">Delete</UButton>                
        </div>
        <div class="flex" v-if="!incident.isTemplate">
          <UButton v-if="String(incident.status) === 'OPEN'" color="yellow" @click="onClose">Close</UButton>
          <UButton v-if="String(incident.status) === 'CLOSED'" color="yellow" @click="onOpen">Reopen</UButton>
        </div>
      </div>
      <div class="flex" v-if="!incident.isTemplate">
        <UButton color="blue" @click="onMakeTemplate" v-if="showMakeTemplate">Make Template</UButton>
      </div>
      <div class="flex" v-if="incident.isTemplate">
        <UButton color="blue" @click="onNewIncident">New Incident</UButton>
      </div>
    </div>
    <div class="flex grow">
      <UTextarea
        :model-value="description"
        disabled
        :ui="{
          wrapper: 'flex grow'
        }"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const props = defineProps<{
    incident: Incident
  }>()

  const emit = defineEmits<{
    (e: 'updated', incidentInfo: IncidentInfo): void
    (e: 'open'): void
    (e: 'close'): void
    (e: 'delete'): void
    (e: 'makeTemplate'): void,
    (e: 'cloneTemplate'): void
  }>()

  const description = computed((): string => {
    return props.incident.description ?? ''
  })

  const onUpdated = async(incidentInfo: IncidentInfo) => {
    emit('updated', incidentInfo)
  }

  const onOpen = async () => {
    emit('open')
  }

  const onClose = async () => {
    emit('close')
  }

  const onDelete = async () => {
    emit('delete')
  }

  const onMakeTemplate = async () => {
    emit('makeTemplate')
  }

  const onNewIncident = async () => {
    emit('cloneTemplate')
  }

  const showMakeTemplate = computed(() => {
    return useHasPermission(user, 'p:incidents-admin')
  })
</script>