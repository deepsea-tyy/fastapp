
declare interface Window {
  webkitDevicePixelRatio: any
  mozDevicePixelRatio: any
}

declare namespace JSX {
  interface Element extends VNode {}
  interface ElementClass extends Vue {}
  interface IntrinsicElements {
    [elem: string]: any
  }
}

declare const __MINE_SYSTEM_INFO__: {
  pkg: {
    version: Recordable<string>
    dependencies: Recordable<string>
    devDependencies: Recordable<string>
  }
  lastBuildTime: string
}
