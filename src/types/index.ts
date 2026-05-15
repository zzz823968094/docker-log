export interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
}

export interface UserInfo {
  username: string
  [key: string]: any
}

export interface LoginParams {
  username: string
  password: string
}

export interface LoginResult {
  token: string
  userInfo?: UserInfo
}

export interface ContainerInfo {
  containerId: string
  containerName: string
  status: string
  imageName: string
}

export interface LogQueryParams {
  containerId: string
  lines?: number
  follow?: boolean
  since?: string
  until?: string
}

export interface LogLineVO {
  content: string
  lineNumber: number
}

export interface LogFileVO {
  fileName: string
  fileSize: number
  fileSizeFormatted: string
  lastModified: number
  lastModifiedFormatted: string
  isActive: boolean
}
