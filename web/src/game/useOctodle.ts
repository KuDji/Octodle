import { useCallback, useEffect, useMemo, useState } from 'react'
import type { DailyGame, OctodleApi } from '../api'
import { WORD_LENGTH } from './constants'
import { normalizeWord } from './normalize'
import { buildBoards, gameStatus, keyboardStates } from './state'

const storageKey = (gameId: string) => `octodle:${gameId}`

function loadGuesses(gameId: string): string[] {
  try {
    const saved = JSON.parse(localStorage.getItem(storageKey(gameId)) ?? '[]')
    return Array.isArray(saved) ? saved : []
  } catch {
    return []
  }
}

export function useOctodle(api: OctodleApi) {
  const [game, setGame] = useState<DailyGame | null>(null)
  const [guesses, setGuesses] = useState<string[]>([])
  const [current, setCurrent] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    let cancelled = false
    api
      .getDailyGame()
      .then((daily) => {
        if (cancelled) return
        const normalized = { ...daily, answers: daily.answers.map(normalizeWord) }
        setGame(normalized)
        setGuesses(loadGuesses(normalized.id))
      })
      .catch((error: unknown) => {
        if (!cancelled) setLoadError(error instanceof Error ? error.message : String(error))
      })
    return () => {
      cancelled = true
    }
  }, [api])

  useEffect(() => {
    if (game) localStorage.setItem(storageKey(game.id), JSON.stringify(guesses))
  }, [game, guesses])

  useEffect(() => {
    if (!message) return
    const timer = setTimeout(() => setMessage(null), 2000)
    return () => clearTimeout(timer)
  }, [message])

  const answers = useMemo(() => game?.answers ?? [], [game])
  const status = gameStatus(answers, guesses)
  const boards = useMemo(() => buildBoards(answers, guesses), [answers, guesses])
  const keyStates = useMemo(() => keyboardStates(answers, guesses), [answers, guesses])

  const addLetter = useCallback(
    (letter: string) => {
      if (status !== 'playing' || submitting) return
      setCurrent((word) => ([...word].length < WORD_LENGTH ? word + letter : word))
    },
    [status, submitting],
  )

  const removeLetter = useCallback(() => {
    if (submitting) return
    setCurrent((word) => [...word].slice(0, -1).join(''))
  }, [submitting])

  const submit = useCallback(async () => {
    if (status !== 'playing' || submitting) return
    if ([...current].length < WORD_LENGTH) {
      setMessage('Недостаточно букв')
      return
    }
    setSubmitting(true)
    try {
      if (!(await api.isValidWord(current))) {
        setMessage('Такого слова нет в словаре')
        return
      }
      setGuesses((list) => [...list, current])
      setCurrent('')
    } catch {
      setMessage('Не удалось проверить слово')
    } finally {
      setSubmitting(false)
    }
  }, [api, current, status, submitting])

  return {
    loading: !game && !loadError,
    loadError,
    answers,
    guesses,
    current,
    status,
    boards,
    keyStates,
    message,
    addLetter,
    removeLetter,
    submit,
  }
}
