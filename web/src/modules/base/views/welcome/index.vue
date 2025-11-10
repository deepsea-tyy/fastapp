
<script setup lang="tsx">
import type { MaTableExpose } from '@/components/ma-table'
import useTable from '@/hooks/useTable.ts'

defineOptions({ name: 'welcome' })

useTable('table').then((table: MaTableExpose) => {
  table.setColumns([
    { label: '成员', prop: 'member', width: 150, align: 'center' },
    { label: '动态', prop: 'dynamic', align: 'center' },
    { label: '时间', prop: 'timer', width: 180, align: 'center',
      cellRender: ({ row }) => {
        return useDayjs(row.timer).fromNow()
      },
    },
  ])

  table.setData([
    { member: 'IT界-风清扬', dynamic: '上班不摸鱼，与咸鱼有什么区别。', timer: '2024-09-25 17:10:20' },
  ])
})
</script>

<template>
  <div class="mine-layout">

    <div class="justify-between lg:flex">
      <div class="mine-card w-auto lg:w-8/12">
        <div class="text-base">
          <div>事项</div>
        </div>
        <div class="grid grid-cols-1 mt-3 lg:grid-cols-3">
          <div class="run-list">
            <div class="flex items-center gap-x-3">
              <ma-svg-icon name="skill-icons:php-light" :size="30" />
              <div>
                Hypertext Preprocessor
              </div>
            </div>
            <div class="desc">
              即“超文本预处理器”，是在服务器端执行的脚本语言，尤其适用于Web开发并可嵌入HTML中。
            </div>
          </div>
        </div>
      </div>
      <div class="mine-card w-auto !ml-3 lg:w-4/12 !lg:ml-0">
        <div class="text-base">
          <div>标题</div>
        </div>
        <div class="mt-3 p-2 text-sm leading-6">
          欢迎使用~
        </div>
        <div class="p-2 text-sm text-gray-5 dark-text-[#ccc]">
          <ul class="ma-link">
            <li>
              <el-link target="_blank" href="javascript:;">
                官方网站 =>
              </el-link>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <div class="mine-card">
      <div class="text-base">
        <div>动态</div>
      </div>
      <ma-table ref="table" class="mt-5" />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.run-list {
  @apply b-1 b-solid b-gray-1 dark-b-dark-3 p-3 b-l-0 b-t-0 b-r-0 lg:b-r-1
  transition-all duration-300
  hover-shadow dark-hover-shadow-dark-3
  ;

  .desc {
    @apply mt-3 text-sm leading-6 dark-text-[#888] text-gray-5
  }
}

.ma-link li {
  @apply flex items-center py-1.5;
}
</style>
