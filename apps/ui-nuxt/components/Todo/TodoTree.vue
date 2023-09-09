<template>
  <div v-if="todoTree" class="flex flex-col grow">
    <div class="flex justify-start min-w-max border-2 rounded-md border-stone-400 grow ml-10">
      <div class="flex flex-col gap-3 align-items-center m-2 basis-1/10">
        <div class="flex gap-1">
          <div class="flex flex-col gap-1 w-30 p-1">
            <div class="flex justify-around gap-1">
              <div v-if="todoTree.type.toString().toUpperCase() === 'TASK'" class="flex">
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
                size="xs" 
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
            :title="todoTree.description"
          >{{ buttonName }}</UButton>
        </div>
        <div class="flex flex-1 gap-2 grow-0" v-if="detailed">
          <TodoAssign :todo="todoTree" @assigned="handleAssigned" />
          <div>{{ todoTree.owner?.displayName }}</div>
        </div>
      </div>
    </div>
    <div v-if="todoTree.hiddenChildren?.totalCount ?? 0 > 0" class="flex justify-start min-w-max grow ml-10 hover:cursor-pointer" @click="onLoadSubtree">
      Load {{ todoTree.hiddenChildren?.totalCount ?? 0 }} children...
    </div>
    <div v-if="todoTree.children?.length ?? 0 > 0" class="ml-3">
      <TodoTree 
        v-for="c in todoTree.children" 
        :todo-id="c.id.toString()"
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
  // import { Todo } from 'db-types';

  const props = withDefaults(defineProps<{
    todoId: string,
    subTree?: Todo,
    treeLevel?: number
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

    // if (todoTree.value) {
    //   switch (todoTree.value.type.toString().toUpperCase()) {
    //     case 'MILESTONE':
    //       return 'white'
    //     case 'TASK':
    //       return 'black'
    //   }
    //   return `teal`
    // }
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
    // return `${todoTree.value?.type?.toString().split('').at(0)}: ${ todoTree.value?.name}`
  })
</script>