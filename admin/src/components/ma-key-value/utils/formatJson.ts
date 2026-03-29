
export default function formatJson(json: Record<string, any>): string {
  try {
    return JSON.stringify(json, null, 2)
  }
  catch (error) {
    // 如果解析失败，返回原始字符串并附带错误信息
    console.error('Invalid JSON string:', error)
    return `/* Invalid JSON: ${json} */`
  }
}
