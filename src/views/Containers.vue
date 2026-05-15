<template>
  <div class="containers-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>Docker容器列表</span>
          <el-button type="primary" :icon="Refresh" @click="loadContainers">
            刷新
          </el-button>
        </div>
      </template>
      
      <el-table
        v-loading="loading"
        :data="containerList"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="containerId" label="容器ID" width="200" />
        <el-table-column prop="containerName" label="容器名称" width="200" />
        <el-table-column prop="imageName" label="镜像" width="250" />
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="280">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click="viewLogs(row)"
            >
              查看日志
            </el-button>
            <el-button
              type="warning"
              size="small"
              @click="showLogFiles(row)"
            >
              日志文件
            </el-button>
            <el-button
              type="success"
              size="small"
              @click="validateContainer(row)"
            >
              验证
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-empty v-if="!loading && containerList.length === 0" description="暂无容器数据" />
    </el-card>
    
    <LogFileList ref="logFileListRef" @view="handleViewLogFile" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Refresh } from '@element-plus/icons-vue'
import { getContainersApi, validateContainerApi } from '@/api/docker'
import type { ContainerInfo, LogFileVO } from '@/types'
import LogFileList from '@/components/LogFileList.vue'

const router = useRouter()
const loading = ref(false)
const containerList = ref<ContainerInfo[]>([])
const logFileListRef = ref()

const loadContainers = async () => {
  loading.value = true
  try {
    const res = await getContainersApi()
    containerList.value = res.data || []
  } catch (error) {
    console.error('加载容器列表失败:', error)
  } finally {
    loading.value = false
  }
}

const getStatusType = (status: string): 'success' | 'warning' | 'danger' | 'info' => {
  if (status.toLowerCase().includes('running')) return 'success'
  if (status.toLowerCase().includes('stopped') || status.toLowerCase().includes('exited')) return 'danger'
  if (status.toLowerCase().includes('paused')) return 'warning'
  return 'info'
}

const viewLogs = (container: ContainerInfo) => {
  router.push(`/logs/${container.containerId}`)
}

const showLogFiles = (container: ContainerInfo) => {
  logFileListRef.value?.open(container.containerId)
}

const handleViewLogFile = (file: LogFileVO) => {
  ElMessage.info(`查看日志文件: ${file.fileName}`)
  // TODO: 实现日志文件查看功能
}

const validateContainer = async (container: ContainerInfo) => {
  try {
    const res = await validateContainerApi(container.containerId)
    if (res.data) {
      ElMessage.success(`容器 ${container.containerName} 验证成功`)
    } else {
      ElMessage.warning(`容器 ${container.containerName} 不存在`)
    }
  } catch (error) {
    console.error('验证容器失败:', error)
  }
}

onMounted(() => {
  loadContainers()
})
</script>

<style lang="scss" scoped>
.containers-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}
</style>
