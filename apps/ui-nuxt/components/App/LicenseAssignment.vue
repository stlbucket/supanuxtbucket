<template>
  <UCard>
    <template #header>
      <div class="text-2xl">{{ licensePack.displayName }}
    </div></template>
    <div class="flex min-w-full justify-around">
      <UCard :ui="{
        base: 'flex flex-col min-w-[40%]',
        header: {
          base: 'flex grow',
          // background: ' bg-blue-600',
        },
        body: {
          // background: 'bg-blue-400'
        }
      }">
        <template #header>
          <div class="flex flex-col gap-2">
            <div class="text-xl">Scoped Licenses</div>
            <div v-if="userIsUser" class="text-sm">User cannot change own scoped licenses</div>
          </div>
        </template>
        <div class="flex flex-col gap-3 grow">
          <URadio v-for="l of scopedChoices" :key="l.name" v-model="selectedScoped" v-bind="l" :disabled="userIsUser || selectedScoped === l.value" @click="onScopedLicenseChange(l.value)"/>
        </div>
      </UCard>
      <UCard :ui="{
        base: 'flex flex-col min-w-[40%]',
        header: {
          // background: ' bg-blue-600'
        },
        body: {
          base: 'flex grow',
          // background: 'bg-blue-400'
        }
      }">
        <template #header>
          <div class="flex flex-col gap-2">
            <div class="text-xl">Unscoped Licenses</div>
            <div v-if="userIsUser" class="text-sm">User can change own unscoped licenses</div>
          </div>
        </template>
        <div class="flex flex-col gap-2 grow">
          <UCheckbox v-for="l of unscopedChoices" :key="l.name" v-model="selectedUnscoped[l.value]" v-bind="l"  @click="onUnscopedLicenseChange(l)"/>
        </div>
      </UCard>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const emit = defineEmits<{
    (e: 'grantLicense', licenseTypeKey: string): void
    (e: 'revokeLicense', license: any): void
  }>()

  const props = defineProps<{
    licensePack: any,
    appUserTenancy: any
  }>()

  const selectedScoped = ref()
  const selectedUnscoped: Ref<any> = ref({})

  const scopedChoices: Ref<{
    name: string
    value: string
    label: string
  }[]> = ref([])

  const unscopedChoices: Ref<{
    name: string
    value: string
    label: string
  }[]> = ref([])

  const prepareChoices = () => {
    scopedChoices.value = props.licensePack.licenseTypes
      .filter((lt: any) => ['ALL', 'NONE'].indexOf(lt.licenseType.assignmentScope) === -1)
      .map((lt: any) => {
        return {
          name: lt.licenseTypeKey,
          value: lt.licenseTypeKey,
          label: lt.licenseTypeKey        
        }
      })
    const scopedLicenseTypeKeys = scopedChoices.value.map(sc => sc.value)
    selectedScoped.value = props.appUserTenancy.licenses.find((l: any) => scopedLicenseTypeKeys.indexOf(l.licenseTypeKey) > -1)?.licenseTypeKey

    unscopedChoices.value = props.licensePack.licenseTypes
      .filter((lt: any) => ['ALL', 'NONE'].indexOf(lt.licenseType.assignmentScope) > -1)
      .map((lt: any) => {
        return {
          name: lt.licenseTypeKey,
          value: lt.licenseTypeKey,
          label: lt.licenseTypeKey        
        }
      })
    selectedUnscoped.value = unscopedChoices.value.reduce(
      (a, c) => {
        const license = props.appUserTenancy.licenses.find((l: any) => l.licenseTypeKey === c.value)
        return {
          ...a,
          [c.value]: !!license
        }
      }, {}
    )
  }
  onMounted(() => {
    prepareChoices()
  })

  const onUnscopedLicenseChange = async (licenseTypeInfo: any) => {
    const existingLicense = props.appUserTenancy.licenses.find((l:any) => l.licenseTypeKey === licenseTypeInfo.value)
    if (existingLicense) {
      emit('revokeLicense', existingLicense)
    } else {
      emit('grantLicense', licenseTypeInfo.value)
    }
  }

  const onScopedLicenseChange = async (licenseTypeKey: any) => {
    emit('grantLicense', licenseTypeKey)
  }

  const userIsUser = computed(() => {
    return user.value?.user_metadata.app_user_tenancy_id === props.appUserTenancy.id
  })
</script>