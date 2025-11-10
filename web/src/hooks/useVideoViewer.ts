import { h, createApp, ref } from 'vue'
import { ElDialog } from 'element-plus'

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
    zIndex: 2500,
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
        h('video', {
          src: videoUrl,
          controls: true,
          autoplay: false,
          preload: 'metadata',
          style: {
            maxWidth: '100%',
            maxHeight: '80vh',
            width: 'auto',
            height: 'auto',
            outline: 'none',
            borderRadius: '4px',
          },
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
  app.mount(videoViewerDom)
}

