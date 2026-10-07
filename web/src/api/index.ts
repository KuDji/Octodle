import { createHttpApi } from './httpApi'
import { mockApi } from './mockApi'
import type { OctodleApi } from './types'

const baseUrl = import.meta.env.VITE_API_BASE_URL as string | undefined

export const api: OctodleApi = baseUrl ? createHttpApi(baseUrl) : mockApi
export type { DailyGame, OctodleApi } from './types'
