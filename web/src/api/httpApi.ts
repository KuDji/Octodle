import type { DailyGame, OctodleApi } from './types'

// TODO: replace paths and payloads with the exact requests used by the iOS app.
export function createHttpApi(baseUrl: string): OctodleApi {
  async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const response = await fetch(`${baseUrl}${path}`, {
      ...init,
      headers: { 'Content-Type': 'application/json', ...init?.headers },
    })
    if (!response.ok) throw new Error(`${init?.method ?? 'GET'} ${path}: ${response.status}`)
    return response.json() as Promise<T>
  }

  return {
    getDailyGame: () => request<DailyGame>('/daily'),
    isValidWord: async (word) =>
      (await request<{ valid: boolean }>(`/words/${encodeURIComponent(word)}`)).valid,
  }
}
