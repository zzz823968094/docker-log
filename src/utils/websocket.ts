/**
 * WebSocket 消息类型定义
 */
export interface WebSocketMessage {
  type: 'connected' | 'log' | 'error' | 'info'
  content: string
  timestamp: number
  lineNumber?: number
}

/**
 * WebSocket 回调函数类型
 */
export interface WebSocketCallbacks {
  onOpen?: () => void
  onMessage?: (message: WebSocketMessage) => void
  onError?: (error: Event) => void
  onClose?: () => void
}

/**
 * WebSocket 客户端封装类
 * 遵循阿里云前端开发规范
 */
export class WebSocketClient {
  private ws: WebSocket | null = null
  private url: string
  private callbacks: WebSocketCallbacks
  private reconnectTimer: number | null = null
  private reconnectAttempts = 0
  private maxReconnectAttempts = 5
  private reconnectDelay = 3000

  constructor(url: string, callbacks: WebSocketCallbacks) {
    this.url = url
    this.callbacks = callbacks
  }

  /**
   * 连接 WebSocket
   */
  connect(): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      console.warn('WebSocket 已经连接')
      return
    }

    try {
      this.ws = new WebSocket(this.url)
      this.setupEventHandlers()
    } catch (error) {
      console.error('WebSocket 连接失败:', error)
      this.handleReconnect()
    }
  }

  /**
   * 设置事件处理器
   */
  private setupEventHandlers(): void {
    if (!this.ws) return

    this.ws.onopen = () => {
      console.log('WebSocket 连接成功')
      this.reconnectAttempts = 0
      this.callbacks.onOpen?.()
    }

    this.ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data)
        this.callbacks.onMessage?.(message)
      } catch (error) {
        console.error('解析 WebSocket 消息失败:', error)
      }
    }

    this.ws.onerror = (error) => {
      console.error('WebSocket 错误:', error)
      this.callbacks.onError?.(error)
    }

    this.ws.onclose = () => {
      console.log('WebSocket 连接关闭')
      this.callbacks.onClose?.()
      this.handleReconnect()
    }
  }

  /**
   * 发送消息
   */
  send(message: string): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(message)
    } else {
      console.warn('WebSocket 未连接，无法发送消息')
    }
  }

  /**
   * 关闭连接
   */
  close(): void {
    this.stopReconnect()
    
    if (this.ws) {
      this.ws.close()
      this.ws = null
    }
  }

  /**
   * 获取连接状态
   */
  isConnected(): boolean {
    return this.ws !== null && this.ws.readyState === WebSocket.OPEN
  }

  /**
   * 获取就绪状态
   */
  getReadyState(): number {
    return this.ws ? this.ws.readyState : WebSocket.CLOSED
  }

  /**
   * 处理重连逻辑
   */
  private handleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('达到最大重连次数，停止重连')
      return
    }

    this.stopReconnect()

    this.reconnectAttempts++
    console.log(`尝试重连 (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`)

    this.reconnectTimer = window.setTimeout(() => {
      this.connect()
    }, this.reconnectDelay * this.reconnectAttempts)
  }

  /**
   * 停止重连
   */
  private stopReconnect(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = null
    }
  }
}
