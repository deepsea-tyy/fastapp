import { h, createApp, ref } from 'vue'
import ElementPlus, { ElDialog } from 'element-plus'
import MaVideoPlayer from '@/components/ma-video-player/index.vue'

type Options = {
  title?: string
  width?: string
  zIndex?: number
}

export function useVideoViewer(videoUrl: string, options?: Options) {
  const videoViewerDom = document.createElement('div')
  document.body.appendChild(videoViewerDom)

  const defaultOptions: Options = {
    title: '视频预览',
    width: '80%',
    zIndex: 3000,
    ...options,
  }

  let app: any = null

  const close = () => {
    if (app && videoViewerDom.parentNode) {
      app.unmount()
      videoViewerDom.parentNode.removeChild(videoViewerDom)
      app = null
    }
  }

  const VideoViewerComponent = {
    setup() {
      const visible = ref(true)

      const handleClose = () => {
        visible.value = false
        setTimeout(() => {
          close()
        }, 300)
      }

      const videoContent = h('div', {
        class: 'video-viewer-content',
        style: {
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          minHeight: '60vh',
          backgroundColor: '#000',
          padding: '20px',
          borderRadius: '4px',
        },
      }, [
        h(MaVideoPlayer, {
          src: videoUrl,
          height: '70vh',
          autoplay: false,
        }),
      ])

      return () => h(ElDialog, {
        modelValue: visible.value,
        'onUpdate:modelValue': (val: boolean) => {
          visible.value = val
          if (!val) {
            handleClose()
          }
        },
        title: defaultOptions.title,
        width: defaultOptions.width,
        zIndex: defaultOptions.zIndex,
        destroyOnClose: true,
        appendToBody: true,
        closeOnClickModal: true,
        onClose: handleClose,
      }, {
        default: () => videoContent,
      })
    },
  }

  app = createApp(VideoViewerComponent)
  app.use(ElementPlus, {})
  app.mount(videoViewerDom)
}
