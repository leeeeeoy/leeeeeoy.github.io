import content from './content.json'

const externalLinkProps = {
  target: '_blank',
  rel: 'noreferrer',
} as const

function Arrow() {
  return <span aria-hidden="true">↗</span>
}

export default function App() {
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
        <a
          className="header-link"
          href={content.profile.links[0].url}
          {...externalLinkProps}
        >
          GitHub <Arrow />
        </a>
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
          <p className="hero-mark" aria-hidden="true">
            01
          </p>
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
                      <h3>{experience.company}</h3>
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
                  <details>
                    <summary>주요 성과 보기</summary>
                    <ul>
                      {experience.highlights.map((highlight) => (
                        <li key={highlight}>{highlight}</li>
                      ))}
                    </ul>
                  </details>
                  <ul className="tags" aria-label={`${experience.company} 사용 기술`}>
                    {experience.skills.map((skill) => (
                      <li key={skill}>{skill}</li>
                    ))}
                  </ul>
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
                  <ul className="project-highlights">
                    {project.highlights.map((highlight) => (
                      <li key={highlight}>{highlight}</li>
                    ))}
                  </ul>
                  <ul className="tags" aria-label={`${project.title} 사용 기술`}>
                    {project.skills.map((skill) => (
                      <li key={skill}>{skill}</li>
                    ))}
                  </ul>
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
          <p>© {new Date().getFullYear()} {content.profile.name}</p>
        </div>
      </footer>
    </>
  )
}
