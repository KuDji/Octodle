import { describe, expect, it } from 'vitest'
import { MAX_GUESSES } from './constants'
import { buildBoards, gameStatus, keyboardStates } from './state'

const answers = ['слово', 'буква']

describe('game state', () => {
  it('stops showing rows on a board once it is solved', () => {
    const boards = buildBoards(answers, ['слово', 'буква'])
    expect(boards[0].solvedAt).toBe(0)
    expect(boards[0].rows).toHaveLength(1)
    expect(boards[1].rows).toHaveLength(2)
  })

  it('is won when every answer is guessed', () => {
    expect(gameStatus(answers, ['слово'])).toBe('playing')
    expect(gameStatus(answers, ['слово', 'буква'])).toBe('won')
  })

  it('is lost after the last guess', () => {
    expect(gameStatus(answers, Array(MAX_GUESSES).fill('мимоо'))).toBe('lost')
  })

  it('ignores solved boards in keyboard hints', () => {
    const states = keyboardStates(answers, ['слово'])
    expect(states['с']).toEqual([null, 'absent'])
  })
})
