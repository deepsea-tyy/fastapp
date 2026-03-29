import type { MaProTableRenderPlugin } from '../types';
export default function useProTableRenderPlugin(): {
    getPluginByName: (name: string) => MaProTableRenderPlugin;
    getPlugins: () => MaProTableRenderPlugin[];
    addPlugin: (plugin: MaProTableRenderPlugin) => void;
    removePlugin: (name: string) => void;
};
