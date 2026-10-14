import translations from './content.json'
import { getPage } from './routes'

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
  const page = getPage(window.location.pathname)
  const [label, description] = {
    home: [ui.navHome, ui.siteDescription],
    portfolio: [ui.navPortfolio, ui.metaDescription],
    lab: [ui.navLab, ui.labIntro],
    writing: [ui.navWriting, ui.writingIntro],
    notes: ['Notes', ui.notesIntro],
    'not-found': [ui.pageMissing, ui.siteDescription],
  }[page]
  const title = `${content.profile.name} — ${label}`
  document.title = title
  document.documentElement.lang = language
  for (const selector of [
    'meta[name="description"]',
    'meta[property="og:description"]',
    'meta[name="twitter:description"]',
  ]) {
    document.querySelector(selector)?.setAttribute('content', description)
  }
  for (const selector of [
    'meta[property="og:title"]',
    'meta[name="twitter:title"]',
  ]) {
    document.querySelector(selector)?.setAttribute('content', title)
  }
  const path =
    page === 'home' || page === 'not-found'
      ? '/'
      : `${window.location.pathname.replace(/\/$/, '')}/`
  const canonical = `https://leeeeeoy.xyz${path}`
  document
    .querySelector('link[rel="canonical"]')
    ?.setAttribute('href', canonical)
  document
    .querySelector('meta[property="og:url"]')
    ?.setAttribute('content', canonical)
  for (const selector of [
    'meta[property="og:image:alt"]',
    'meta[name="twitter:image:alt"]',
  ]) {
    document.querySelector(selector)?.setAttribute('content', ui.imageAlt)
  }
  document
    .querySelector('meta[property="og:locale"]')
    ?.setAttribute('content', language === 'en' ? 'en_US' : 'ko_KR')
}
