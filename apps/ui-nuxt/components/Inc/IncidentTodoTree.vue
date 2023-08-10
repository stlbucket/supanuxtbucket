<template>
  <div v-if="todoTree" class="flex flex-col grow">
    <div class="flex justify-start min-w-max border-2 rounded-md border-stone-400 grow ml-10">
      <div class="flex flex-col gap-3 align-items-center m-2 basis-1/10">
        <div class="flex gap-1">
          <div class="flex flex-col gap-1 w-30 p-1">
            <div class="flex justify-around gap-1">
              <UButton v-if="todoTree.status?.toUpperCase() === 'COMPLETE'" icon="i-heroicons-check" size="sm" color="green" square variant="solid" title="Reopen" @click="handleReopen" :disabled="!todoTree.canEdit"/>
              <UButton v-if="todoTree.status?.toUpperCase() === 'INCOMPLETE'" icon="none" size="sm" color="yellow" square variant="outline" title="Close" @click="handleClose" :disabled="!todoTree.canEdit"/>
            </div>
          </div>
        </div>
      </div>
      <div class="flex flex-1 flex-col m-2 flex-grow-2 gap-1">
        <div class="text-xl flex bg-cyan-950">
          <UButton
            class="flex grow"
            @click="handleSelectTodo(todoTree.id)"
            :color="primaryButtonColor"
          >{{ todoTree.type?.split('').at(0) }}: {{ todoTree.name }}</UButton>
        </div>
      </div>
    </div>
    <div v-if="todoTree.children?.length > 0" class="ml-3">
      <IncidentTodoTree 
        v-for="c in todoTree.children" 
        :todo-tree="c" 
        :tree-level="(treeLevel + 1)"
        @selected="handleSelectTodo"
        @updated="onUpdated"
      />
    </div>
  </div>
  <!-- <pre>{{ todoTree }}</pre> -->
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todoTree: any
    treeLevel: number
  }>()

  const emit = defineEmits<{
    (e: 'updated', todoId: string): void
    (e: 'selected', todoId: string): void
  }>()

  const handleClose = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todoTree.id,
      status: 'COMPLETE'
    })
    emit('updated', props.todoTree.id)
  }
  const handleReopen = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todoTree.id,
      status: 'INCOMPLETE'
    })
    emit('updated', props.todoTree.id)
  }
  const handleSelectTodo = async (todoId: string) => {
    emit('selected', todoId)
  }
  const onUpdated = async (todoId: string) => {
    emit('updated', todoId)
  }
  const primaryButtonColor = computed(()=>{
    switch (props.todoTree.type?.toUpperCase()) {
      case 'MILESTONE':
        return 'fuchsia'
      case 'TASK':
        return 'teal'
    }
    return `fuchsia`
  })
</script>