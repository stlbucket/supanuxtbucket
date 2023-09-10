<template>
    <div class="text-xl flex gap-1">
      <UButton 
        v-if="String(todoTree.type) === 'TASK' && String(todoTree.status) === 'COMPLETE'"
        icon="i-heroicons-check"
        size="xs"
        title="Reopen"
        @click="onReopened"
      />
      <UButton
        v-if="String(todoTree.type) === 'TASK' && String(todoTree.status) === 'INCOMPLETE'"
        icon="none"
        size="xs"
        color="yellow"
        :title="Boolean(todoTree.isTemplate) ? 'This is a template so no action can be taken' : 'Close'"
        @click="onClosed"
        :disabled="Boolean(todoTree.isTemplate)"
      />
      <UButton
        class="flex grow"
        @click="onSelected"
        color="black"
        :title="todoTree.description"
      >{{ todoTree.name }}</UButton>
    </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todoTree: Todo
  }>()

  const emit = defineEmits<{
    (e: 'reopened', todo: Todo): void
    (e: 'closed', todo: Todo): void
    (e: 'selected', todo: Todo): void
  }>()

  const onReopened = async () => {
    emit('reopened', props.todoTree)
  }

  const onClosed = async () => {
    emit('closed', props.todoTree)
  }

  const onSelected = async () => {
    emit('selected', props.todoTree)
  }

</script>