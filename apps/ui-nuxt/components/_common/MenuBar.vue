
<template>
  <div class="flex justify-between px-2 py-3">
    <div class="text-3xl hover:bg-sky-700 focus:cursor-pointer" @click="navigateTo('/')">SupaNuxtPhile</div>
    <div class="flex basis-2/3 gap-3">
      <Auth />
      <ColorMode />
    </div>
  </div>
</template>

<script lang="ts" setup>
</script>