<template>
  <UCard>
    <template #header>
      <div class="flex flex-col gap-2">
        <div class="flex justify-between">
          <div class="text-2xl">Todo</div>
          <TodoModal @updated="handleCreate"></TodoModal>
        </div>
        <div class="flex flex-col">
          <div class="text-xs">SEARCH TERM</div>
          <UInput v-model="searchTerm" data-1p-ignore />
        </div>
      </div>
    </template>
    <UTable
      :rows="todos"
      :columns="[
        { key:'name', label: 'Name' },
        { key:'status', label: 'Status' }
      ]"
    >
      <template #name-data="{row}">
        <NuxtLink :to="`/tools/todo/${row.id}`">{{ row.name }}</NuxtLink>
      </template>
    </UTable>
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

  const appStore = useAppStateStore()
  const loggedIn = computed(()=>{
    return appStore.loggedIn
  })
</script>
