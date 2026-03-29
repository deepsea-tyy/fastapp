
export default function hasIncludesByArray(data: string[], needCheckData: string[]): boolean {
  return needCheckData.every(item => data.includes(item))
}
