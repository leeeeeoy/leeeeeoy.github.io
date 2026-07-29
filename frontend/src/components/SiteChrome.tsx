import content from '../content.json'

export const externalLinkProps = {
  target: '_blank',
  rel: 'noreferrer',
} as const

export function Arrow() {
  return <span aria-hidden="true">↗</span>
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
      <a className="brand" href="/" aria-label="홈으로">
        Y<span>.</span>
      </a>
      <nav aria-label="주요 메뉴">
        <a href="/#experience">Experience</a>
        <a href="/#projects">Projects</a>
        <a href="/#skills">Skills</a>
      </nav>
      <div className="header-actions">
        <a className="header-link" href="/notes/">
          Notes
        </a>
        <button
          className="theme-toggle"
          type="button"
          aria-label={theme === 'light' ? '다크 테마로 전환' : '라이트 테마로 전환'}
          onClick={onToggleTheme}
        >
          {theme === 'light' ? 'Dark' : 'Light'}
        </button>
        <a
          className="header-link"
          href={content.profile.links[0].url}
          {...externalLinkProps}
        >
          GitHub <Arrow />
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
  return (
    <footer>
      <div>
        <p className="eyebrow">LET&apos;S BUILD SOMETHING USEFUL</p>
        <h2>복잡한 문제를<br />함께 단순하게.</h2>
      </div>
      <div className="footer-meta">
        <div>
          {content.profile.links.map((link) => (
            <a key={link.url} href={link.url} {...externalLinkProps}>
              {link.label} <Arrow />
            </a>
          ))}
        </div>
        <div className="footer-privacy">
          <p>허용한 경우에만 Microsoft Clarity로 사용 패턴을 분석합니다.</p>
          <button type="button" onClick={onOpenConsent}>
            분석 설정
          </button>
          <a
            href="https://www.microsoft.com/privacy/privacystatement"
            {...externalLinkProps}
          >
            Microsoft 개인정보 처리방침 <Arrow />
          </a>
        </div>
        <p>© {new Date().getFullYear()} {content.profile.name}</p>
      </div>
    </footer>
  )
}
