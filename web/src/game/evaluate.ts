export type LetterState = 'correct' | 'present' | 'absent'

const STATE_RANK: Record<LetterState, number> = { absent: 0, present: 1, correct: 2 }

export function evaluateGuess(guess: string, answer: string): LetterState[] {
  const guessLetters = [...guess]
  const answerLetters = [...answer]
  const result: LetterState[] = guessLetters.map(() => 'absent')
  const remaining = new Map<string, number>()

  guessLetters.forEach((letter, i) => {
    if (letter === answerLetters[i]) {
      result[i] = 'correct'
    } else {
      remaining.set(answerLetters[i], (remaining.get(answerLetters[i]) ?? 0) + 1)
    }
  })

  guessLetters.forEach((letter, i) => {
    if (result[i] === 'correct') return
    const count = remaining.get(letter) ?? 0
    if (count > 0) {
      result[i] = 'present'
      remaining.set(letter, count - 1)
    }
  })

  return result
}

export function bestState(a: LetterState | null, b: LetterState): LetterState {
  return a === null || STATE_RANK[b] > STATE_RANK[a] ? b : a
}
