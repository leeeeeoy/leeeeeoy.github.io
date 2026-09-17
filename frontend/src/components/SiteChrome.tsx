import { useRef, type MouseEvent } from 'react'
import { content, language, ui, localizedHref } from '../content'

export const SCROLL_TARGET_KEY = 'portfolio-scroll-target'

export const externalLinkProps = {
  target: '_blank',
  rel: 'noreferrer',
} as const

export function Arrow() {
  return <span className="external-arrow" aria-hidden="true">↗</span>
}

function ThemeIcon({ theme }: { theme: 'light' | 'dark' }) {
  return theme === 'light' ? (
    <svg className="header-icon" viewBox="0 0 24 24" aria-hidden="true">
      <path d="M20.4 15.7A9 9 0 0 1 8.3 3.6 9 9 0 1 0 20.4 15.7Z" />
    </svg>
  ) : (
    <svg className="header-icon" viewBox="0 0 24 24" aria-hidden="true">
      <circle cx="12" cy="12" r="4" />
      <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
    </svg>
  )
}

function navigateToSection(event: MouseEvent<HTMLAnchorElement>, section: string) {
  if (window.location.pathname === '/') {
    event.preventDefault()
    document.getElementById(section)?.scrollIntoView()
    return
  }

  try {
    sessionStorage.setItem(SCROLL_TARGET_KEY, section)
  } catch {
    // Navigating home still works when browser storage is unavailable.
  }
}

export function SiteHeader({
  theme,
  onToggleTheme,
}: {
  theme: 'light' | 'dark'
  onToggleTheme: () => void
}) {
  return (
    <header className="site-header">
      <a className="brand" href={localizedHref("/")} aria-label={ui.home}>
        Y<span>.</span>
      </a>
      <nav aria-label={ui.navigation}>
        <a href={localizedHref("/")} onClick={(event) => navigateToSection(event, 'experience')}>
          Experience
        </a>
        <a href={localizedHref("/")} onClick={(event) => navigateToSection(event, 'projects')}>
          Projects
        </a>
        <a href={localizedHref("/")} onClick={(event) => navigateToSection(event, 'skills')}>
          Skills
        </a>
      </nav>
      <div className="header-actions">
        <a
          className="header-link language-switch"
          href={localizedHref(window.location.pathname + window.location.search + window.location.hash, language === 'ko' ? 'en' : 'ko')}
          hrefLang={language === 'ko' ? 'en' : 'ko'}
          lang={language === 'ko' ? 'en' : 'ko'}
          aria-label={language === 'ko' ? 'Read in English' : '한국어로 보기'}
        >
          {language === 'ko' ? 'EN' : '한국어'}
        </a>
        <a className="header-link" href={localizedHref("/notes/")}>
          Notes
        </a>
        <button
          className="theme-toggle"
          type="button"
          aria-label={theme === 'light' ? ui.darkTheme : ui.lightTheme}
          onClick={onToggleTheme}
        >
          <ThemeIcon theme={theme} />
          <span className="header-action-label">
            {theme === 'light' ? 'Dark' : 'Light'}
          </span>
        </button>
        <a
          className="header-link"
          href={content.profile.links[0].url}
          {...externalLinkProps}
        >
          <img
            className="header-icon"
            src="/brand/github-invertocat-white.svg"
            width="16"
            height="16"
            alt=""
          />
          <span className="header-action-label">GitHub</span>
          <Arrow />
        </a>
      </div>
    </header>
  )
}

export function SiteFooter({
  onOpenConsent,
}: {
  onOpenConsent: () => void
}) {
  const architectureDialog = useRef<HTMLDialogElement>(null)

  return (
    <footer>
      <div className="footer-intro">
        <p className="eyebrow">LET&apos;S BUILD SOMETHING USEFUL</p>
        <h2>
          {ui.footerHeading}
        </h2>
        <button
          className="cloudflare-badge"
          type="button"
          aria-haspopup="dialog"
          aria-controls="architecture-dialog"
          onClick={() => architectureDialog.current?.showModal()}
        >
          <img
            src="/brand/built-with-cloudflare.svg"
            width="184"
            height="39"
            alt="Built with Cloudflare"
          />
        </button>
      </div>
      <div className="footer-meta">
        <address className="footer-contact">
          <strong>{content.profile.name}</strong>
          <span>{content.profile.role}</span>
          <a href={`mailto:${content.profile.email}`}>{content.profile.email}</a>
        </address>
        <div className="footer-links">
          {content.profile.links.map((link) => (
            <a key={link.url} href={link.url} {...externalLinkProps}>
              {link.label} <Arrow />
            </a>
          ))}
        </div>
        <div className="footer-privacy">
          <p>{ui.privacyNote}</p>
          <div className="footer-privacy-actions">
            <button type="button" onClick={onOpenConsent}>
              {ui.analyticsSettings}
            </button>
            <a
              href="https://www.microsoft.com/privacy/privacystatement"
              {...externalLinkProps}
            >
              {ui.privacyPolicy} <Arrow />
            </a>
          </div>
        </div>
        <p>© {new Date().getFullYear()} {content.profile.name}</p>
      </div>
      <dialog
        id="architecture-dialog"
        className="architecture-dialog"
        ref={architectureDialog}
        aria-labelledby="architecture-title"
      >
        <form method="dialog">
          <button className="architecture-dialog__close" type="submit">
            {ui.close}
          </button>
        </form>
        <p className="eyebrow">HOW THIS SITE WORKS</p>
        <h2 id="architecture-title">{ui.architectureTitle}</h2>
        <p className="architecture-dialog__intro">
          {ui.architectureIntro}
        </p>
        <div
          className="site-architecture"
          role="img"
          aria-label={ui.architectureAlt}
        >
          <div className="architecture-node">
            <strong>{ui.browser}</strong>
            <span>Desktop · Mobile</span>
          </div>
          <span className="architecture-arrow" aria-hidden="true">↓</span>
          <div className="architecture-node architecture-node--primary">
            <strong>Cloudflare Pages</strong>
            <span>{ui.staticContent}</span>
          </div>
          <span className="architecture-arrow" aria-hidden="true">{ui.r2Reference}</span>
          <div className="architecture-node">
            <strong>Cloudflare R2</strong>
            <span>{ui.publicImages}</span>
          </div>
        </div>
        <div className="architecture-ci" aria-label={ui.deploymentFlow}>
          <span>GitHub Actions</span>
          <b aria-hidden="true">→</b>
          <span>Test · Typecheck · Build</span>
          <b aria-hidden="true">→</b>
          <span>Pages Deploy</span>
        </div>
        <p className="architecture-dialog__legacy">
          {ui.architectureLegacy}
        </p>
        <a
          className="architecture-dialog__link"
          href="https://github.com/leeeeeoy/leeeeeoy.github.io"
          {...externalLinkProps}
        >
          {ui.source} <Arrow />
        </a>
      </dialog>
    </footer>
  )
}
