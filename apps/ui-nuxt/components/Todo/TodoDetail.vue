<template>
  <UCard>
    <template #header>
      <div class="flex gap-2">
        <TodoModal
          :todo="todo"
          @updated="onUpdated"
        />
        <UButton color="red" @click="onDelete">Delete</UButton>                
        <div class="flex" v-if="!todo.isTemplate">
          <UButton v-if="String(todo.status) === 'OPEN'" color="yellow" @click="onClose">Close</UButton>
          <UButton v-if="String(todo.status) === 'CLOSED'" color="yellow" @click="onOpen">Reopen</UButton>
        </div>
        <div class="flex" v-if="!todo.isTemplate">
          <UButton color="blue" @click="onMakeTemplate" v-if="showMakeTemplate">Make Template</UButton>
        </div>
        <div class="flex" v-if="todo.isTemplate">
          <UButton color="blue" @click="onNewTodo">New Todo</UButton>
        </div>
      </div>
    </template>
    <div class="flex grow min-h-[200px]">
      <UTextarea
        :model-value="description"
        disabled
        :ui="{
          wrapper: 'flex grow'
        }"
      />
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const user = useSupabaseUser()
  const props = defineProps<{
    todo: Todo
  }>()

  const emit = defineEmits<{
    (e: 'updated', todoInfo: Todo): void
    (e: 'open'): void
    (e: 'close'): void
    (e: 'delete'): void
    (e: 'makeTemplate'): void,
    (e: 'cloneTemplate'): void
  }>()

  const description = computed((): string => {
    return props.todo.description ?? ''
  })

  const onUpdated = async(todoInfo: Todo) => {
    emit('updated', todoInfo)
  }

  const onOpen = async () => {
    emit('open')
  }

  const onClose = async () => {
    emit('close')
  }

  const onDelete = async () => {
    emit('delete')
  }

  const onMakeTemplate = async () => {
    emit('makeTemplate')
  }

  const onNewTodo = async () => {
    emit('cloneTemplate')
  }

  const showMakeTemplate = computed(() => {
    return useHasPermission(user, 'p:todos-admin')
  })
</script>