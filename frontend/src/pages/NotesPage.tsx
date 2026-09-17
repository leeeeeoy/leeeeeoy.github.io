import { ui, localizedHref } from '../content'
import { noteCategories, notes } from '../notes'

export default function NotesPage({ slug }: { slug?: string }) {
  const note = notes.find((item) => item.slug === slug)

  if (slug) {
    if (!note) {
      return (
        <section className="notes-hero" id="top">
          <div className="hero-copy">
            <p className="eyebrow">ENGINEERING NOTES</p>
            <h1>{ui.noteMissing}</h1>
            <a className="notes-back" href={localizedHref("/notes/")}>{ui.backToNotes}</a>
          </div>
        </section>
      )
    }

    return (
      <article className="note-article" id="top">
        <a className="notes-back" href={localizedHref("/notes/")}>← Notes</a>
        <p className="eyebrow">{note.category}</p>
        <h1>{note.title}</h1>
        <p className="note-lead">{note.summary}</p>
        <ul className="tags" aria-label={ui.tags}>
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
          <p className="eyebrow">NOTES</p>
          <h1>{ui.notesHeading}</h1>
          <p className="hero-intro">
            {ui.notesIntro}
          </p>
        </div>
      </section>
      <section className="section notes-section" aria-label={ui.notesList}>
        <div className="note-categories">
          {noteCategories.map((category) => {
            const categoryNotes = notes.filter(
              (note) => note.category === category.id,
            )

            return (
              <section className="note-category" key={category.id} data-reveal>
                <div className="note-category-heading">
                  <div>
                    <p className="eyebrow">{category.id}</p>
                    <h2>{category.title}</h2>
                  </div>
                  <p>{category.description}</p>
                </div>
                {categoryNotes.length === 0 ? (
                  <p className="notes-empty">{ui.notesEmpty}</p>
                ) : (
                  <div className="notes-list">
                    {categoryNotes.map((item) => (
                      <article key={item.slug}>
                        <h3><a href={localizedHref(`/notes/${item.slug}/`)}>{item.title}</a></h3>
                        <p>{item.summary}</p>
                        <ul className="tags" aria-label={`${item.title} ${ui.tags}`}>
                          {item.tags.map((tag) => <li key={tag}>{tag}</li>)}
                        </ul>
                      </article>
                    ))}
                  </div>
                )}
              </section>
            )
          })}
        </div>
      </section>
    </>
  )
}
