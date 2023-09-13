<template>
  <div class="flex flex-col gap-3 grow">
    <div class="flex grow" v-for="ab in abUsers">
      <div class="flex flex-col gap-1 grow">
        <div class="flex">
          {{ ab.displayName }}
        </div>
        <div class="flex justify-end">
          {{ ab.email }}
        </div>
        <div class="flex justify-end">
          <UButton @click="onInvite(ab.email)" :disabled="!ab.canInvite" title="Admin users can send invitations to users not yet in their organization.">Invite</UButton>
        </div>
      </div>
    </div>
  </div>
    <!-- <UTable
      v-if="abUsers.length"
      :rows="abUsers"
      :columns="[
        {key: 'action'},
        {key: 'email', label: 'Email', sortable: true},
        {key: 'name', label: 'Name', sortable: true},
        {key: 'phone', label: 'Phone', sortable: true},
      ]"
      :sort="{ column: 'name', direction: 'asc' }"
    >
      <template #action-data="{ row }">
        <UButton @click="onInvite(row.email)" :disabled="!row.canInvite" title="Admin users can send invitations to users not yet in their organization.">Invite</UButton>
      </template>
      <template #name-data="{ row }">
        {{ row.fullName }}
      </template>
    </UTable> -->
</template>

<script lang="ts" setup>
  const props = defineProps<{
    abUsers: any[]
  }>()
  const emit = defineEmits<{
    (e: 'invite', email: string): void
  }>()

  const onInvite = async (email: string) => {
    emit('invite', email)
  }
</script>
