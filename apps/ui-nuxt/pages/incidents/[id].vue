<template>
  <UCard v-if="incident">
    <template #header>
      <div class="flex gap-2">
        <div class="flex flex-col gap-1.5 max-w-[50%] min-w-[50%]">
          <div class="text-2xl">{{ incident.name }}</div>
          <div class="flex justify-start gap-5">
            <div class="flex">
              <IncidentModal
                :incident="incident"
                @updated="onUpdateIncident"
              />
            </div>
            <div class="flex">
              <UButton v-if="incident.status === 'OPEN'" color="green" @click="onClose">Close</UButton>
              <UButton v-if="incident.status === 'CLOSED'" color="yellow" @click="onOpen">Reopen</UButton>
            </div>
          </div>
          <div class="flex grow">
            <UTextarea
              v-model="incident.description"
              disabled
              :ui="{
                wrapper: 'flex grow'
              }"
            />
          </div>
        </div>
        <div class="flex min-w-[30%] min-h-[300px] max-h-[300px] grow z-1">
          <MarkerMap />
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
  
  const loadData = async () => {
    const result = await GqlIncidentById({
      incidentId: route.params.id,
    })
    incident.value = result.incident
    selectedStatus.value = incident.value.status
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
  </script>
