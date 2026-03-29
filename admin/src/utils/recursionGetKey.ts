
export function recursionGetKey(arr: any[], key: string): any[] {
  const keys: any[] = []
  arr.map((item: any) => {
    if (item.children && item.children.length > 0) {
      keys.push(...recursionGetKey(item.children, key))
    }
    else {
      keys.push(item[key])
    }
  })
  return keys
}
