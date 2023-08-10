<template>
  <div class="flex flex-col gap-1">
    <TodoTask
      v-for="t in todos" :todo="t"
      @updated="onUpdated"
      @subtask-added="onSubtaskAdded"
      @assigned="onAssigned"
      @deleted="onDeleted"
      @selected="onSelected"
    ></TodoTask>
  </div>
</template>

<script lang="ts" setup>
  export type TodoStatus = 'complete' | 'incomplete' | 'archived'
  export interface Props {
    status: TodoStatus,
    todos: any[]
  }
  const props = defineProps<Props>()

  const emit = defineEmits<{
    (e: 'updated', todo: Todo): void
    (e: 'subtaskAdded', todo: Todo, subTask: Todo): void
    (e: 'assigned', todo: Todo): void
    (e: 'selected', todoId: string): void
    (e: 'deleted'): void
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
  const onSelected = async (todoId: string) => {
    emit('selected', todoId)
  }

</script>