
import type { AxiosInstance } from 'axios'
import request from '@/utils/http'

export default function useHttp(): AxiosInstance {
  return request.http
}
