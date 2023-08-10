<template>
  <UTabs
    v-if="incident"
    :items="tabItems"
    class="flex flex-col grow"
    v-model="selectedTab"
  >
    <template #default="{item}">
      {{ item.label }}
    </template>
    <template #detailed="{item}">
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
          v-if="todo"
          :todo="todo"
          @updated="onUpdated"
          @selected="onTodoSelected"
          @subtask-added="onSubtaskAdded"
          @assigned="onAssigned"
          @deleted="onDeleted"
          show-description
        />
        <TodoListManagerTabbed
          :todo="todo"
          v-if="todo"
          @updated="onUpdated"
          @subtask-added="onSubtaskAdded"
          @assigned="onAssigned"
          @deleted="onDeleted"
          @selected="onTodoSelected"
        />
      </div>
    </template>
    <template #tree="{item}">
      <IncidentTodoTree
        :key="componentKey"
        :todo-tree="fullTodoTree" 
        :tree-level="0"
        @updated="onUpdated"
        @selected="onTodoSelected"
      />
    </template>
  </UTabs>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    incident: any
    hideCompleted?: boolean
  }>()
  const focusTodoId = ref(props.incident.todo.id)
  const todo = ref()
  const fullTodoTree = ref({})
  const componentKey = ref(0)

  const loadData = async () => {
    const result = await GqlTodoById({
      id: focusTodoId.value,
    })
    todo.value = result.todoById
    fullTodoTree.value = result.getFullTodoTree
    componentKey.value += 1
  }
  loadData()

  const onUpdated = async (todoId:any) => {
    await loadData()
  }
  const onSubtaskAdded = async (todo:any, subTask:any) => {
    await loadData()
  }
  const onAssigned = async (todo:any) => {
    await loadData()
  }
  const onDeleted = async () => {
    await loadData()
  }
  const onTodoSelected = async (todoId: string) => {
    focusTodoId.value = todoId
    await loadData()
    selectedTab.value = 1
  }

  const tabItems = [
    {
      slot: 'tree',
      label: 'Tree'
    },
    {
      slot: 'detailed',
      label: 'Detail'
    },
  ]
  const selectedTab = ref(0)
  // const onTabChange = async (index: number) => {
  //   if (index === 0) {
  //     focusTodoId.value = props.incident.todo.id
  //     await loadData()
  //   }
  // }
</script>