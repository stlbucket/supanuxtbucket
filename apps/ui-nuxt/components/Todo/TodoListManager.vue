<template>
  <div class="flex justify-stretch grow gap-1 mt-3">
    <div class="flex flex-col gap-1 grow overflow-hidden">
      <div class="text-xl">INCOMPLETE SUBTASKS</div>
      <TodoList
        status="incomplete"
        :todos="incompleteTodos"
        @updated="onUpdated"
        @subtask-added="onSubtaskAdded"
        @assigned="onAssigned"
        @deleted="onDeleted"
        @selected="onTodoSelected"
      />
    </div>
    <div v-if="!hideCompleted" class="flex flex-col gap-1 grow max-w-[50%] overflow-hidden">
      <div class="text-xl">COMPLETE SUBTASKS</div>
      <TodoList
        status="complete"
        :todos="completeTodos"
        @updated="onUpdated"
        @subtask-added="onSubtaskAdded"
        @assigned="onAssigned"
        @deleted="onDeleted"
        @selected="onTodoSelected"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todo: Todo
    hideCompleted?: boolean
  }>()

  const incompleteTodos = ref([])
  const completeTodos = ref([])

  const sortTodos = async () => {
    if (props.todo) {
      incompleteTodos.value = props.todo.children.filter((t:any) => t.status === 'INCOMPLETE')
      completeTodos.value = props.todo.children.filter((t:any) => t.status === 'COMPLETE')
    }
  }
  sortTodos()
  watch(() => props.todo, async () => {
    await sortTodos()
  })

  const emit = defineEmits<{
    (e: 'updated', todo: Todo): void
    (e: 'subtaskAdded', todo: Todo, subTask: Todo): void
    (e: 'assigned', todo: Todo): void
    (e: 'deleted'): void
    (e: 'selected', todoId: string): void
  }>()
  const onUpdated = async (todo:any) => {
    emit('updated', todo)
  }
  const onSubtaskAdded = async (todo:any, subTask:any) => {
    emit('subtaskAdded', todo, subTask)
  }
  const onAssigned = async (todo:any) => {
    emit('assigned', todo)
  }
  const onDeleted = async () => {
    emit('deleted')
  }
  const onTodoSelected = async (todoId: string) => {
    emit('selected', todoId)
  }
</script>