import { useEffect, useState } from 'react'
import content from './content.json'

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

const externalLinkProps = {
  target: '_blank',
  rel: 'noreferrer',
} as const

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

function Arrow() {
  return <span aria-hidden="true">↗</span>
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

  useEffect(() => {
    if (consent === 'granted') loadClarity()
  }, [consent])

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

      <header className="site-header">
        <a className="brand" href="#top" aria-label="맨 위로">
          Y<span>.</span>
        </a>
        <nav aria-label="주요 메뉴">
          <a href="#experience">Experience</a>
          <a href="#projects">Projects</a>
          <a href="#skills">Skills</a>
        </nav>
        <div className="header-actions">
          <button
            className="theme-toggle"
            type="button"
            aria-label={theme === 'light' ? '다크 테마로 전환' : '라이트 테마로 전환'}
            onClick={toggleTheme}
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

      <main id="content">
        <section className="hero" id="top">
          <div className="hero-copy">
            <p className="eyebrow">{content.profile.eyebrow}</p>
            <h1>
              {content.profile.headline.split('\n').map((line) => (
                <span key={line}>{line}</span>
              ))}
            </h1>
            <p className="hero-intro">{content.profile.intro}</p>
            <div className="hero-links" aria-label="외부 링크">
              {content.profile.links.map((link) => (
                <a key={link.url} href={link.url} {...externalLinkProps}>
                  {link.label} <Arrow />
                </a>
              ))}
            </div>
          </div>
        </section>

        <section className="metric-strip" aria-label="대표 성과">
          {content.metrics.map((metric) => (
            <div key={metric.label}>
              <strong>{metric.value}</strong>
              <span>{metric.label}</span>
            </div>
          ))}
        </section>

        <section className="section" id="experience">
          <div className="section-heading">
            <p className="eyebrow">02 · EXPERIENCE</p>
            <h2>문제를 발견하고,<br />운영 가능한 답을 만듭니다.</h2>
          </div>
          <div className="timeline">
            {content.experiences.map((experience, index) => (
              <article className="experience" key={experience.company}>
                <div className="experience-index" aria-hidden="true">
                  {String(index + 1).padStart(2, '0')}
                </div>
                <div className="experience-main">
                  <div className="experience-title">
                    <div>
                      <h3>
                        <a
                          className="company-link"
                          href={experience.website}
                          aria-label={`${experience.company} 홈페이지 열기`}
                          {...externalLinkProps}
                        >
                          {experience.company} <Arrow />
                        </a>
                      </h3>
                      <p>{experience.role}</p>
                    </div>
                    <time>{experience.period}</time>
                  </div>
                  <p className="summary">{experience.summary}</p>
                  <div className="inline-metrics">
                    {experience.metrics.map((metric) => (
                      <span key={metric.label}>
                        <strong>{metric.value}</strong> {metric.label}
                      </span>
                    ))}
                  </div>
                  <details className="disclosure">
                    <summary>
                      <span>상세 성과</span>
                      <span className="disclosure-action" aria-hidden="true" />
                    </summary>
                    <div className="disclosure-content">
                      <div className="case-studies">
                        {experience.caseStudies.map((caseStudy) => (
                          <article className="case-study" key={caseStudy.title}>
                            <h4>{caseStudy.title}</h4>
                            <dl>
                              <div>
                                <dt>문제</dt>
                                <dd>{caseStudy.problem}</dd>
                              </div>
                              <div>
                                <dt>분석</dt>
                                <dd>{caseStudy.analysis}</dd>
                              </div>
                              <div>
                                <dt>실행</dt>
                                <dd>{caseStudy.action}</dd>
                              </div>
                              <div>
                                <dt>결과</dt>
                                <dd>{caseStudy.result}</dd>
                              </div>
                            </dl>
                          </article>
                        ))}
                      </div>
                      <h4 className="contribution-title">그 밖의 기여</h4>
                      <ul className="contributions">
                        {experience.highlights.map((highlight) => (
                          <li key={highlight}>{highlight}</li>
                        ))}
                      </ul>
                      <ul
                        className="tags"
                        aria-label={`${experience.company} 사용 기술`}
                      >
                        {experience.skills.map((skill) => (
                          <li key={skill}>{skill}</li>
                        ))}
                      </ul>
                    </div>
                  </details>
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="section projects-section" id="projects">
          <div className="section-heading">
            <p className="eyebrow">03 · SELECTED PROJECTS</p>
            <h2>직접 만들고,<br />출시하고, 운영했습니다.</h2>
          </div>
          <div className="projects">
            {content.projects.map((project, index) => (
              <article className="project" key={project.title}>
                <div className="project-visual">
                  <span className="project-number" aria-hidden="true">
                    {String(index + 1).padStart(2, '0')}
                  </span>
                  <img
                    src={project.image.src}
                    alt={project.image.alt}
                    width={project.image.width}
                    height={project.image.height}
                    loading="lazy"
                    decoding="async"
                  />
                </div>
                <div className="project-copy">
                  <p className="project-subtitle">{project.subtitle}</p>
                  <h3>{project.title}</h3>
                  <p className="summary">{project.description}</p>
                  <div className="inline-metrics">
                    {project.metrics.map((metric) => (
                      <span key={metric.label}>
                        <strong>{metric.value}</strong> {metric.label}
                      </span>
                    ))}
                  </div>
                  <details className="disclosure">
                    <summary>
                      <span>프로젝트 자세히 보기</span>
                      <span className="disclosure-action" aria-hidden="true" />
                    </summary>
                    <div className="disclosure-content">
                      <ul>
                        {project.highlights.map((highlight) => (
                          <li key={highlight}>{highlight}</li>
                        ))}
                      </ul>
                      <ul
                        className="tags"
                        aria-label={`${project.title} 사용 기술`}
                      >
                        {project.skills.map((skill) => (
                          <li key={skill}>{skill}</li>
                        ))}
                      </ul>
                    </div>
                  </details>
                  {project.links.map((link) => (
                    <a
                      className="project-link"
                      key={link.url}
                      href={link.url}
                      {...externalLinkProps}
                    >
                      {link.label}에서 보기 <Arrow />
                    </a>
                  ))}
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="section skills-section" id="skills">
          <div className="section-heading">
            <p className="eyebrow">04 · SKILLS</p>
            <h2>기술보다<br />사용한 맥락을 말합니다.</h2>
          </div>
          <div className="skill-grid">
            {content.skillGroups.map((group) => (
              <article key={group.title}>
                <p>{group.description}</p>
                <h3>{group.title}</h3>
                <ul>
                  {group.items.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </article>
            ))}
          </div>
        </section>
      </main>

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
            <p>
              허용한 경우에만 Microsoft Clarity로 사용 패턴을 분석합니다.
            </p>
            <button type="button" onClick={() => setShowConsent(true)}>
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
              Microsoft Clarity로 클릭, 스크롤, 세션 재생 데이터를 수집해
              포트폴리오를 개선합니다. 거부하면 Clarity를 불러오지 않습니다.
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
