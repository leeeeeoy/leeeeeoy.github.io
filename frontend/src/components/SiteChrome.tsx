import { useRef, type MouseEvent } from 'react'
import content from '../content.json'

export const SCROLL_TARGET_KEY = 'portfolio-scroll-target'

export const externalLinkProps = {
  target: '_blank',
  rel: 'noreferrer',
} as const

export function Arrow() {
  return <span aria-hidden="true">↗</span>
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
      <a className="brand" href="/" aria-label="홈으로">
        Y<span>.</span>
      </a>
      <nav aria-label="주요 메뉴">
        <a href="/" onClick={(event) => navigateToSection(event, 'experience')}>
          Experience
        </a>
        <a href="/" onClick={(event) => navigateToSection(event, 'projects')}>
          Projects
        </a>
        <a href="/" onClick={(event) => navigateToSection(event, 'skills')}>
          Skills
        </a>
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
  const architectureDialog = useRef<HTMLDialogElement>(null)

  return (
    <footer>
      <div>
        <p className="eyebrow">LET&apos;S BUILD SOMETHING USEFUL</p>
        <h2>복잡한 문제를<br />함께 단순하게.</h2>
      </div>
      <div className="footer-meta">
        <address className="footer-contact">
          <strong>{content.profile.name}</strong>
          <span>{content.profile.role}</span>
          <a href={`mailto:${content.profile.email}`}>{content.profile.email}</a>
        </address>
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
        <button
          className="footer-architecture-trigger"
          type="button"
          onClick={() => architectureDialog.current?.showModal()}
        >
          How this site works <Arrow />
        </button>
        <p>© {new Date().getFullYear()} {content.profile.name}</p>
      </div>
      <dialog
        className="architecture-dialog"
        ref={architectureDialog}
        aria-labelledby="architecture-title"
      >
        <form method="dialog">
          <button className="architecture-dialog__close" type="submit">
            닫기
          </button>
        </form>
        <p className="eyebrow">HOW THIS SITE WORKS</p>
        <h2 id="architecture-title">작게 유지한<br />포트폴리오 구조</h2>
        <p className="architecture-dialog__intro">
          공개 콘텐츠는 빌드에 포함하고, 브라우저에서 API를 호출하지 않아
          로딩과 실패 지점을 줄였습니다.
        </p>
        <div
          className="site-architecture"
          role="img"
          aria-label="사용자 브라우저가 Cloudflare Pages의 React 정적 앱을 열고 앱이 R2의 공개 이미지를 불러오는 구조"
        >
          <div className="architecture-node">
            <strong>사용자 브라우저</strong>
            <span>Desktop · Mobile</span>
          </div>
          <span className="architecture-arrow" aria-hidden="true">↓</span>
          <div className="architecture-node architecture-node--primary">
            <strong>Cloudflare Pages</strong>
            <span>React · Vite · 정적 콘텐츠</span>
          </div>
          <span className="architecture-arrow" aria-hidden="true">↓ R2 URL 참조</span>
          <div className="architecture-node">
            <strong>Cloudflare R2</strong>
            <span>공개 프로젝트 이미지</span>
          </div>
        </div>
        <div className="architecture-ci" aria-label="배포 흐름">
          <span>GitHub Actions</span>
          <b aria-hidden="true">→</b>
          <span>Test · Typecheck · Build</span>
          <b aria-hidden="true">→</b>
          <span>Pages Deploy</span>
        </div>
        <p className="architecture-dialog__legacy">
          Workers와 D1은 이전 API를 정리하기 전까지 보존하고 있으며,
          현재 Frontend 요청 경로에서는 사용하지 않습니다.
        </p>
        <a
          className="architecture-dialog__link"
          href="https://github.com/leeeeeoy/leeeeeoy.github.io"
          {...externalLinkProps}
        >
          GitHub에서 소스 보기 <Arrow />
        </a>
      </dialog>
    </footer>
  )
}
