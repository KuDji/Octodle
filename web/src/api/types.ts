export interface DailyGame {
  /** Stable id used to persist progress (e.g. date or server game id). */
  id: string
  answers: string[]
}

/**
 * Backend contract. Must mirror the requests made by the iOS (SwiftUI) app.
 */
export interface OctodleApi {
  getDailyGame(): Promise<DailyGame>
  isValidWord(word: string): Promise<boolean>
}
