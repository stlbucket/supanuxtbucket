<template>
  <UCard>
    <template #header>
      <div class="flex justify-between">
        <div class="text-2xl">Projects</div>
        <TodoModal @updated="handleCreate"></TodoModal>
      </div>
      <div>
        <UInput v-model="searchTerm" />
      </div>
    </template>
    <div class="flex flex-col gap-1">
      <TodoTask v-for="t in todos" :todo="t" 
        @updated="loadData" 
        @deleted="loadData"
        @selected="handleSelected"
      ></TodoTask>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const todos = ref([])
  const searchTerm = ref()
  const loadData = async () => {
    const result = await GqlSearchTodos({
      searchTerm: searchTerm.value,
      rootsOnly: true
    })
    todos.value = result.searchTodos.nodes
  }
  loadData()

  watch(()=>searchTerm.value, loadData)

  const handleCreate = async (todo: Todo) => {
    const result = await GqlCreateTodo({
      name: todo.name,
      description: todo.description
    })
    await loadData()
  }

  const handleSelected = async (todoId: string) => {
    navigateTo(`/tools/todo/${todoId}`)
  }
</script>
