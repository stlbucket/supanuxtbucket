<template>
  <UCard v-if="incident">
    <template #header>
      <div class="flex gap-2">
        <div class="flex flex-col gap-1.5 max-w-[50%] min-w-[50%] min-h-[300px] max-h-[300px]">
          <div class="text-2xl">{{ incident.name }}</div>
          <UTabs 
            :items="tabItems" 
            :ui="{
              container: 'flex flex-col grow w-full',
              base: 'focus:outline-none flex flex-col grow',
              wrapper: 'flex flex-col grow space-y-2'
            }"
          >
            <template #detail="{ item }">
              <IncidentDetail
                :incident="incident"
                @close="onClose"
                @open="onOpen"
                @make-template="onMakeTemplate"
                @updated="onUpdateIncident"
                @clone-template="onCloneTemplate"
                @delete="onDelete"
              />
            </template>
            <template #locations="{ item }">
              <LocationList 
                :locations="incident.incLocations.map((l:any) => l.location)"
                @location-selected="onLocationSelected"
                :pre-selected="incident.incLocations.map((l:any) => l.location)"
              />
            </template>
            <template #attachments="{ item }">
              <p>ATTACHMENTS - documents, photos</p>
              <p>videos might be a stretch</p>
            </template>
          </UTabs>          
        </div>
        <div class="flex min-w-[30%] min-h-[300px] max-h-[300px] grow z-1">
          <MarkerMap 
            :locations="selectedLocations"
          />
        </div>
      </div>
    </template>
    <div class="flex grow">
      <div class="flex grow max-w-[50%] overflow-hidden flex-col">
        <MsgTopic
          class="flex grow"
          :topicId="incident.topic.id"
          title="Group Discussion"
        />
      </div>
      <div class="flex grow max-w-[50%] overflow-hidden flex-col">
        <UCard>
          <template #header>
            <div class="text-2xl">Tasks for this Incident</div>
          </template>
          <TodoTree 
            :todoId="incident.todo.id" 
            :treeLevel="0"
          />
        </UCard>
      </div>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const incident = ref()
  const selectedStatus = ref()
  const selectedLocations: Ref<IncLocation[]> = ref([])

  const tabItems = ref([
    {
      slot: 'detail',
      label: 'Detail',
    }, 
    {
      slot: 'locations',
      label: 'Locations',
    }, 
    {
      slot: 'attachments',
      label: 'Attachments',
    }
  ])
  
  const loadData = async () => {
    const result = await GqlIncidentById({
      incidentId: route.params.id,
    })
    incident.value = result.incident
    selectedStatus.value = incident.value.status
    selectedLocations.value = incident.value.incLocations.map((l: any) => l.location)
  }
  loadData()  

  const onClose = async () => {
    const result = await GqlUpdateIncidentStatus({
      incidentId: incident.value.id,
      status: 'CLOSED'
    })
    await loadData()
  }

  const onOpen = async () => {
    const result = await GqlUpdateIncidentStatus({
      incidentId: incident.value.id,
      status: 'OPEN'
    })
    await loadData()
  }

  const onUpdateIncident = async (incidentInfo: IncidentInfo) => {
    const result = await GqlUpdateIncident({
      incidentId: incidentInfo.id,
      name: incidentInfo.name,
      description: incidentInfo.description
    })
    await loadData()
  }

  const onMakeTemplate = async () => {
    const result = await GqlTemplatizeIncident({
      incidentId: incident.value.id
    })
    navigateTo(`/incidents/${result.templatizeIncident.incident.id}`)
  }

  const onCloneTemplate = async () => {
    const result = await GqlCloneIncidentTemplate({
      incidentId: incident.value.id
    })
    navigateTo(`/incidents/${result.cloneIncidentTemplate.incident.id}`)
  }

  const onDelete = async() => {
    const result = await GqlDeleteIncident({
      incidentId: incident.value.id
    })
    navigateTo('/incidents')
  }

  const onLocationSelected = async (locations: IncLocation[]) => {
    selectedLocations.value = locations
  }

</script>
