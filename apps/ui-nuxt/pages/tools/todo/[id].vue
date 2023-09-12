<template>
  <UCard v-if="todoTree">
    <template #header>
      <div class="flex justify-between">
        <div class="flex gap-5">
          <div class="text-2xl">THIS IS HAPPENING:</div>
          <div class="text-2xl">{{ todoTree.name }}</div>
        </div>
        <div class="flex gap-5">
          <NuxtLink v-if="todoTree.parentTodoId" :to="`/tools/todo/${todoTree.parentTodoId}`">To Parent</NuxtLink>
          <NuxtLink v-if="todoTree.rootTodoId" :to="`/tools/todo/${todoTree.rootTodoId}`">Back to Project</NuxtLink>
        </div>
      </div>
    </template>
    <UCard>
      <div class="flex gap-2">
        <div class="flex max-w-[50%] min-w-[50%]">
          <UTabs 
            :items="tabItems" 
            :ui="{
              container: 'flex flex-col grow w-full',
              base: 'focus:outline-none flex flex-col grow',
              wrapper: 'flex flex-col grow space-y-2'
            }"
          >
            <template #detail="{ item }">
              <div class="flex flex-col gap-2">
                <TodoDetail
                  :todo="todoTree"
                  @make-template="onMakeTemplate"
                  @clone-template="onCloneTemplate"
                  @delete="onDelete"
                />
                <MsgTopic
                  class="flex grow"
                  :topicId="todoTree.topicId"
                  title="GROUP DISCUSSION"
                />
              </div>
            </template>
            <template #map="{ item }">
              <div class="flex flex-col gap-2 grow min-h-[600px]">
                <UCard>
                  <template #header>
                    <div>LOCATIONS</div>
                  </template>
                  <LocationList 
                    :locations="todoTree.location ? [todoTree.location] : []"
                    :pre-selected="todoTree.location ? [todoTree.location] : []"
                    @location-selected="onLocationSelected"
                    @update-location="onUpdateLocation"
                    :show-new="false"
                    :show-delete="false"
                    :show-headers="false"
                  />
                </UCard>
                <div class="flex grow">
                  <MarkerMap 
                    :locations="selectedLocations"
                  />
                </div>
              </div>
            </template>
          </UTabs>          
        </div>
        <div class="flex grow flex-col gap-2">
          <!-- <UCard>
            <template #header>
              <div>LOCATIONS</div>
            </template>
            <LocationList 
              :locations="todoTree.location ? [todoTree.location] : []"
              :pre-selected="todoTree.location ? [todoTree.location] : []"
              @location-selected="onLocationSelected"
              @update-location="onUpdateLocation"
              :show-new="false"
              :show-delete="false"
            />
          </UCard> -->
          <UTable
            :rows="[]"
            :ui="{
              thead: 'hidden'
            }"
          >
            <template #empty-state>
              <UCard>
                <template #header>
                  <div>ATTACHMENTS</div>
                </template>
                <div class="flex justify-between">
                  <UButton label="Add an attachment" @click="onAddAttachment" />
                  <div class="text-xs"><a target="_blank" href="https://supabase.com/docs/guides/storage">Supabase Storage Guide</a></div>
                </div>
              </UCard>
            </template>
          </UTable>
          <UCard>
            <template #header>
              <div class="text-2xl flex justify-center">TASKS</div>
            </template>
            <TodoTree 
              :todo-id="todoTree.id"
              :tree-level="0"
            />
          </UCard>
        </div>      
      </div>        
    </UCard>
  </UCard>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const todoTree = ref()
  const selectedLocations: Ref<ALocation[]> = ref([])

  const loadData = async () => {
    const result = await GqlTodoById({
      id: route.params.id
    })
    todoTree.value = result.todo
  }
  loadData()

  const tabItems = ref([
    {
      slot: 'detail',
      label: 'DETAIL',
    }, 
    {
      slot: 'map',
      label: 'MAP',
    }, 
    // {
    //   slot: 'attachments',
    //   label: 'ATTACHMENTS',
    // }
  ])

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

  const onMakeTemplate = async () => {
    // const result = await GqlTemplatizeIncident({
    //   incidentId: incident.value.id
    // })
    // navigateTo(`/incidents/${result.templatizeIncident.incident.id}`)
  }

  const onCloneTemplate = async () => {
    // const result = await GqlCloneIncidentTemplate({
    //   incidentId: incident.value.id
    // })
    // navigateTo(`/incidents/${result.cloneIncidentTemplate.incident.id}`)
  }

  const onDelete = async() => {
    // const result = await GqlDeleteIncident({
    //   incidentId: incident.value.id
    // })
    // navigateTo('/incidents')
  }
  const onAddAttachment = async () => {
    alert('NOT IMPLEMENTED')
  }

</script>
