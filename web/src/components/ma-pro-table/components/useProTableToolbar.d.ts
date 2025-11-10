import type { MaProTableToolbar } from '../types';
export default function useProTableToolbar(): {
    get: (name: string) => MaProTableToolbar;
    getAll: () => MaProTableToolbar[];
    add: (toolbar: MaProTableToolbar) => void;
    remove: (name: string) => void;
    hide: (name: string) => void;
    show: (name: string) => void;
};
