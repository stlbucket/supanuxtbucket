<template>
  <UCard>
    <template #header>
      <div>APPLICATIONS</div>
    </template>
    <div class="flex flex-col gap-3">
        <Application v-for="a in applications" :application="a" />
      </div>
  </UCard>  
</template>

<script lang="ts" setup>
  // import { Application } from 'types'

  // const applications: Ref<Application[]> = ref([])
    const applications = ref([])

  const loadData = async () => {
    const result = await GqlAllApplications()
    applications.value = result.applications.nodes
  }
  loadData()

</script>
