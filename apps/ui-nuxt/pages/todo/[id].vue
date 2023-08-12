<template>
  <TodoTaskManager :todoId="todoId" />
</template>

<script lang="ts" setup>
  const route = useRoute()
  const todoId = computed((): string => {
    return route.params.id as string
  })
</script>
