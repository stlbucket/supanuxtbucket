<template>
  <UCard v-if="siteUser">
    <template #header>
    </template>
    <div class="flex justify-around">
      <UCard>
        <template #header>
          USER EMAIL
        </template>
        <pre class="flex">{{ JSON.stringify(residencies,null,2) }}</pre>
      </UCard>
      <UCard>
        <template #header>
          RAW USER META DATA (user claims)
        </template>
        <pre class="flex">{{ JSON.stringify(siteUser.raw_user_meta_data,null,2) }}</pre>
      </UCard>
    </div>
  </UCard>
  <UCard>
    <template #header>
      ALL USER DATA (from auth provider)
    </template>
    <pre class="flex">{{ JSON.stringify(siteUser,null,2) }}</pre>
  </UCard>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const siteUser = ref()
  const residencies = ref([])
  
  const loadData = async () => {
    const result = await GqlSiteUserById({
      id: route.params.id,
    })
    siteUser.value = result.siteUserById.authUser
    residencies.value = result.siteUserById.residencies
  }
  loadData()  

</script>