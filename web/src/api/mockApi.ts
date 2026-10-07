import { BOARD_COUNT, WORD_LENGTH } from '../game/constants'
import { isCyrillicLetter } from '../game/normalize'
import { MOCK_ANSWERS } from './mockWords'
import type { DailyGame, OctodleApi } from './types'

function seededRandom(seed: number): () => number {
  let state = seed
  return () => {
    state = (state * 1664525 + 1013904223) % 4294967296
    return state / 4294967296
  }
}

function pickAnswers(seed: number): string[] {
  const random = seededRandom(seed)
  const pool = [...MOCK_ANSWERS]
  const answers: string[] = []
  while (answers.length < BOARD_COUNT && pool.length > 0) {
    answers.push(pool.splice(Math.floor(random() * pool.length), 1)[0])
  }
  return answers
}

/** Local stand-in for the backend until real endpoints are wired in. */
export const mockApi: OctodleApi = {
  async getDailyGame(): Promise<DailyGame> {
    const id = new Date().toISOString().slice(0, 10)
    return { id, answers: pickAnswers(Number(id.replaceAll('-', ''))) }
  },
  async isValidWord(word: string): Promise<boolean> {
    return [...word].length === WORD_LENGTH && [...word].every(isCyrillicLetter)
  },
}
