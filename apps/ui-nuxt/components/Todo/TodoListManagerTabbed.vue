<template>
  <div class="flex justify-stretch grow gap-1 mt-3">
    <div class="flex flex-col gap-1 grow overflow-hidden">
      <UTabs
        :items="tabItems"
      >
        <template #default="{item}">
          {{ item.label }}
        </template>
        <template #incomplete="{item}">
          <TodoList
            v-if="incompleteTodos.length > 0"
            status="incomplete"
            :todos="incompleteTodos"
            @updated="onUpdated"
            @subtask-added="onSubtaskAdded"
            @assigned="onAssigned"
            @deleted="onDeleted"
            @selected="onTodoSelected"
          />
          <div v-else>NO INCOMPLETE SUBTASKS</div>
        </template>
        <template #complete="{item}">
          <TodoList
            v-if="completeTodos.length > 0"
            status="complete"
            :todos="completeTodos"
            @updated="onUpdated"
            @subtask-added="onSubtaskAdded"
            @assigned="onAssigned"
            @deleted="onDeleted"
            @selected="onTodoSelected"
          />
          <div v-else>NO COMPLETE SUBTASKS</div>
        </template>
      </UTabs>
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todo: Todo
  }>()

  const incompleteTodos = ref([])
  const completeTodos = ref([])

  const tabItems = [
    {
      slot: 'incomplete',
      label: 'Incomplete'
    },
    {
      slot: 'complete',
      label: 'Complete'
    }
  ]

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