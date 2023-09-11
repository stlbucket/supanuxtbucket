<template>
  <UCard v-if="incident">
    <template #header>
      <div class="flex gap-5">
        <div class="text-2xl">THIS IS HAPPENING:</div>
        <div class="text-2xl">{{ incident.name }}</div>
      </div>
    </template>
    <UCard>
      <div class="flex gap-2">
        <div class="flex flex-col gap-1.5 max-w-[50%] min-w-[50%] min-h-[300px] max-h-[300px]">
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
                :locations="[incident.location]"
                :pre-selected="[incident.location]"
                @location-selected="onLocationSelected"
                @update-location="onUpdateLocation"
                @new-location="onNewLocation"
                :show-headers="false"
                :show-new="false"
                :show-delete="false"
              />
            </template>
            <template #attachments="{ item }">
              <p>ATTACHMENTS - documents, photos</p>
              <p>videos might be a stretch</p>
              <hr>
              <a target="_blank" href="https://supabase.com/docs/guides/storage">Supabase Storage Guide</a>
            </template>
          </UTabs>          
        </div>
        <div class="flex min-w-[30%] min-h-[300px] max-h-[300px] grow z-1">
          <MarkerMap 
            :locations="selectedLocations"
          />
        </div>
      </div>        
    </UCard>
    <div class="flex grow">
        <div class="flex grow max-w-[50%] overflow-hidden flex-col">
          <UCard>
            <MsgTopic
              class="flex grow"
              :topicId="incident.topic.id"
              title="GROUP DISCUSSION"
            />
          </UCard>
        </div>
        <div class="flex grow max-w-[50%] overflow-hidden flex-col">
          <UCard>
            <UCard>
              <template #header>
                <div class="text-2xl flex justify-center">TASKS</div>
              </template>
              <TodoTree 
                :todoId="incident.todo.id" 
                :treeLevel="0"
              />
            </UCard>
          </UCard>
        </div>      
      </div>
  </UCard>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const incident = ref()
  const selectedStatus = ref()
  const selectedLocations: Ref<ALocation[]> = ref([])

  const tabItems = ref([
    {
      slot: 'detail',
      label: 'DETAIL',
    }, 
    {
      slot: 'locations',
      label: 'LOCATIONS',
    }, 
    {
      slot: 'attachments',
      label: 'ATTACHMENTS',
    }
  ])
  
  const loadData = async () => {
    const result = await GqlIncidentById({
      incidentId: route.params.id,
    })
    incident.value = result.incident
    selectedStatus.value = incident.value.status
    selectedLocations.value = [incident.value.location]
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

  const onLocationSelected = async (locations: ALocation[]) => {
    selectedLocations.value = locations
  }
  const onNewLocation = async(locationInfo: LocationInfo) => {
    const result = await GqlCreateLocation({
      locationInfo: locationInfo
    })
    await loadData()
  }
  const onUpdateLocation = async(locationInfo: LocationInfo) => {
    const result = await GqlUpdateLocation({
      locationInfo: locationInfo
    })
    await loadData()
  }

</script>
