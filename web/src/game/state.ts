import { MAX_GUESSES } from './constants'
import { bestState, evaluateGuess, type LetterState } from './evaluate'

export type GameStatus = 'playing' | 'won' | 'lost'

export interface BoardView {
  answer: string
  solvedAt: number | null
  rows: { word: string; states: LetterState[] }[]
}

export function solvedAt(answer: string, guesses: string[]): number | null {
  const index = guesses.indexOf(answer)
  return index === -1 ? null : index
}

export function buildBoards(answers: string[], guesses: string[]): BoardView[] {
  return answers.map((answer) => {
    const solved = solvedAt(answer, guesses)
    const visible = solved === null ? guesses : guesses.slice(0, solved + 1)
    return {
      answer,
      solvedAt: solved,
      rows: visible.map((word) => ({ word, states: evaluateGuess(word, answer) })),
    }
  })
}

export function gameStatus(answers: string[], guesses: string[]): GameStatus {
  if (answers.length > 0 && answers.every((a) => guesses.includes(a))) return 'won'
  if (guesses.length >= MAX_GUESSES) return 'lost'
  return 'playing'
}

/** For every letter: its best known state on each board (null = unknown or board solved). */
export function keyboardStates(
  answers: string[],
  guesses: string[],
): Record<string, (LetterState | null)[]> {
  const result: Record<string, (LetterState | null)[]> = {}
  buildBoards(answers, guesses).forEach((board, boardIndex) => {
    if (board.solvedAt !== null) return
    board.rows.forEach(({ word, states }) => {
      ;[...word].forEach((letter, i) => {
        result[letter] ??= answers.map(() => null)
        result[letter][boardIndex] = bestState(result[letter][boardIndex], states[i])
      })
    })
  })
  return result
}
