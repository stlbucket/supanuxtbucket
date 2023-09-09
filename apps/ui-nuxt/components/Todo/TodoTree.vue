<template>
  <div v-if="todoTree" class="flex flex-col grow">
    <div class="flex justify-start min-w-max border-2 rounded-md border-black grow ml-10">
      <div class="flex flex-1 flex-col m-2 flex-grow-2">
        <div class="text-xl flex gap-1">
          <div v-if="String(todoTree.type) === 'TASK'" class="flex ">
            <UButton 
              v-if="todoTree.status?.toString().toUpperCase() === 'COMPLETE'"
              icon="i-heroicons-check"
              size="xs"
              color="green"
              square
              variant="solid"
              title="Reopen"
              @click="onReopened"
            />
            <UButton
              v-if="todoTree.status?.toString().toUpperCase() === 'INCOMPLETE'"
              icon="none"
              size="xs"
              color="yellow"
              square variant="outline"
              :title="Boolean(todoTree.isTemplate) ? 'This is a template so no action can be taken' : 'Close'"
              @click="onClosed"
              :disabled="Boolean(todoTree.isTemplate)"
            />
          </div>
          <div v-else class="flex">
            <UButton
              v-if="todoTree.status?.toString().toUpperCase() === 'COMPLETE'" 
              icon="i-heroicons-check"
              size="xs"
              color="green"
              square
              variant="solid"
              title="Reopen"
              @click="onReopened"
              disabled
            />
            <UButton
              v-if="todoTree.status?.toString().toUpperCase() === 'INCOMPLETE'"
              size="xs"
              color="yellow"
              square 
              variant="outline"
              title="Close"
              @click="onClosed"
              disabled
            >{{ completionRatio }}</UButton>
          </div>
          <UButton 
            v-if="String(todoTree.type) === 'MILESTONE'"
            :icon="expansionIcon"
            size="xs"
            color="white" 
            square 
            variant="solid" 
            :title="expansionTitle" 
            @click="onToggleExpansion"
          />
          <UButton 
            v-if="String(todoTree.type) === 'MILESTONE' && !expanded"
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
            @click="handleSelectTodo"
            :color="primaryButtonColor"
            :title="todoTree.description"
          >{{ buttonName }}</UButton>
        </div>
        <div class="flex gap-1" v-if="detailed">
          <TodoModal 
            @updated="onAddSubtask" 
            :parent-todo="todoTree"
          />
          <UButton
            v-if="String(todoTree.type) === 'TASK'"
            icon="i-heroicons-minus-circle"
            size="xs"
            color="white" 
            square 
            variant="solid" 
            title="Delete" 
            @click="onDelete"
          />
          <TodoModal 
            @updated="onAddSubtask" 
            :todo="todoTree"
          />
          <TodoAssign :todo="todoTree" @assigned="handleAssigned" />
          <div>{{ todoTree.owner?.displayName }}</div>
        </div>
      </div>
    </div>
    <div v-if="showLoadChildren" class="flex justify-start min-w-max grow ml-10 hover:cursor-pointer" @click="onLoadSubtree">
      Load {{ todoTree.hiddenChildren?.totalCount ?? 0 }} children...
    </div>
    <div v-if="showChildren" class="ml-3">
      <TodoTree 
        v-for="c in todoTree.children" 
        :todo-id="c.id.toString()"
        :sub-tree="c" 
        :tree-level="(treeLevel + 1)"
        @selected="handleSelectTodo"
        @updated="handleChildUpdated"
        @subtask-added="handleAddSubtask"
        @deleted="handleDelete"
        :expand-all="expandAllChildren"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = withDefaults(defineProps<{
    todoId: string,
    subTree?: Todo,
    treeLevel?: number,
    expandAll?: boolean
  }>(), {
    treeLevel: 0
  })

  const emit = defineEmits<{
    (e: 'updated', todo: Todo): void
    (e: 'subtaskAdded', subTask: Todo): void    
    (e: 'assigned', todo: Todo): void
    (e: 'deleted', todoId: string): void
    (e: 'selected', todoId: string): void
  }>()

  const todoTree: Ref<Todo | undefined> = ref()
  const detailed = ref(false)
  const expanded = ref(false)
  const expandAllChildren = ref(false)

  const shallowMerge = (todo: Todo) => {

    todoTree.value = {
      ...todoTree.value,
      ...{
        name: todo.name,
        status: todo.status,
        owner: todo.owner,
      }
    } as Todo
  }

  const shallowRefresh = async () => {
    const result = await GqlTodoById({
      id: props.todoId,
    })
    shallowMerge(result.todo) 
    emit('updated', todoTree.value as Todo)
  }

  const loadData = async () => {
    const result = await GqlTodoById({
      id: props.todoId,
    })
    todoTree.value = result.todo
  }

  const initializeData = async () => {
    // console.log(JSON.stringify(props,null,2))
    if (props.treeLevel === 0) {
      await loadData()
    } else {
      todoTree.value = props.subTree
    }
    expanded.value = !!props.expandAll
    expandAllChildren.value = !!props.expandAll
  }
  initializeData()

  // this only happens for tasks, which never have children
  const onClosed = async () => {
    if (todoTree.value) {
      const result = await GqlUpdateTodoStatus({
        todoId: props.todoId,
        status: 'COMPLETE'
      })
      todoTree.value.status = result.updateTodoStatus.todo.status
      emit('updated', result.updateTodoStatus.todo)
    }
  }
  // this only happens for tasks, which never have children
  const onReopened = async () => {
    if (todoTree.value) {
      const result = await GqlUpdateTodoStatus({
        todoId: props.todoId,
        status: 'INCOMPLETE'
      })
      todoTree.value.status = result.updateTodoStatus.todo.status
      emit('updated', result.updateTodoStatus.todo)
    }
  }
  const onAddSubtask = async (todo: Todo) => {
    if (todoTree.value) {
      const result = await GqlCreateTodo({
        name: todo.name,
        description: todo.description,
        parentTodoId: todo.parentTodoId
      })
      const children = [
        ...(todoTree.value.children || []),
        result.createTodo.todo
      ]
      todoTree.value.children = children
      // @ts-ignore
      todoTree.value.status = 'INCOMPLETE'
      // @ts-ignore
      todoTree.value.type = 'MILESTONE'
      emit('subtaskAdded', todoTree.value)
    }
  }
  const onDelete = async () => {
    const result = await GqlDeleteTodo({
      todoId: props.todoId
    })
    emit('deleted', props.todoId)
  }
  const onLoadSubtree = async () => {
    await loadData()
  }

  // this only happens for milestones, which always have children
  const handleChildUpdated = async (todo: Todo) => {
    await shallowRefresh()
  }
  // updated is for changes that do not affect task status - name, description, tags...
  const handleUpdated = async (todo: Todo) => {
    await shallowMerge(todo)
  }
  // add the child optimistically, if current state is complete, then we will need to refresh and bubble
  const handleAddSubtask = async (todo: Todo) => {
    await shallowRefresh()
  }
  const handleAssigned = async (residentId: string) => {
    if (todoTree.value) {
      const result = await GqlAssignTodo({
        todoId: todoTree.value.id,
        residentId: residentId
      })
      await shallowMerge(result.assignTodo.todo)
    }
  }
  const handleDelete = async (todoId: string) => {
    await loadData()
  }
  const handleSelectTodo = async () => {
    detailed.value = !detailed.value
  }
  const primaryButtonColor = computed(()=>{
    const type = String(todoTree.value?.type)
    return type === 'MILESTONE' ? 'white' : 'black'
  })

  const completionRatio = computed(() => {
    if (todoTree.value) {
      const complete = (todoTree.value.children || []).filter((t:Todo) => t.status.toString().toUpperCase() === 'COMPLETE').length
      const totalCount = (todoTree.value.children || []).length
      return `${complete}/${totalCount}`
    }
  })

  const buttonName = computed(() => {
    return todoTree.value?.name
  })

  const showChildren = computed(() => {
    return expanded.value && ((todoTree.value?.children?.length ?? 0) > 0)
  })
  const showLoadChildren = computed(() => {
    return todoTree.value?.hiddenChildren?.totalCount ?? 0 > 0
  })

  const onExpandAllChildren = async () => {
    expanded.value = true
    expandAllChildren.value = true
  }
  const onToggleExpansion = async () => {
    expanded.value = !(expanded.value)
    if (!expanded.value) {
      expandAllChildren.value = false
    }
  }
  const expansionIcon = computed(() => {
    return `${expanded.value ? 'i-heroicons-chevron-up' : 'i-heroicons-chevron-down'}`
  })
  const expansionTitle = computed(() => {
    return `${expanded.value ? 'Collapse' : 'Expand'}`
  })
  watch(()=>{ 
    return props.expandAll
  }, ()=>{
    alert(props.expandAll)
    expanded.value = props.expandAll
    alert(expanded.value)
    expandAllChildren.value = props.expandAll
  })
</script>