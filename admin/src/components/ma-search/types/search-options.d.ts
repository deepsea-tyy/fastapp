export type MediaBreakPoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
/**
 * @description `MaSearch` 配置项列表
 */
export interface MaSearchOptions {
    defaultValue?: Record<string, any>;
    cols?: Record<MediaBreakPoint, number>;
    fold?: boolean;
    foldButtonShow?: boolean;
    foldRows?: number;
    show?: boolean | (() => boolean);
    text?: {
        searchBtn?: () => string;
        resetBtn?: () => string;
        isFoldBtn?: () => string;
        notFoldBtn?: () => string;
    };
    searchBtnProps?: Record<string, any>;
    resetBtnProps?: Record<string, any>;
}
