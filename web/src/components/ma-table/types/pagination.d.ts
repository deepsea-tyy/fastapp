import type { CSSProperties } from 'vue';
/**
 * @description 分页相关配置。注意：`pageSize`、`total`、`currentPage` 这三个属性必传
 * @see {@link https://element-plus.org/zh-CN/component/pagination.html#%E5%B1%9E%E6%80%A7}
 */
export interface PaginationProps {
    total?: number;
    pageSize?: number;
    currentPage?: number;
    size?: '' | 'small' | 'default' | 'large';
    small?: boolean;
    background?: boolean;
    defaultPageSize?: number;
    pageCount?: number;
    pagerCount?: number;
    defaultCurrentPage?: number;
    layout?: string;
    pageSizes?: number[];
    popperClass?: string;
    prevText?: string;
    nextText?: string;
    disabled?: boolean;
    hideOnSinglePage?: boolean;
    style?: CSSProperties;
    class?: string;
    onSizeChange?: (value: number) => void;
    onCurrentChange?: (value: number) => void;
    onChange?: (currentPage: number, pageSize: number) => void;
    onPrevClick?: (value: number) => void;
    onNextClick?: (value: number) => void;
}
