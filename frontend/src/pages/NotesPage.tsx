import { noteCategories, notes } from '../notes'

export default function NotesPage({ slug }: { slug?: string }) {
  const note = notes.find((item) => item.slug === slug)

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
        <a className="notes-back" href="/notes/">← Notes</a>
        <p className="eyebrow">{note.category}</p>
        <h1>{note.title}</h1>
        <p className="note-lead">{note.summary}</p>
        <ul className="tags" aria-label="관련 태그">
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
          <h1>문제를 풀고 결정하며<br />배운 것들을 기록합니다.</h1>
          <p className="hero-intro">
            기술적인 문제 해결과 제품·기술 의사결정의 근거, 실험 이후의
            생각을 정리합니다.
          </p>
        </div>
      </section>
      <section className="section notes-section" aria-label="노트 목록">
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
                  <p className="notes-empty">아직 작성된 기록이 없습니다.</p>
                ) : (
                  <div className="notes-list">
                    {categoryNotes.map((item) => (
                      <article key={item.slug}>
                        <h3><a href={`/notes/${item.slug}/`}>{item.title}</a></h3>
                        <p>{item.summary}</p>
                        <ul className="tags" aria-label={`${item.title} 관련 태그`}>
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
