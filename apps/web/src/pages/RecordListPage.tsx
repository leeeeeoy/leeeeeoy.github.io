import { localizedHref, ui } from '../content'
import { posts, type Section } from '../posts'

export default function RecordListPage({ kind }: { kind: Section }) {
  const isLab = kind === 'lab'
  const entries = posts.filter((post) => post.section === kind)
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
        aria-label={isLab ? ui.labRecords : ui.writingRecords}
      >
        {entries.length ? (
          <ul className="record-list">
            {entries.map((post) => (
              <li key={post.slug}>
                <time dateTime={post.date}>{post.date}</time>
                <h2>
                  <a href={localizedHref(`/${kind}/${post.slug}/`)}>
                    {post.title}
                  </a>
                </h2>
                <p>{post.summary}</p>
                {post.tags.length > 0 && (
                  <ul className="record-tags" aria-label={ui.recordTags}>
                    {post.tags.map((tag, index) => (
                      <li key={index}>{tag}</li>
                    ))}
                  </ul>
                )}
              </li>
            ))}
          </ul>
        ) : (
          <div className="collection-empty">
            <h2 id={`${kind}-status`}>{ui.recordsEmpty}</h2>
            <p>{isLab ? ui.labEmptyDescription : ui.writingEmptyDescription}</p>
          </div>
        )}
      </section>
    </>
  )
}
