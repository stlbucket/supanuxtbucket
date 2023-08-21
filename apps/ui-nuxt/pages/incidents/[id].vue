<template>
  <UCard v-if="incident">
    <template #header>
      <div class="flex justify-between">
        <div class="flex flex-col gap-1.5">
          <div class="text-3xl">{{ incident.name }}</div>
          <div class="text-xl">{{ incident.description }}</div>
        </div>
        <div class="flex justify-start gap-5">
          <div class="flex flex-col gap-1 bg-cyan-700 p-3">
            <div class="flex text-xs">Status</div>
            <div class="flex">{{ incident.status }}</div>
          </div>
        </div>
      </div>
    </template>
    <div class="flex">
      <div class="flex grow max-w-[50%] overflow-hidden">
        <MsgTopic
          :topicId="incident.topic.id"
          title="Group Discussion"
        />
      </div>
      <div class="flex grow max-w-[50%] overflow-hidden">
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
  
  const loadData = async () => {
    const result = await GqlIncidentById({
      incidentId: route.params.id,
    })
    incident.value = result.incident
  }
  loadData()  
  </script>
