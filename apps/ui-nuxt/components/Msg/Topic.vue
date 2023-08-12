<template>
  <UCard v-if="topic" class="flex flex-col grow">
    <template #header>
      <div class="flex justify-between">
        <div class="text-2xl">{{ title || topic.name }}</div>
        <div class="flex justify-start gap-5">
        </div>
      </div>
    </template>
    <div class="flex flex-col gap-1.5">
      <div class="flex gap-1">
        <div class="flex grow">
          <UTextarea
            v-model="content"
            :ui="{
              wrapper: 'flex grow'
            }"
          ></UTextarea>
        </div>
        <UButton 
          @click="handleSendMessage"
          :disabled="sendDisabled"
        >Send</UButton>
      </div>
      <div v-for="m in preppedMessages" class="flex flex-col">
        <div :class="m.display.justify">
          <div class="flex flex-col w-3/4 gap-0.5">
            <div class="flex text-sm font-bold">{{ m.postedBy.displayName }}</div>
            <div class="flex text-xs italic">{{ useFormatDateTimeString(m.createdAt) }}</div>
            <div :class="m.display.content"><pre>{{ m.content }}</pre></div>
          </div>
        </div>
      </div>
    </div>
  </UCard>
</template>

<script lang="ts" setup>
  const props = defineProps<{
    topicId: string,
    title?: string
  }>()
  const user = useSupabaseUser()
  const topic = ref()
  const content = ref('')

  const loadData = async () => {
    const result = await GqlDiscussionById({
      topicId: props.topicId
    })
    topic.value = result.topic
  }
  loadData()

  const preppedMessages = computed(() => {
    return topic.value?.messages.map(m => {
      return {
        ...m,
        display: {
          justify: user.value?.user_metadata.display_name === m.postedBy.displayName ? 'flex justify-end' : 'flex justify-start',
          content: user.value?.user_metadata.display_name === m.postedBy.displayName ? 'flex bg-blue-700 p-1 rounded grow break-normal' :  'flex bg-green-700 p-1 rounded grow break-normal'
        }
      }
    })
    .sort((a:any,b:any) => a.createdAt > b.createdAt ? -1 : 1)
  })

  const sendDisabled = computed(()=>{
    return content.value?.length === 0
  })

  const handleSendMessage = async () => {
    const result = await GqlUpsertMessage({
      messageInfo: {
        topicId: topic.value.id,
        content: content.value
      }
    })
    content.value = ''
    await loadData()
  }
  </script>
