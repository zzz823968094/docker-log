<template>
  <el-dialog
    v-model="dialogVisible"
    title="容器日志文件列表"
    width="800px"
    @close="handleClose"
  >
    <el-table
      v-loading="loading"
      :data="logFiles"
      stripe
      style="width: 100%"
    >
      <el-table-column prop="fileName" label="文件名" min-width="200" />
      <el-table-column prop="fileSizeFormatted" label="文件大小" width="120" />
      <el-table-column prop="lastModifiedFormatted" label="最后修改时间" width="180" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag v-if="row.isActive" type="success">活动</el-tag>
          <el-tag v-else type="info">历史</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button
            type="primary"
            size="small"
            @click="viewLogFile(row)"
          >
            查看
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <el-empty v-if="!loading && logFiles.length === 0" description="暂无日志文件" />
    
    <template #footer>
      <el-button @click="dialogVisible = false">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { getLogFilesApi } from '@/api/docker'
import type { LogFileVO } from '@/types'

const dialogVisible = ref(false)
const loading = ref(false)
const logFiles = ref<LogFileVO[]>([])
const currentContainerId = ref('')

const emit = defineEmits<{
  (e: 'view', file: LogFileVO): void
}>()

const open = async (containerId: string) => {
  currentContainerId.value = containerId
  dialogVisible.value = true
  await loadLogFiles()
}

const loadLogFiles = async () => {
  loading.value = true
  try {
    const res = await getLogFilesApi(currentContainerId.value)
    logFiles.value = res.data || []
  } catch (error) {
    console.error('加载日志文件列表失败:', error)
  } finally {
    loading.value = false
  }
}

const viewLogFile = (file: LogFileVO) => {
  emit('view', file)
  dialogVisible.value = false
}

const handleClose = () => {
  logFiles.value = []
  currentContainerId.value = ''
}

defineExpose({
  open
})
</script>

<style lang="scss" scoped>
// 样式继承自 Element Plus Dialog
</style>
