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
            :disabled="queryParams.follow"
          />
        </el-form-item>
        
        <el-form-item label="实时跟踪">
          <el-switch v-model="queryParams.follow" />
        </el-form-item>
        
        <el-form-item v-if="wsConnected" label="自动滚动">
          <el-switch v-model="autoScroll" />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="loadLogs">
            {{ queryParams.follow ? (wsConnected ? '连接中...' : '开始实时跟踪') : '查询日志' }}
          </el-button>
          <el-button @click="clearLogs">清空</el-button>
          <el-button 
            v-if="wsConnected" 
            type="warning" 
            @click="sendCommand('pause')"
          >
            暂停
          </el-button>
          <el-button 
            v-if="wsConnected" 
            type="success" 
            @click="sendCommand('resume')"
          >
            恢复
          </el-button>
        </el-form-item>
      </el-form>
      
      <el-alert
        v-if="wsConnected"
        title="实时日志模式已启用"
        type="success"
        :closable="false"
        show-icon
        style="margin-bottom: 10px"
      >
        <template #default>
          正在实时接收容器 {{ containerId }} 的日志输出。您可以点击“暂停”按钮暂时停止接收日志。
        </template>
      </el-alert>
      
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
import { ref, reactive, onMounted, onUnmounted } from 'vue'
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

// WebSocket 相关
let ws: WebSocket | null = null
const wsConnected = ref(false)
const autoScroll = ref(true)

const queryParams = reactive<LogQueryParams>({
  containerId: containerId.value,
  lines: 100,
  follow: false
})

/**
 * 初始化 WebSocket 连接
 */
const initWebSocket = () => {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const host = window.location.host
  const wsUrl = `${protocol}//${host}/ws/logs/${containerId.value}`
  
  console.log('正在连接 WebSocket:', wsUrl)
  
  ws = new WebSocket(wsUrl)
  
  ws.onopen = () => {
    console.log('WebSocket 连接成功')
    wsConnected.value = true
    ElMessage.success('实时日志连接已建立')
  }
  
  ws.onmessage = (event) => {
    try {
      const message = JSON.parse(event.data)
      handleWebSocketMessage(message)
    } catch (error) {
      console.error('解析 WebSocket 消息失败:', error)
    }
  }
  
  ws.onerror = (error) => {
    console.error('WebSocket 错误:', error)
    ElMessage.error('实时日志连接出错')
  }
  
  ws.onclose = () => {
    console.log('WebSocket 连接关闭')
    wsConnected.value = false
    ElMessage.warning('实时日志连接已断开')
  }
}

/**
 * 处理 WebSocket 消息
 */
const handleWebSocketMessage = (message: any) => {
  const { type, content, lineNumber } = message
  
  switch (type) {
    case 'connected':
      console.log('服务器消息:', content)
      break
      
    case 'log':
      // 添加新日志行
      logsData.value.push({
        content,
        lineNumber: lineNumber || logsData.value.length + 1
      })
      
      // 限制日志行数，避免内存溢出（最多保留 10000 行）
      if (logsData.value.length > 10000) {
        logsData.value = logsData.value.slice(-10000)
      }
      
      // 自动滚动到底部
      if (autoScroll.value) {
        setTimeout(() => {
          scrollToBottom()
        }, 50)
      }
      break
      
    case 'error':
      console.error('服务器错误:', content)
      ElMessage.error(content)
      break
      
    case 'info':
      console.log('服务器信息:', content)
      ElMessage.info(content)
      break
      
    default:
      console.warn('未知消息类型:', type, message)
  }
}

/**
 * 关闭 WebSocket 连接
 */
const closeWebSocket = () => {
  if (ws) {
    ws.close()
    ws = null
    wsConnected.value = false
  }
}

/**
 * 发送控制命令到服务器
 */
const sendCommand = (command: string) => {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(command)
  }
}

const loadLogs = async () => {
  // 如果开启了实时跟踪，使用 WebSocket
  if (queryParams.follow) {
    if (wsConnected.value) {
      ElMessage.warning('实时日志已在运行中')
      return
    }
    
    // 清空现有日志
    logsData.value = []
    
    // 初始化 WebSocket 连接
    initWebSocket()
  } else {
    // 关闭 WebSocket 连接（如果存在）
    closeWebSocket()
    
    // 使用 HTTP 请求加载日志
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
  // 关闭 WebSocket 连接
  closeWebSocket()
  router.back()
}

// 组件卸载时关闭 WebSocket
onUnmounted(() => {
  closeWebSocket()
})

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
          transition: background-color 0.2s;
          
          &:hover {
            background-color: rgba(255, 255, 255, 0.05);
          }
          
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
