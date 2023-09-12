<template>
  <UCard>
    <TodoTree 
      :todoId="todoId" 
      :treeLevel="0"
    />
  </UCard>
  <!-- <pre>{{ JSON.stringify(todoTree, null, 2) }}</pre> -->
</template>

<script lang="ts" setup>
  const route = useRoute()
  const todoTree = ref()
  const todoId = computed((): string => {
    return route.params.id as string
  })
</script>
