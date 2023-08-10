<template>
  <UVerticalNavigation :links="links" />
</template>

<script lang="ts" setup>
const links = [
  {
    label: 'Projects',
    icon: 'i-heroicons-clipboard-document-list',
    to: '/todo'
  }
]
</script>