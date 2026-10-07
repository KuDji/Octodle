import { useEffect } from 'react'
import { api } from './api'
import { Board } from './components/Board'
import { Keyboard } from './components/Keyboard'
import { BOARD_COUNT, MAX_GUESSES } from './game/constants'
import { letterFromKeyboardEvent } from './game/normalize'
import { useOctodle } from './game/useOctodle'
import './App.css'

export default function App() {
  const game = useOctodle(api)
  const { addLetter, removeLetter, submit } = game

  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.ctrlKey || event.metaKey || event.altKey) return
      const letter = letterFromKeyboardEvent(event.key, event.code)
      if (event.key !== 'Enter' && event.key !== 'Backspace' && !letter) return
      // Keeps Enter from also "clicking" a focused on-screen key.
      event.preventDefault()
      if (event.key === 'Enter') void submit()
      else if (event.key === 'Backspace') removeLetter()
      else if (letter) addLetter(letter)
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [addLetter, removeLetter, submit])

  if (game.loadError) return <p className="status">Ошибка загрузки: {game.loadError}</p>
  if (game.loading) return <p className="status">Загрузка…</p>

  const solvedCount = game.boards.filter((b) => b.solvedAt !== null).length

  return (
    <div className="app">
      <header className="header">
        <h1>Осминогль</h1>
        <div className="header__stats">
          Попытка {Math.min(game.guesses.length + 1, MAX_GUESSES)}/{MAX_GUESSES} · Отгадано{' '}
          {solvedCount}/{game.answers.length}
        </div>
      </header>

      {game.message && <div className="toast">{game.message}</div>}
      {game.status !== 'playing' && (
        <div className="result">
          {game.status === 'won'
            ? `Победа! Все слова отгаданы за ${game.guesses.length} попыток`
            : 'Попытки закончились'}
        </div>
      )}

      <main className="boards">
        {game.boards.map((board, i) => (
          <Board
            key={i}
            index={i}
            board={board}
            current={game.current}
            showAnswer={game.status === 'lost'}
          />
        ))}
      </main>

      <Keyboard
        keyStates={game.keyStates}
        boardCount={BOARD_COUNT}
        onLetter={addLetter}
        onEnter={() => void submit()}
        onBackspace={removeLetter}
      />
    </div>
  )
}
