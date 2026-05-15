<template>
  <div class="logs-page">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>容器日志 - {{ containerId }}</span>
          <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>
        </div>
      </template>
      
      <el-form :inline="true" class="query-form">
        <el-form-item label="行数">
          <el-input-number
            v-model="queryParams.lines"
            :min="10"
            :max="10000"
            :step="50"
          />
        </el-form-item>
        
        <el-form-item label="实时跟踪">
          <el-switch v-model="queryParams.follow" />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="loadLogs">
            查询日志
          </el-button>
          <el-button @click="clearLogs">清空</el-button>
        </el-form-item>
      </el-form>
      
      <el-divider />
      
      <div class="logs-container">
        <el-scrollbar ref="scrollbarRef" height="600px">
          <div ref="logsContentRef" class="logs-content">
            <div v-if="logsData && logsData.length > 0" class="logs-text">
              <div v-for="log in logsData" :key="log.lineNumber" class="log-line">
                <span class="line-number">{{ log.lineNumber }}</span>
                <span class="line-content">{{ log.content }}</span>
              </div>
            </div>
            <el-empty v-else description="暂无日志数据" />
          </div>
        </el-scrollbar>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import { getLogsApi } from '@/api/docker'
import type { LogQueryParams, LogLineVO } from '@/types'

const route = useRoute()
const router = useRouter()

const containerId = ref(route.params.containerId as string)
const loading = ref(false)
const logsData = ref<LogLineVO[]>([])
const scrollbarRef = ref()
const logsContentRef = ref()

const queryParams = reactive<LogQueryParams>({
  containerId: containerId.value,
  lines: 100,
  follow: false
})

const loadLogs = async () => {
  loading.value = true
  try {
    queryParams.containerId = containerId.value
    const res = await getLogsApi(queryParams)
    logsData.value = res.data || []
    
    ElMessage.success('日志加载成功')
    
    setTimeout(() => {
      scrollToBottom()
    }, 100)
  } catch (error) {
    console.error('加载日志失败:', error)
  } finally {
    loading.value = false
  }
}

const clearLogs = () => {
  logsData.value = []
  ElMessage.info('已清空日志')
}

const scrollToBottom = () => {
  if (scrollbarRef.value && logsContentRef.value) {
    const wrapRef = scrollbarRef.value.wrapRef
    if (wrapRef) {
      wrapRef.scrollTop = wrapRef.scrollHeight
    }
  }
}

const goBack = () => {
  router.back()
}

onMounted(() => {
  loadLogs()
})
</script>

<style lang="scss" scoped>
.logs-page {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .query-form {
    margin-bottom: 0;
  }
  
  .logs-container {
    background-color: #1e1e1e;
    border-radius: 4px;
    padding: 10px;
    
    .logs-content {
      .logs-text {
        color: #d4d4d4;
        font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
        font-size: 13px;
        line-height: 1.6;
        margin: 0;
        
        .log-line {
          display: flex;
          gap: 15px;
          padding: 2px 0;
          
          .line-number {
            color: #858585;
            min-width: 50px;
            text-align: right;
            user-select: none;
          }
          
          .line-content {
            flex: 1;
            white-space: pre-wrap;
            word-wrap: break-word;
          }
        }
      }
    }
  }
}
</style>
