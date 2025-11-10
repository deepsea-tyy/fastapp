
export function uploadLocal(options: any, url?: string, key?: string) {
  const upload = (formData: FormData) => {
    return useHttp().post(url ?? '/attachment/upload', formData)
  }

  return new Promise((resolve, reject) => {
    const formData = new FormData()
    formData.append(key ?? 'file', options.file)
    upload(formData).then((res: Record<string, any>) => {
      res.code === 200 ? resolve(res) : reject(res)
    }).catch((err) => {
      reject(err)
    })
  })
}
