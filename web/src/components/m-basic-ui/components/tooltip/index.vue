
<script setup lang="ts">
defineOptions({ name: 'MTooltip' })

withDefaults(
  defineProps<{
    text?: string | (() => string)
    enable?: boolean
  }>(),
  {
    text: '',
    enable: true,
  },
)
</script>

<template>
  <v-tooltip v-if="enable" :popper-triggers="['hover']" v-bind="$attrs">
    <slot />
    <template #popper>
      <slot name="text">
        {{ text }}
      </slot>
    </template>
  </v-tooltip>
  <div v-else>
    <slot />
  </div>
</template>
