import { engineeringNotes } from '../notes'

export default function NotesPage({ slug }: { slug?: string }) {
  const note = engineeringNotes.find((item) => item.slug === slug)

  if (slug) {
    if (!note) {
      return (
        <section className="notes-hero" id="top">
          <div className="hero-copy">
            <p className="eyebrow">ENGINEERING NOTES</p>
            <h1>아직 작성되지 않은 기록입니다.</h1>
            <a className="notes-back" href="/notes/">← Notes로 돌아가기</a>
          </div>
        </section>
      )
    }

    return (
      <article className="note-article" id="top">
        <a className="notes-back" href="/notes/">← Engineering Notes</a>
        <p className="eyebrow">{note.category}</p>
        <h1>{note.title}</h1>
        <p className="note-lead">{note.summary}</p>
        <ul className="tags" aria-label="관련 기술">
          {note.tags.map((tag) => <li key={tag}>{tag}</li>)}
        </ul>
        {note.sections.map((section) => (
          <section key={section.heading}>
            <h2>{section.heading}</h2>
            {section.paragraphs.map((paragraph) => (
              <p key={paragraph}>{paragraph}</p>
            ))}
          </section>
        ))}
      </article>
    )
  }

  return (
    <>
      <section className="notes-hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">ENGINEERING NOTES</p>
          <h1>문제를 풀며<br />배운 것들을 기록합니다.</h1>
          <p className="hero-intro">
            트러블슈팅 과정과 기술적 선택, 다시 돌아보며 달라진 생각을
            정리합니다.
          </p>
        </div>
      </section>
      <section className="section notes-section" aria-label="엔지니어링 노트">
        {engineeringNotes.length === 0 ? (
          <p className="notes-empty" data-reveal>
            첫 번째 기록을 준비하고 있습니다.
          </p>
        ) : (
          <div className="notes-list">
            {engineeringNotes.map((item) => (
              <article key={item.slug} data-reveal>
                <p className="eyebrow">{item.category}</p>
                <h2><a href={`/notes/${item.slug}/`}>{item.title}</a></h2>
                <p>{item.summary}</p>
                <ul className="tags" aria-label={`${item.title} 관련 기술`}>
                  {item.tags.map((tag) => <li key={tag}>{tag}</li>)}
                </ul>
              </article>
            ))}
          </div>
        )}
      </section>
    </>
  )
}
