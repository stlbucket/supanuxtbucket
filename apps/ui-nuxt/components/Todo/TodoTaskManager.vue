<template>
  <div class="flex justify-stretch grow" v-if="todo?.parent?.parent">
    <TodoTask 
      :todo="todo.parent.parent" 
      @updated="onUpdated"
      @selected="onTodoSelected"
      @subtask-added="onSubtaskAdded"
      @assigned="onAssigned"
      @deleted="onDeleted"
    />
  </div>
  <div class="flex pl-3 grow" v-if="todo?.parent">
    <TodoTask 
      :todo="todo.parent"
      @updated="onUpdated"
      @selected="onTodoSelected"
      @subtask-added="onSubtaskAdded"
      @assigned="onAssigned"
      @deleted="onDeleted"
    />
  </div>
  <div class="flex flex-col grow pl-6">
    <TodoTask 
      :todo="todo"
      @updated="onUpdated"
      @subtask-added="onSubtaskAdded"
      @assigned="onAssigned"
      @deleted="onDeleted"
      @selected="onTodoSelected"
      show-description
    ></TodoTask>
    <TodoListManager
      :todo="todo"
      v-if="todo"
      :hide-completed="hideCompleted"
      @updated="onUpdated"
      @subtask-added="onSubtaskAdded"
      @assigned="onAssigned"
      @deleted="onDeleted"
      @selected="onTodoSelected"
    />
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todoId: string
    hideCompleted?: boolean
  }>()
  const todo = ref()

  const loadData = async (todoId: string) => {
    const result = await GqlTodoById({
      id: todoId,
    })
    todo.value = result.todoById
  }
  loadData(props.todoId)

  const onUpdated = async (todo:any) => {
    await loadData(todo.id)
  }
  const onSubtaskAdded = async (todo:any, subTask:any) => {
    // await loadData(todo.id)
    await loadData(props.todoId)
  }
  const onAssigned = async (todo:any) => {
    await loadData(todo.id)
  }
  const onDeleted = async () => {
    await loadData(props.todoId)
  }
  const onTodoSelected = async (todoId: string) => {
    await loadData(todoId)
  }
</script>