import translations from './content.json'

export type Language = 'ko' | 'en'

export function getLanguage(search: string): Language {
  return new URLSearchParams(search).get('lang') === 'en' ? 'en' : 'ko'
}

export const language = getLanguage(window.location.search)
export const content = translations[language]
export const ui = content.ui

export function localizedHref(path: string, target: Language = language) {
  const url = new URL(path, window.location.origin)
  if (target === 'en') url.searchParams.set('lang', 'en')
  else url.searchParams.delete('lang')
  return url.pathname + url.search + url.hash
}

export function applyLanguageMetadata() {
  document.documentElement.lang = language
  for (const selector of [
    'meta[name="description"]',
    'meta[property="og:description"]',
    'meta[name="twitter:description"]',
  ]) {
    document.querySelector(selector)?.setAttribute('content', ui.metaDescription)
  }
  for (const selector of ['meta[property="og:image:alt"]', 'meta[name="twitter:image:alt"]']) {
    document.querySelector(selector)?.setAttribute('content', ui.imageAlt)
  }
  document.querySelector('meta[property="og:locale"]')
    ?.setAttribute('content', language === 'en' ? 'en_US' : 'ko_KR')
}
