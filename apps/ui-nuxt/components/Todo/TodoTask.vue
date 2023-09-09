<template>
  <div v-if="todo" class="flex justify-start min-w-max border-2 rounded-md border-stone-400 grow">
    <div class="flex flex-col gap-3 align-items-center m-2 basis-1/10">
      <div class="flex gap-1">
        <div class="flex flex-col gap-1 w-30 p-1">
          <div class="flex justify-around gap-1">
            <UButton v-if="todo.status.toString().toUpperCase() === 'COMPLETE'" icon="i-heroicons-check" size="sm" color="green" square variant="solid" title="Reopen" @click="handleReopen" :disabled="closeDisabled"/>
            <UButton v-if="todo.status.toString().toUpperCase() === 'INCOMPLETE'" icon="none" size="sm" color="yellow" square variant="outline" title="Close" @click="handleClose" :disabled="closeDisabled"/>
            <TodoModal @updated="handleAddSubtask" :parent-todo="todo"/>
          </div>
          <div class="flex gap-1">
            <TodoModal :todo="todo" @updated="handleUpdated"/>
            <UButton icon="i-heroicons-minus-circle" size="sm" color="red" square variant="solid" title="Delete" @click="handleDelete"/>
          </div>
        </div>
      </div>
    </div>
    <div class="flex flex-1 flex-col m-2 flex-grow-2 gap-1">
      <div class="text-xl flex bg-cyan-950">
        <UButton
          class="flex grow"
          @click="handleSelectTodo(todo.id.toString())"
          :color="primaryButtonColor"
        >{{ todo.type.toString().split('').at(0) }}: {{ todo.name }}</UButton>
      </div>
      <div class="flex flex-1 gap-2 grow-0" v-if="showOwner">
        <TodoAssign :todo="todo" @assigned="handleAssigned" />
        <div>{{ todo.owner?.displayName }}</div>
      </div>
      <div class="flex flex-1" v-if="showDescription"><pre>{{ todo.description }}</pre></div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    todo: Todo
    showDescription?: boolean
  }>()
  const route = useRoute()

  const emit = defineEmits<{
    (e: 'updated', todo: Todo): void
    (e: 'subtaskAdded', todo: Todo, subTask: Todo): void
    (e: 'assigned', todo: Todo): void
    (e: 'deleted'): void
    (e: 'selected', todoId: string): void
  }>()

  const handleUpdated = async (todo: Todo) => {
    const result = await GqlUpdateTodo({
      todoId: todo.id,
      name: todo.name,
      description: todo.description
    })

    emit('updated', result.updateTodo.todo)
  }
  const handleDelete = async () => {
    const confirmed = confirm('Are you sure you want to delete?')
    if (!confirmed) return

    const result = await GqlDeleteTodo({
      todoId: props.todo.id
    })

    emit('deleted')
  }
  const handleAddSubtask = async (subTask: Todo) => {
    const result = await GqlCreateTodo({
      name: subTask.name,
      description: subTask.description,
      parentTodoId: subTask.parentTodoId
    })
    emit('subtaskAdded', props.todo, result.createTodo.todo)
  }
  const handleAssigned = async (residentId: string) => {
    const result = await GqlAssignTodo({
      todoId: props.todo.id,
      residentId: residentId
    })
    emit('assigned', props.todo)
  }
  const handleClose = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todo.id,
      status: 'COMPLETE'
    })
    emit('updated', props.todo)
  }
  const handleReopen = async () => {
    const result = await GqlUpdateTodoStatus({
      todoId: props.todo.id,
      status: 'INCOMPLETE'
    })
    emit('updated', props.todo)
  }
  const handleSelectTodo = async (todoId: string) => {
    emit('selected', todoId)
  }

  const showOwner = computed(() => {
    return true
  })
  const closeDisabled = computed(() => {
    return props.todo?.type.toString().toUpperCase() !== 'TASK'
  })
  const primaryButtonColor = computed(()=>{
    switch (props.todo.type.toString().toUpperCase()) {
      case 'MILESTONE':
        return 'white'
      case 'TASK':
        return 'black'
    }
    return `fuchsia`
  })
</script>