
export default function useParentNode(e: PointerEvent | MouseEvent, labelName: string) {
  let node: any = e.target
  while (node.tagName !== labelName.toUpperCase()) {
    node = node?.parentNode
  }
  return node
}
