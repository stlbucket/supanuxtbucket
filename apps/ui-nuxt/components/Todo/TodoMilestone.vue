<template>
    <div class="text-xl flex gap-1">
      <UButton
          v-if="String(todoTree.status) === 'COMPLETE'" 
          icon="i-heroicons-check"
          size="xs"
          color="green"
          title="Reopen"
          @click="onReopened"
          disabled
        />
        <UButton
          v-if="String(todoTree.status) === 'INCOMPLETE'"
          size="xs"
          color="yellow"
          title="Close"
          @click="onClosed"
          disabled
        >{{ completionRatio }}</UButton>
        <UButton 
          :icon="expansionIcon"
          size="xs"
          color="white" 
          square 
          variant="solid" 
          :title="expansionTitle" 
          @click="onToggleExpansion"
        />
        <UButton 
          v-if="!expanded"
          icon="i-heroicons-chevron-double-down"
          size="xs"
          color="white" 
          square 
          variant="solid" 
          title="Expand All Children"
          @click="onExpandAllChildren"
        />
        <UButton
          class="flex grow"
          @click="onSelected"
          color="white"
          :title="todoTree.description"
        >{{ todoTree.name }}</UButton>
      </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todoTree: Todo
    expanded: boolean
  }>()

  const emit = defineEmits<{
    (e: 'selected', todo: Todo): void
    (e: 'toggleExpansion', todo: Todo): void
    (e: 'expandAllChildren', todo: Todo): void
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

  const onToggleExpansion = async () => {
    emit('toggleExpansion', props.todoTree)
  }

  const onExpandAllChildren = async () => {
    emit('expandAllChildren', props.todoTree)
  }


  const expansionTitle = computed(() => {
    return `${props.expanded ? 'Collapse' : 'Expand'}`
  })
  const expansionIcon = computed(() => {
    return `${props.expanded ? 'i-heroicons-chevron-up' : 'i-heroicons-chevron-down'}`
  })
  const completionRatio = computed(() => {
    const complete = (props.todoTree.children || []).filter((t:Todo) => t.status.toString().toUpperCase() === 'COMPLETE').length
    const totalCount = (props.todoTree.children || []).length
    return `${complete}/${totalCount}`
  })

</script>