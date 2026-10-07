# Осьминогль для iOS

Нативный клиент [octordle.ru](https://octordle.ru): 8 слов из 5 букв, 14 попыток, тот же бэкенд и те же слова дня, что на сайте.

Стек: SwiftUI, SwiftData, Observation, Swift Concurrency (`async`/`await`, без Combine). iOS 17+.

## Структура

| Путь | Что внутри |
| --- | --- |
| `OctodleKit/` | Swift-пакет без UI: слова дня, проверка попыток, подсказки для клавиатуры, счет, API-клиент. Собирается и тестируется и на macOS, и на Linux. |
| `Octodle/App` | Точка входа, `ModelContainer`. |
| `Octodle/Models` | SwiftData-модели: `SavedGame` (прогресс дня), `PlayerProfile` (uuid устройства). |
| `Octodle/Game` | `GameViewModel` (`@Observable`, `@MainActor`). |
| `Octodle/Views` | Поля, своя клавиатура с подсветкой букв, результат, рейтинг, статистика. |
| `project.yml` | Описание проекта для [XcodeGen](https://github.com/yonaskolb/XcodeGen); `Octodle.xcodeproj` генерируется из него. |

## Запуск

```sh
open Octodle.xcodeproj        # Xcode 16+, схема Octodle
```

После изменения `project.yml` или добавления/удаления файлов пересоберите проект: `brew install xcodegen && xcodegen generate`.

Тесты логики:

```sh
swift test --package-path OctodleKit
```

## Как устроена игра (как на сайте)

- **Номер дня:** `floor(unixSeconds / 86400) - 19612`, смена дня в 00:00 UTC.
- **Слова дня** генерируются на клиенте: генератор mulberry32 с seed = номер дня выбирает 8 слов из `easyWords` (в режиме «согра» — из `easyWords + hardWords`). Словарь `OctodleKit/Sources/OctodleKit/Resources/words.json` взят с сайта.
- **Счет:** за каждое слово `20 - номер попытки`, неугаданное слово — 0.

## API octordle.ru

Базовый URL `https://octordle.ru/api`, клиент — `OctordleAPI`.

| Метод | Когда вызывается |
| --- | --- |
| `POST /post_start` `{day, word, uuid}` | первая попытка дня |
| `POST /post_game` `{day, words, tries, score, uuid, mode}` → `{betterThan}` | конец игры |
| `GET /get_game_stat?game=<json>` → `{betterThan}` | повторный запрос процента, если результат уже отправлен |
| `GET /get_leader_board?day=&email=` | экран рейтинга |
| `GET /get_full_stat?uuid=&email=` | экран статистики |
| `GET /get_day_news?news_number=`, `POST /post_watched_news?uuid=` | новости (в UI пока нет) |
| `POST /login?uuid=&email=&name=` | привязка к Google-аккаунту (в UI пока нет) |
| `POST /send_word_offer` `{action, word, userName}` | предложить слово (в UI пока нет) |

Эндпоинты взяты из JS-бандла сайта. Формат ответов `post_start` и `send_word_offer` не проверен, поэтому клиент их не разбирает.
