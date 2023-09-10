<template>
  <menu-bar></menu-bar>
  <div class="flex items-star items-stretch">
    <div class="flex flex-col">
      <TheNav />
    </div>
    <div class="flex flex-col grow">
      <slot />      
    </div>
  </div>
</template>
