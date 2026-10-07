import type { LetterState } from '../game/evaluate'

const ROWS = [
  ['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ'],
  ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
  ['enter', 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', 'backspace'],
]

interface Props {
  keyStates: Record<string, (LetterState | null)[]>
  boardCount: number
  onLetter: (letter: string) => void
  onEnter: () => void
  onBackspace: () => void
}

export function Keyboard({ keyStates, boardCount, onLetter, onEnter, onBackspace }: Props) {
  return (
    <div className="keyboard">
      {ROWS.map((row, r) => (
        <div className="keyboard__row" key={r}>
          {row.map((key) => {
            if (key === 'enter')
              return (
                <button className="key key--wide" key={key} onClick={onEnter}>
                  Ввод
                </button>
              )
            if (key === 'backspace')
              return (
                <button className="key key--wide" key={key} onClick={onBackspace} aria-label="Стереть">
                  ⌫
                </button>
              )
            const states = keyStates[key]
            const allAbsent = states?.every((s) => s === 'absent' || s === null) && states.some((s) => s)
            return (
              <button
                className={`key${allAbsent ? ' key--absent' : ''}`}
                key={key}
                onClick={() => onLetter(key)}
              >
                {states && !allAbsent && (
                  <span className="key__hints" aria-hidden>
                    {Array.from({ length: boardCount }, (_, i) => (
                      <span className={`key__hint key__hint--${states[i] ?? 'none'}`} key={i} />
                    ))}
                  </span>
                )}
                <span className="key__label">{key}</span>
              </button>
            )
          })}
        </div>
      ))}
    </div>
  )
}
