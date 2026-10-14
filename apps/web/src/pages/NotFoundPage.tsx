import { ui, localizedHref } from '../content'

export default function NotFoundPage() {
  return (
    <section className="notes-hero" id="top">
      <div className="hero-copy">
        <p className="eyebrow">404</p>
        <h1>{ui.pageMissing}</h1>
        <p className="hero-intro">{ui.pageMissingDescription}</p>
        <a className="notes-back" href={localizedHref('/')}>
          {ui.backHome}
        </a>
      </div>
    </section>
  )
}
