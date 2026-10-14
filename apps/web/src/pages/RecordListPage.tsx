import { ui } from '../content'

export default function RecordListPage({ kind }: { kind: 'lab' | 'writing' }) {
  const isLab = kind === 'lab'
  return (
    <>
      <section className="notes-hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">{isLab ? ui.labEyebrow : ui.writingEyebrow}</p>
          <h1>{isLab ? ui.navLab : ui.navWriting}</h1>
          <p className="hero-intro">{isLab ? ui.labIntro : ui.writingIntro}</p>
        </div>
      </section>
      <section
        className="section collection-section"
        aria-labelledby={`${kind}-status`}
      >
        <div className="collection-empty">
          <h2 id={`${kind}-status`}>{ui.recordsEmpty}</h2>
          <p>{isLab ? ui.labEmptyDescription : ui.writingEmptyDescription}</p>
        </div>
      </section>
    </>
  )
}
