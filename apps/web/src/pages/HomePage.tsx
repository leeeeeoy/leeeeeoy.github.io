import { content, ui, localizedHref } from '../content'

export default function HomePage() {
  const spaces = [
    {
      path: '/portfolio/',
      title: ui.navPortfolio,
      description: ui.portfolioIntro,
    },
    { path: '/lab/', title: ui.navLab, description: ui.labIntro },
    { path: '/writing/', title: ui.navWriting, description: ui.writingIntro },
  ]

  return (
    <>
      <section className="hero home-hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">{content.profile.name}</p>
          <h1>
            {ui.homeHeading.split('\n').map((line) => (
              <span key={line}>{line}</span>
            ))}
          </h1>
          <p className="hero-intro">{ui.homeIntro}</p>
          <div className="hero-links">
            <a href={localizedHref('/portfolio/')}>{ui.viewPortfolio}</a>
          </div>
        </div>
      </section>
      <section className="section home-spaces" aria-labelledby="spaces-title">
        <div className="home-space-list">
          <h2 id="spaces-title" className="eyebrow">
            {ui.explore}
          </h2>
          {spaces.map((space, index) => (
            <a
              className="home-space"
              href={localizedHref(space.path)}
              key={space.path}
            >
              <span className="home-space-number" aria-hidden="true">
                0{index + 1}
              </span>
              <div>
                <h3>{space.title}</h3>
                <p>{space.description}</p>
              </div>
              <span className="home-space-arrow" aria-hidden="true">
                →
              </span>
            </a>
          ))}
        </div>
      </section>
    </>
  )
}
