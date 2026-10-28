/**
 * 个人中心 Tab 注册中心
 * 插件在 config/module.config.ts 中调用 ucTabRegistry.register
 */

import type { Component } from 'vue'

export interface UcTabConfig {
  /** 全局唯一，如 storyStudio-publish */
  name: string
  /** 已有插件文案，如 admin.StoryStudioPublish */
  i18n: string
  order: number
  component: Component
}

class UcTabRegistry {
  private tabs: Map<string, UcTabConfig> = new Map()

  register(tab: UcTabConfig) {
    if (this.tabs.has(tab.name)) {
      console.warn(`[UC] Tab "${tab.name}" already registered, overwriting...`)
    }
    this.tabs.set(tab.name, tab)
  }

  getTabs(): UcTabConfig[] {
    return Array.from(this.tabs.values()).sort((a, b) => a.order - b.order)
  }
}

export const ucTabRegistry = new UcTabRegistry()
