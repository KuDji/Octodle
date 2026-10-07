import { MAX_GUESSES, WORD_LENGTH } from '../game/constants'
import type { BoardView } from '../game/state'

interface Props {
  board: BoardView
  index: number
  current: string
  showAnswer: boolean
}

export function Board({ board, index, current, showAnswer }: Props) {
  const solved = board.solvedAt !== null
  const rows = [...board.rows.map((row) => ({ ...row, typed: false }))]
  if (!solved && rows.length < MAX_GUESSES) {
    rows.push({ word: current, states: [], typed: true })
  }
  while (rows.length < MAX_GUESSES) rows.push({ word: '', states: [], typed: false })

  return (
    <section className={`board${solved ? ' board--solved' : ''}`} aria-label={`Поле ${index + 1}`}>
      {rows.map((row, r) => (
        <div className="board__row" key={r}>
          {Array.from({ length: WORD_LENGTH }, (_, c) => {
            const letter = [...row.word][c] ?? ''
            const state = row.states[c] ?? (row.typed && letter ? 'typed' : 'empty')
            return (
              <div className={`cell cell--${state}`} key={c}>
                {letter}
              </div>
            )
          })}
        </div>
      ))}
      {showAnswer && !solved && <div className="board__answer">{board.answer}</div>}
    </section>
  )
}
