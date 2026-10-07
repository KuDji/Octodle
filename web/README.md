# Осминогль — веб-версия

Веб-клиент игры «Осминогль»: 8 загаданных слов из 5 букв, 13 попыток. Использует тот же бэкенд, что и iOS-приложение (SwiftUI).

## Стек

Vite + React + TypeScript, Vitest, oxlint.

## Запуск

```bash
npm install
cp .env.example .env.local   # укажите VITE_API_BASE_URL, иначе используется мок
npm run dev
```

Команды: `npm run lint`, `npm test`, `npm run build`.

## Структура

- `src/api/` — контракт бэкенда (`OctodleApi`), HTTP-клиент и локальный мок.
- `src/game/` — игровая логика (оценка попыток, состояние досок, хук `useOctodle`).
- `src/components/` — доски и экранная клавиатура.
