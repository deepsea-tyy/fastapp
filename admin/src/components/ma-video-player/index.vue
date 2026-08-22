<script setup lang="ts">
import Player from 'xgplayer'
import 'xgplayer/dist/index.min.css'
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'

defineOptions({ name: 'MaVideoPlayer' })

const props = withDefaults(defineProps<{
  src: string
  autoplay?: boolean
  muted?: boolean
  width?: number | string
  height?: number | string
}>(), {
  autoplay: true,
  muted: false,
  width: '100%',
  height: '100%',
})

const emit = defineEmits<{
  timeupdate: [currentTimeMs: number]
  ended: []
}>()

const containerRef = ref<HTMLDivElement>()
let player: Player | null = null

function initPlayer() {
  if (!containerRef.value || !props.src)
    return
  destroyPlayer()
  player = new Player({
    el: containerRef.value,
    url: props.src,
    width: props.width,
    height: props.height,
    autoplay: props.autoplay,
    muted: props.muted,
    playsinline: true,
    fluid: false,
    controls: true,
    crossorigin: true,
  })
  player.on('timeupdate', () => {
    if (player)
      emit('timeupdate', player.currentTime * 1000)
  })
  player.on('ended', () => {
    emit('ended')
  })
}

function destroyPlayer() {
  if (player) {
    player.destroy()
    player = null
  }
}

function pause() {
  player?.pause()
}

function play() {
  return player?.play() ?? Promise.resolve()
}

function getCurrentTimeMs(): number {
  return player ? player.currentTime * 1000 : 0
}

function setCurrentTimeMs(ms: number) {
  if (player)
    player.currentTime = ms / 1000
}

defineExpose({
  pause,
  play,
  getCurrentTimeMs,
  setCurrentTimeMs,
  get player() {
    return player
  },
})

watch(() => props.src, () => {
  initPlayer()
})

watch(() => props.muted, (val) => {
  if (player)
    player.muted = val
})

onMounted(() => {
  initPlayer()
})

onBeforeUnmount(() => {
  destroyPlayer()
})
</script>

<template>
  <div class="ma-video-player">
    <div ref="containerRef" class="ma-video-player__container" />
  </div>
</template>

<style scoped>
.ma-video-player {
  width: 100%;
  height: 100%;
}

.ma-video-player__container {
  width: 100%;
  height: 100%;
}
</style>
