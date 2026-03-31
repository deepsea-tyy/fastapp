import type { MaSearchItem } from '@/components/ma-search'
import MaRemoteSelect from '@/components/ma-remote-select/index.vue'
import {selectPlacementPosition} from "$/ds/sysCms/api/placementPosition.ts";

export default function getSearchItems(t: any): MaSearchItem[] {
  return [
    {
      label: () => t('admin.PlacementPosition'),
      prop: 'position_id',
      render: () => MaRemoteSelect,
      renderProps: {
                api: selectPlacementPosition,
placeholder: t('crud.status'),
            },
    },
    {
      label: () => t('crud.status'), // '状态：1显示 0隐藏'
      prop: 'status',
      render: () => <ma-dict-select />,
      renderProps: {
placeholder: t('crud.status'),
            },
    },
    {
      label: () => t('admin.PlacementContentFields.start_at'), // '开始时间（时间戳）'
      prop: 'start_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.start_at'),
            },
    },
    {
      label: () => t('admin.PlacementContentFields.start_at'), // '开始时间（时间戳）'
      prop: 'start_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.start_at'),
            },
    },
    {
      label: () => t('admin.PlacementContentFields.end_at'), // '结束时间（时间戳）'
      prop: 'end_at',
      render: () => <el-date-picker />,
      renderProps: {
placeholder: t('admin.PlacementContentFields.end_at'),
            },
    },
  ]
}
