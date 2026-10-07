const CYRILLIC_LETTER = /^[а-яё]$/

export function normalizeLetter(letter: string): string {
  return letter.toLowerCase().replace('ё', 'е')
}

export function normalizeWord(word: string): string {
  return [...word].map(normalizeLetter).join('')
}

export function isCyrillicLetter(key: string): boolean {
  return CYRILLIC_LETTER.test(key.toLowerCase())
}

// Lets players without a Russian layout type via physical key positions (ЙЦУКЕН).
const CODE_TO_CYRILLIC: Record<string, string> = {
  KeyQ: 'й', KeyW: 'ц', KeyE: 'у', KeyR: 'к', KeyT: 'е', KeyY: 'н',
  KeyU: 'г', KeyI: 'ш', KeyO: 'щ', KeyP: 'з', BracketLeft: 'х', BracketRight: 'ъ',
  KeyA: 'ф', KeyS: 'ы', KeyD: 'в', KeyF: 'а', KeyG: 'п', KeyH: 'р',
  KeyJ: 'о', KeyK: 'л', KeyL: 'д', Semicolon: 'ж', Quote: 'э',
  KeyZ: 'я', KeyX: 'ч', KeyC: 'с', KeyV: 'м', KeyB: 'и', KeyN: 'т',
  KeyM: 'ь', Comma: 'б', Period: 'ю',
}

export function letterFromKeyboardEvent(key: string, code: string): string | null {
  if (isCyrillicLetter(key)) return normalizeLetter(key)
  return CODE_TO_CYRILLIC[code] ?? null
}
