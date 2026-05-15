import request from '@/utils/request'
import type { ContainerInfo, LogQueryParams, LogLineVO, LogFileVO, ApiResponse } from '@/types'

export const getContainersApi = (): Promise<ApiResponse<ContainerInfo[]>> => {
  return request({
    url: '/docker/containers',
    method: 'get'
  })
}

export const getLogsApi = (data: LogQueryParams): Promise<ApiResponse<LogLineVO[]>> => {
  return request({
    url: '/docker/logs',
    method: 'post',
    data
  })
}

export const validateContainerApi = (containerId: string): Promise<ApiResponse<boolean>> => {
  return request({
    url: `/docker/containers/${containerId}/validate`,
    method: 'get'
  })
}

export const getLogFilesApi = (containerId: string): Promise<ApiResponse<LogFileVO[]>> => {
  return request({
    url: `/docker/containers/${containerId}/logs`,
    method: 'get'
  })
}

export const getWebSocketStatusApi = (): Promise<ApiResponse<{ activeConnections: number; wsUrl: string; devWsUrl: string }>> => {
  return request({
    url: '/docker/websocket/status',
    method: 'get'
  })
}
