<template>
  <div class="flex flex-col gap-1">
    <UCard>
    <template #header>
      <div class="flex justify-between">
        MY PROFILE
        <MyselfModal :appProfile="appProfile" v-if="appProfile" @updated="onUpdate"/>
      </div>
    </template>
    <div class="flex flex-col gap-3">
      <div v-for="df in dataFields" class="flex flex-col gap-1 border-2 rounded-md border-stone-400 p-2">
        <div class="text-xs">{{ df.label }}</div>
        <div :class="df.class">{{ df.value }}</div>
      </div>
    </div>
  </UCard>
  </div>
</template>

<script lang="ts" setup>
  const appProfile = ref()
  const loadData = async () => {
    const result = await GqlGetMyself()
    appProfile.value = result.getMyself
  }
  loadData()

  const onEdit = async () => {
    alert('not implemented')
  }

  const dataFields = computed(() => {
    return [
    {
        label: 'Email',
        value: appProfile.value?.email,
        class: ''
      },
      {
        label: 'Display Name',
        value: appProfile.value?.displayName,
        class: ''
      },
      {
        label: 'First Name',
        value: appProfile.value?.firstName || 'not specified',
        class: appProfile.value?.firstName ? '' : 'italic'
      },
      {
        label: 'Last Name',
        value: appProfile.value?.lastName || 'not specified',
        class: appProfile.value?.lastName ? '' : 'italic'
      },
      {
        label: 'Phone',
        value: appProfile.value?.phone || 'not specified',
        class: appProfile.value?.phone ? '' : 'italic'
      },
    ]
  })

  const onUpdate = async (appProfile: AppProfile) => {
    const result = await GqlUpdateProfile({
      displayName: appProfile.displayName,
      firstName: appProfile.firstName,
      lastName: appProfile.lastName,
      phone: appProfile.phone
    })
    await loadData()
  }
</script>
