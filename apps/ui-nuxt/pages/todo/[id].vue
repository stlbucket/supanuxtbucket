<template>
  <!-- <TodoTaskManager :todoId="todoId" /> -->
  <TodoTree :todoTree="todoTree" :treeLevel="0"/>
</template>

<script lang="ts" setup>
  const route = useRoute()
  const todoTree = ref()
  const todoId = computed((): string => {
    return route.params.id as string
  })
  const loadData = async () => {
    const result = await GqlTodoById({
      id: route.params.id,
    })
    todoTree.value = result.getFullTodoTree
  }
  loadData()


</script>
