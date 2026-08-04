import { useEffect, useState } from 'react'
import { SiteFooter, SiteHeader } from './components/SiteChrome'
import NotesPage from './pages/NotesPage'
import PortfolioPage from './pages/PortfolioPage'

const CLARITY_PROJECT_ID = 'xti7rw64s1'
const CLARITY_CONSENT_KEY = 'portfolio-clarity-consent'
const THEME_KEY = 'portfolio-theme'
const PRODUCTION_HOST = 'portfolio.leeeeeoy.xyz'

type Consent = 'granted' | 'denied'
type Theme = 'light' | 'dark'
type Clarity = ((command: string, options?: Record<string, string>) => void) & {
  q?: unknown[][]
}

declare global {
  interface Window {
    clarity?: Clarity
  }
}

function loadClarity() {
  if (
    window.location.hostname !== PRODUCTION_HOST ||
    document.querySelector('script[data-clarity]')
  ) {
    return
  }

  window.clarity ??= (...args: unknown[]) => {
    window.clarity!.q ??= []
    window.clarity!.q!.push(args)
  }
  window.clarity('consentv2', {
    ad_Storage: 'denied',
    analytics_Storage: 'granted',
  })

  const script = document.createElement('script')
  script.async = true
  script.dataset.clarity = CLARITY_PROJECT_ID
  script.src = `https://www.clarity.ms/tag/${CLARITY_PROJECT_ID}`
  document.head.append(script)
}

function getSavedConsent(): Consent | null {
  try {
    const consent = localStorage.getItem(CLARITY_CONSENT_KEY)
    return consent === 'granted' || consent === 'denied' ? consent : null
  } catch {
    return null
  }
}

function applyTheme(theme: Theme) {
  document.documentElement.dataset.theme = theme
  document.documentElement.style.colorScheme = theme
  document
    .querySelector('meta[name="theme-color"]')
    ?.setAttribute('content', theme === 'dark' ? '#000000' : '#ffffff')
}

export default function App() {
  const initialConsent = getSavedConsent()
  const [consent, setConsent] = useState<Consent | null>(initialConsent)
  const [showConsent, setShowConsent] = useState(initialConsent === null)
  const [theme, setTheme] = useState<Theme>(() =>
    document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light',
  )
  const [, section, noteSlug] = window.location.pathname.split('/')
  const isNotes = section === 'notes'

  useEffect(() => {
    if (consent === 'granted') loadClarity()
  }, [consent])

  useEffect(() => {
    const elements = document.querySelectorAll('[data-reveal]')
    if (
      window.matchMedia('(prefers-reduced-motion: reduce)').matches ||
      !('IntersectionObserver' in window)
    ) {
      elements.forEach((element) => element.classList.add('is-visible'))
      return
    }

    const observer = new IntersectionObserver(
      (entries) =>
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return
          entry.target.classList.add('is-visible')
          observer.unobserve(entry.target)
        }),
      { rootMargin: '0px 0px -8%', threshold: 0.12 },
    )

    elements.forEach((element) => observer.observe(element))
    return () => observer.disconnect()
  }, [])

  const chooseConsent = (nextConsent: Consent) => {
    try {
      localStorage.setItem(CLARITY_CONSENT_KEY, nextConsent)
    } catch {
      // The current-page choice still applies when browser storage is unavailable.
    }

    if (nextConsent === 'denied' && window.clarity) {
      window.clarity('consentv2', {
        ad_Storage: 'denied',
        analytics_Storage: 'denied',
      })
      window.location.reload()
      return
    }

    setConsent(nextConsent)
    setShowConsent(false)
  }

  const toggleTheme = () => {
    const nextTheme = theme === 'light' ? 'dark' : 'light'
    applyTheme(nextTheme)

    try {
      localStorage.setItem(THEME_KEY, nextTheme)
    } catch {
      // The current-page choice still applies when browser storage is unavailable.
    }

    setTheme(nextTheme)
  }

  return (
    <>
      <a className="skip-link" href="#content">
        본문으로 건너뛰기
      </a>

      <SiteHeader theme={theme} onToggleTheme={toggleTheme} />

      <main id="content">
        {isNotes ? <NotesPage slug={noteSlug} /> : <PortfolioPage />}
      </main>

      <SiteFooter onOpenConsent={() => setShowConsent(true)} />

      {showConsent && (
        <aside
          className="consent-banner"
          role="region"
          aria-labelledby="consent-title"
          aria-describedby="consent-description"
        >
          <div>
            <strong id="consent-title">사이트 사용성 분석</strong>
            <p id="consent-description">
              Microsoft Clarity로 클릭·스크롤 등 사용 패턴을 분석합니다.
              거부하면 불러오지 않습니다.
            </p>
          </div>
          <div className="consent-actions">
            <button type="button" onClick={() => chooseConsent('denied')}>
              거부
            </button>
            <button
              className="consent-accept"
              type="button"
              onClick={() => chooseConsent('granted')}
            >
              허용
            </button>
          </div>
        </aside>
      )}
    </>
  )
}
