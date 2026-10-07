import { describe, expect, it } from 'vitest'
import { evaluateGuess } from './evaluate'
import { normalizeWord } from './normalize'

describe('evaluateGuess', () => {
  it('marks exact matches as correct', () => {
    expect(evaluateGuess('слово', 'слово')).toEqual(Array(5).fill('correct'))
  })

  it('marks misplaced letters as present', () => {
    expect(evaluateGuess('волос', 'слово')).toEqual([
      'present', 'present', 'present', 'present', 'present',
    ])
  })

  it('does not over-count duplicate letters', () => {
    // answer has a single "а": only the first misplaced "а" is present
    expect(evaluateGuess('ааааб', 'бочка')).toEqual([
      'present', 'absent', 'absent', 'absent', 'present',
    ])
  })

  it('prefers correct over present for duplicates', () => {
    expect(evaluateGuess('кошка', 'кукла')).toEqual([
      'correct', 'absent', 'absent', 'present', 'correct',
    ])
  })
})

describe('normalizeWord', () => {
  it('lowercases and replaces ё with е', () => {
    expect(normalizeWord('ЁЛКА')).toBe('елка')
  })
})
