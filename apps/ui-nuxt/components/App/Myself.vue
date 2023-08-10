<template>
  <div class="flex flex-col gap-1">
    <UCard>
    <template #header>
      <div class="flex justify-between">
        MY PROFILE
        <MyselfModal :appUser="appUser" v-if="appUser" @updated="onUpdate"/>
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
  const appUser = ref()
  const loadData = async () => {
    const result = await GqlGetMyself()
    appUser.value = result.getMyself
  }
  loadData()

  const onEdit = async () => {
    alert('not implemented')
  }

  const dataFields = computed(() => {
    return [
    {
        label: 'Email',
        value: appUser.value?.email,
        class: ''
      },
      {
        label: 'Display Name',
        value: appUser.value?.displayName,
        class: ''
      },
      {
        label: 'First Name',
        value: appUser.value?.firstName || 'not specified',
        class: appUser.value?.firstName ? '' : 'italic'
      },
      {
        label: 'Last Name',
        value: appUser.value?.lastName || 'not specified',
        class: appUser.value?.lastName ? '' : 'italic'
      },
      {
        label: 'Phone',
        value: appUser.value?.phone || 'not specified',
        class: appUser.value?.phone ? '' : 'italic'
      },
    ]
  })

  const onUpdate = async (appUser: AppUser) => {
    const result = await GqlUpdateProfile({
      displayName: appUser.displayName,
      firstName: appUser.firstName,
      lastName: appUser.lastName,
      phone: appUser.phone
    })
    await loadData()
  }
</script>
