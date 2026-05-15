import request from '@/utils/request'
import type { LoginParams, ApiResponse, LoginResult } from '@/types'

export const loginApi = (data: LoginParams): Promise<ApiResponse<LoginResult>> => {
  return request({
    url: '/auth/login',
    method: 'post',
    data
  })
}

export const logoutApi = (): Promise<ApiResponse> => {
  return request({
    url: '/auth/logout',
    method: 'post'
  })
}
