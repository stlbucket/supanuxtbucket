<template>
  <div v-if="todoTree" class="flex flex-col grow">
    <div class="flex justify-start min-w-max border-2 rounded-md border-stone-400 grow ml-10">
      <div class="flex flex-col gap-3 align-items-center m-2 basis-1/10">
        <div class="flex gap-1">
          <div class="flex flex-col gap-1 w-30 p-1">
            <div class="flex justify-around gap-1">
              <div v-if="todoTree.type === 'TASK'" class="flex">
                <UButton 
                  v-if="todoTree.status?.toUpperCase() === 'COMPLETE'" 
                  icon="i-heroicons-check"
                  size="sm"
                  color="green"
                  square
                  variant="solid"
                  title="Reopen"
                  @click="onReopened"
                />
                <UButton
                  v-if="todoTree.status?.toUpperCase() === 'INCOMPLETE'"
                  icon="none"
                  size="sm"
                  color="yellow"
                  square variant="outline"
                  title="Close"
                  @click="onClosed"
                />
              </div>
              <div v-else class="flex">
                <UButton 
                  v-if="todoTree.status?.toUpperCase() === 'COMPLETE'" 
                  icon="i-heroicons-check"
                  size="sm"
                  color="green"
                  square
                  variant="solid"
                  title="Reopen"
                  @click="onReopened"
                  disabled
                />
                <UButton
                  v-if="todoTree.status?.toUpperCase() === 'INCOMPLETE'"
                  size="sm"
                  color="yellow"
                  square 
                  variant="outline"
                  title="Close"
                  @click="onClosed"
                  disabled
                >{{ completionRatio }}</UButton>
              </div>
              <TodoModal 
                v-if="detailed"
                @updated="onAddSubtask" 
                :parent-todo="todoTree"
              />
            </div>
            <div v-if="detailed" class="flex gap-1">
              <TodoModal :todo="todoTree" @updated="handleUpdated"/>
              <UButton 
                icon="i-heroicons-minus-circle" 
                size="sm" 
                color="red" 
                square 
                variant="solid" 
                title="Delete" 
                @click="onDelete"
              />
            </div>
            </div>
        </div>
      </div>
      <div class="flex flex-1 flex-col m-2 flex-grow-2 gap-1">
        <div class="text-xl flex bg-cyan-950">
          <UButton
            class="flex grow"
            @click="handleSelectTodo"
            :color="primaryButtonColor"
          >{{ todoTree.type?.split('').at(0) }}: {{ todoTree.name }}</UButton>
        </div>
        <div class="flex flex-1 gap-2 grow-0" v-if="detailed">
          <TodoAssign :todo="todoTree" @assigned="handleAssigned" />
          <div>{{ todoTree.owner?.displayName }}</div>
        </div>
      </div>
    </div>
    <div v-if="todoTree.hiddenChildren?.totalCount > 0" class="flex justify-start min-w-max grow ml-10 hover:cursor-pointer" @click="onLoadSubtree">
      Load {{ todoTree.hiddenChildren.totalCount }} children...
    </div>
    <div v-if="todoTree.children?.length > 0" class="ml-3">
      <TodoTree 
        v-for="c in todoTree.children" 
        :todo-id="c.id"
        :sub-tree="c" 
        :tree-level="(treeLevel + 1)"
        @selected="handleSelectTodo"
        @updated="handleChildUpdated"
        @subtask-added="handleAddSubtask"
        @deleted="handleDelete"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = withDefaults(defineProps<{
    todoId: string,
    subTree?: any,
    treeLevel?: number
  }>(), {
    treeLevel: 0
  })

  const emit = defineEmits<{
    (e: 'updated', todo: any): void
    (e: 'subtaskAdded', subTask: any): void    
    (e: 'assigned', todo: any): void
    (e: 'deleted', todoId: string): void
    (e: 'selected', todoId: string): void
  }>()

  const todoTree = ref()
  const detailed = ref(false)

  const shallowMerge = (todo: any) => {
    todoTree.value = {
      ...todoTree.value,
      ...{
        name: todo.name,
        status: todo.status,
        owner: todo.owner
      }
    }
  }

  const shallowRefresh = async () => {
    const result = await GqlTodoById({
      id: props.todoId,
    })
    shallowMerge(result.todo) 
    emit('updated', todoTree)
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
  }
  initializeData()

  // this only happens for tasks, which never have children
  const onClosed = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todoId,
      status: 'COMPLETE'
    })
    todoTree.value.status = result.updateTodoStatus.todo.status
    emit('updated', result.updateTodoStatus.todo)
  }
  // this only happens for tasks, which never have children
  const onReopened = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todoId,
      status: 'INCOMPLETE'
    })
    todoTree.value.status = result.updateTodoStatus.todo.status
    emit('updated', result.updateTodoStatus.todo)
  }
  const onAddSubtask = async (todo: any) => {
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
    emit('subtaskAdded', todoTree)
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
  const handleChildUpdated = async (todo: any) => {
    await shallowRefresh()
  }
  // updated is for changes that do not affect task status - name, description, tags...
  const handleUpdated = async (todo: any) => {
    await shallowMerge(todo)
  }
  // add the child optimistically, if current state is complete, then we will need to refresh and bubble
  const handleAddSubtask = async (todo: any) => {
    await shallowRefresh()
  }
  const handleAssigned = async (residentId: string) => {
    const result = await GqlAssignTodo({
      todoId: todoTree.value.id,
      residentId: residentId
    })
    await shallowMerge(result.assignTodo.todo)
  }
  const handleDelete = async (todoId: string) => {
    await loadData()
    // emit('updated', todoTree)
    // alert(todoId)
    // todoTree.value.children = todoTree.value.children.filter((t:any) => t.id !== todoId)
    // await shallowRefresh()
  }
  const handleSelectTodo = async () => {
    detailed.value = !detailed.value
  }
  const primaryButtonColor = computed(()=>{
    switch (todoTree.value.type) {
      case 'MILESTONE':
        return 'fuchsia'
      case 'TASK':
        return 'teal'
    }
    return `teal`
  })

  const completionRatio = computed(() => {
    const complete = (todoTree.value.children || []).filter((t:any) => t.status === 'COMPLETE').length
    const totalCount = (todoTree.value.children || []).length
    return `${complete}/${totalCount}`
  })
</script>