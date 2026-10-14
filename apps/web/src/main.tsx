import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { applyLanguageMetadata } from './content'
import { legacyPortfolioHref } from './routes'
import { SCROLL_TARGET_KEY } from './components/SiteChrome'
import './styles.css'

const { pathname, search, hash } = window.location
let scrollTarget: string | null = null
try {
  scrollTarget = sessionStorage.getItem(SCROLL_TARGET_KEY)
} catch {
  // Hash compatibility does not depend on browser storage.
}
const legacyTarget = legacyPortfolioHref(pathname, search, hash, scrollTarget)

if (legacyTarget) {
  window.location.replace(legacyTarget)
} else {
  applyLanguageMetadata()
  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
}
