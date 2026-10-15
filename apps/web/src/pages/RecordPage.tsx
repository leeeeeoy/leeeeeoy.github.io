import Markdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import { localizedHref, ui } from '../content'
import { getPost, type Section } from '../posts'

export default function RecordPage({
  kind,
  slug,
}: {
  kind: Section
  slug: string
}) {
  const post = getPost(kind, slug)
  const back = (
    <a className="notes-back" href={localizedHref(`/${kind}/`)}>
      ← {kind === 'lab' ? ui.backToLab : ui.backToWriting}
    </a>
  )
  if (!post)
    return (
      <section className="notes-hero">
        <div className="hero-copy">
          <p className="eyebrow">404</p>
          <h1>{ui.recordMissing}</h1>
          <p className="hero-intro">{ui.recordMissingDescription}</p>
          {back}
        </div>
      </section>
    )
  return (
    <article className="note-article record-article">
      {back}
      <header className="record-heading">
        <p className="eyebrow">{kind === 'lab' ? ui.navLab : ui.navWriting}</p>
        <h1>{post.title}</h1>
        <p className="record-dates">
          <time dateTime={post.date}>{post.date}</time>
          {post.updated && (
            <>
              {' '}
              · {ui.recordUpdated}{' '}
              <time dateTime={post.updated}>{post.updated}</time>
            </>
          )}
        </p>
        <p className="note-lead">{post.summary}</p>
        {post.tags.length > 0 && (
          <ul className="record-tags" aria-label={ui.recordTags}>
            {post.tags.map((tag, index) => (
              <li key={index}>{tag}</li>
            ))}
          </ul>
        )}
      </header>
      <div className="markdown-body">
        <Markdown
          skipHtml
          remarkPlugins={[remarkGfm]}
          components={{
            h1: ({ children }) => <h2>{children}</h2>,
            a: ({ href, children }) => {
              if (!href) return <span>{children}</span>
              const external = href && /^(https?:)?\/\//i.test(href)
              const internal =
                href &&
                !external &&
                !/^[a-z]+:/i.test(href) &&
                !href.startsWith('#')
              const url = internal
                ? new URL(
                    href,
                    window.location.origin +
                      window.location.pathname.replace(/\/?$/, '/'),
                  )
                : undefined
              return (
                <a
                  href={
                    url
                      ? localizedHref(url.pathname + url.search + url.hash)
                      : href
                  }
                  {...(external
                    ? { target: '_blank', rel: 'noopener noreferrer' }
                    : {})}
                >
                  {children}
                </a>
              )
            },
            img: ({ src, alt, title }) =>
              src ? (
                <img
                  src={src}
                  alt={alt ?? ''}
                  title={title}
                  loading="lazy"
                  decoding="async"
                />
              ) : (
                <span>{alt}</span>
              ),
            pre: ({ children }) => (
              <pre role="region" tabIndex={0} aria-label={ui.recordCode}>
                {children}
              </pre>
            ),
            table: ({ children }) => (
              <div
                className="markdown-table"
                role="region"
                tabIndex={0}
                aria-label={ui.recordTable}
              >
                <table>{children}</table>
              </div>
            ),
          }}
        >
          {post.body}
        </Markdown>
      </div>
      <div className="record-end">{back}</div>
    </article>
  )
}
