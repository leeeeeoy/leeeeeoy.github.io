export type Page =
  'home' | 'portfolio' | 'lab' | 'writing' | 'notes' | 'not-found'

export const portfolioSections = ['experience', 'projects', 'skills'] as const

export function getPage(pathname: string): Page {
  const path = pathname === '/' ? '/' : pathname.replace(/\/$/, '')
  if (path === '/') return 'home'
  if (path === '/portfolio') return 'portfolio'
  if (path === '/lab') return 'lab'
  if (path === '/writing') return 'writing'
  if (path === '/notes' || /^\/notes\/[^/]+$/.test(path)) return 'notes'
  return 'not-found'
}

export function legacyPortfolioHref(
  pathname: string,
  search: string,
  hash: string,
  scrollTarget?: string | null,
) {
  if (
    pathname === '/' &&
    portfolioSections.some(
      (section) => hash === `#${section}` || scrollTarget === section,
    )
  ) {
    return `/portfolio/${search}${hash}`
  }
  return null
}
