import assert from 'node:assert/strict'
import {
  cp,
  mkdir,
  mkdtemp,
  readFile,
  readdir,
  realpath,
  rm,
  symlink,
  writeFile,
} from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import test from 'node:test'
import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { build, createServer } from 'vite'
import { collectPosts, parsePost, publishPosts } from '../scripts/content.ts'

const fixture = await readFile(
  new URL('./fixtures/markdown.md', import.meta.url),
  'utf8',
)
const webRoot = fileURLToPath(new URL('../', import.meta.url))
const minimal = (fields = '', body = 'Body') =>
  `---\ntitle: Title\ndate: "2026-10-14"\nsummary: Summary\n${fields}\n---\n${body}`

test('frontmatter validates fields, YAML, real dates, slugs and safe draft defaults', () => {
  const parse = (source, slug = 'test-post') =>
    parsePost(source, 'lab', slug, 'content/lab/test-post.md')
  assert.equal(parse(minimal()).draft, true)
  assert.equal(parse(minimal('draft: false')).draft, false)
  assert.deepEqual(parse(fixture).tags, ['test', 'markdown'])
  assert.equal(parse(fixture).updated, '2026-10-15')
  assert.ok(
    parse('\uFEFF' + fixture.replace(/\n/g, '\r\n')).body.startsWith('\n#'),
  )
  for (const [source, message] of [
    ['No metadata', /frontmatter/],
    [minimal().replace('title: Title\n', ''), /title/],
    [minimal().replace('date: "2026-10-14"\n', ''), /date/],
    [minimal().replace('summary: Summary\n', ''), /summary/],
    [minimal().replace('summary: Summary', 'summary: []'), /summary/],
    [minimal().replace('date: "2026-10-14"', 'date: 123'), /date/],
    [
      minimal().replace('date: "2026-10-14"', 'date: "2026-02-29"'),
      /calendar date/,
    ],
    [
      minimal().replace('date: "2026-10-14"', 'date: "2026-13-01"'),
      /calendar date/,
    ],
    [
      minimal().replace('date: "2026-10-14"', 'date: "0000-01-01"'),
      /calendar date/,
    ],
    [minimal('updated: "2026-10-13"'), /updated/],
    [minimal('draft: "false"'), /draft/],
    [minimal('draft: null'), /draft/],
    [minimal('updated: 42'), /updated/],
    [minimal('tags: [1]'), /tags/],
    [minimal('tags: null'), /tags/],
    [minimal('tags: [""]'), /tags/],
    [minimal('slug: hidden'), /unsupported field: slug/],
    [minimal('title: Duplicate'), /invalid YAML/],
    [minimal('tags: [unclosed'), /invalid YAML/],
    [minimal('tags: !unknown value'), /invalid YAML/],
  ]) {
    assert.throws(
      () => parse(source),
      (error) =>
        /content\/lab\/test-post.md:/.test(error.message) &&
        message.test(error.message),
    )
  }
  assert.throws(
    () =>
      parse(
        minimal('tags: [&a test, ' + Array(110).fill('*a').join(',') + ']'),
      ),
    /content\/lab\/test-post.md: invalid YAML/,
  )
  for (const slug of ['UPPER', '../outside', 'has space', 'double--hyphen'])
    assert.throws(() => parse(fixture, slug), /slug/)
  assert.equal(
    parse(minimal().replace('2026-10-14', '2024-02-29')).date,
    '2024-02-29',
  )
})

test('collection sorts dates, separates namespaces and rejects invalid drafts, duplicates and nested files', async () => {
  const root = await mkdtemp(join(tmpdir(), 'leeeeeoy-posts-'))
  try {
    for (const kind of ['lab', 'writing']) await mkdir(join(root, kind))
    await writeFile(join(root, 'lab', '.gitkeep'), '')
    await writeFile(join(root, 'lab', 'same.md'), minimal('draft: false'))
    await writeFile(
      join(root, 'writing', 'same.md'),
      minimal('draft: false').replace('2026-10-14', '2026-10-15'),
    )
    await writeFile(
      join(root, 'lab', 'draft.md'),
      minimal('draft: true', 'EXCLUDED_DRAFT'),
    )
    await writeFile(
      join(root, 'writing', 'implicit.md'),
      minimal('', 'EXCLUDED_IMPLICIT'),
    )
    await writeFile(
      join(root, 'lab', 'newer.md'),
      minimal('draft: false').replace('2026-10-14', '2026-10-16'),
    )
    await writeFile(
      join(root, 'lab', 'earlier.md'),
      minimal('draft: false').replace('2026-10-14', '2026-10-12'),
    )
    const posts = await collectPosts(root)
    assert.deepEqual(
      posts.map(({ section, slug }) => [section, slug]),
      [
        ['lab', 'newer'],
        ['writing', 'same'],
        ['lab', 'same'],
        ['lab', 'earlier'],
      ],
    )
    assert.doesNotMatch(JSON.stringify(posts), /EXCLUDED|draft/)
    const duplicate = parsePost(minimal(), 'lab', 'same', 'content/lab/same.md')
    assert.throws(
      () => publishPosts([duplicate, { ...duplicate, draft: false }]),
      /duplicate slug in lab: same/,
    )
    await writeFile(
      join(root, 'lab', 'draft.md'),
      minimal('draft: true').replace('2026-10-14', 'not-a-date'),
    )
    await assert.rejects(collectPosts(root), /draft.md: date/)
    await rm(join(root, 'lab', 'draft.md'))
    await mkdir(join(root, 'lab', 'nested'))
    await assert.rejects(collectPosts(root), /only flat Markdown/)
  } finally {
    await rm(root, { recursive: true, force: true })
  }
})

test('isolated Vite dev/build publishes only validated posts and renders safe Markdown in both UIs', async () => {
  const root = await realpath(
    await mkdtemp(join(tmpdir(), 'leeeeeoy-content-app-')),
  )
  const web = join(root, 'apps', 'web')
  let server
  const originals = {
    window: globalThis.window,
    document: globalThis.document,
    storage: Object.getOwnPropertyDescriptor(globalThis, 'localStorage'),
  }
  try {
    await cp(webRoot, web, {
      recursive: true,
      filter: (path) =>
        !/\/(node_modules|dist|\.vite|\.wrangler)(\/|$)/.test(path),
    })
    await symlink(
      join(webRoot, 'node_modules'),
      join(web, 'node_modules'),
      'dir',
    )
    for (const kind of ['lab', 'writing'])
      await mkdir(join(root, 'content', kind), { recursive: true })
    await writeFile(join(root, 'content', 'lab', 'fixture.md'), fixture)
    await writeFile(
      join(root, 'content', 'writing', 'fixture.md'),
      minimal('draft: false', 'WRITING_ONLY_FIXTURE').replace(
        'title: Title',
        'title: 개인 글 검증',
      ),
    )
    await writeFile(
      join(root, 'content', 'lab', 'private-draft.md'),
      minimal('draft: true', 'DRAFT_BODY_SHOULD_NEVER_SHIP'),
    )
    await writeFile(
      join(root, 'content', 'lab', 'implicit-draft.md'),
      minimal('', 'IMPLICIT_DRAFT_SHOULD_NEVER_SHIP'),
    )
    server = await createServer({
      root: web,
      configFile: join(web, 'vite.config.ts'),
      optimizeDeps: { noDiscovery: true, include: [] },
      server: { middlewareMode: true, hmr: false, ws: false },
    })
    Object.defineProperty(globalThis, 'localStorage', {
      configurable: true,
      value: { getItem: () => null },
    })
    for (const lang of ['ko', 'en']) {
      globalThis.window = {
        location: new URL(`https://leeeeeoy.xyz/lab/fixture/?lang=${lang}`),
      }
      const meta = new Map()
      globalThis.document = {
        documentElement: { dataset: { theme: 'light' } },
        querySelector: (selector) => ({
          setAttribute: (key, value) => meta.set(`${selector}:${key}`, value),
        }),
      }
      server.moduleGraph.invalidateAll()
      const { default: App } = await server.ssrLoadModule('/src/App.tsx')
      const { applyLanguageMetadata } =
        await server.ssrLoadModule('/src/content.ts')
      const article = renderToStaticMarkup(createElement(App))
      for (const element of [
        '<strong>',
        '<em>',
        '<del>',
        '<ul>',
        '<ol>',
        '<blockquote>',
        '<code>',
        '<pre ',
        '<table>',
        '<hr',
      ])
        assert.ok(article.includes(element), element)
      assert.match(article, /class="language-go"/)
      assert.equal((article.match(/<h1(?:\s|>)/g) ?? []).length, 1)
      assert.match(article, /렌더링 검증 자료/)
      assert.match(article, /dateTime="2026-10-15"/i)
      assert.match(article, /aria-label="(?:코드 블록|Code block)"/)
      assert.match(article, /role="region" tabindex="0"/)
      assert.match(
        article,
        /href="https:\/\/github.com\/leeeeeoy\/personal-space" target="_blank" rel="noopener noreferrer"/,
      )
      assert.match(article, /alt="정적 이미지 검증"/)
      assert.match(article, /loading="lazy" decoding="async"/)
      assert.doesNotMatch(
        article,
        /<script|onerror|javascript:|data:text\/html|DRAFT_BODY|WRITING_ONLY/,
      )
      assert.ok(
        article.includes(
          `href="/portfolio/${lang === 'en' ? '?lang=en' : ''}"`,
        ),
      )
      applyLanguageMetadata()
      assert.match(globalThis.document.title, /렌더링 검증 자료/)
      assert.equal(
        meta.get('link[rel="canonical"]:href'),
        'https://leeeeeoy.xyz/lab/fixture/',
      )
      for (const kind of ['lab', 'writing']) {
        globalThis.window.location = new URL(
          `https://leeeeeoy.xyz/${kind}/?lang=${lang}`,
        )
        const list = renderToStaticMarkup(createElement(App))
        assert.ok(
          list.includes(
            `href="/${kind}/fixture/${lang === 'en' ? '?lang=en' : ''}"`,
          ),
        )
        assert.doesNotMatch(list, /DRAFT_BODY|private-draft/)
        assert.ok(
          list.includes(kind === 'lab' ? '렌더링 검증 자료' : '개인 글 검증'),
        )
        assert.ok(
          !list.includes(kind === 'lab' ? '개인 글 검증' : '렌더링 검증 자료'),
        )
      }
      globalThis.window.location = new URL(
        `https://leeeeeoy.xyz/lab/fixture?lang=${lang}`,
      )
      const withoutSlash = renderToStaticMarkup(createElement(App))
      assert.ok(
        withoutSlash.includes(`href="/lab/${lang === 'en' ? '?lang=en' : ''}"`),
      )
      globalThis.window.location = new URL(
        'https://leeeeeoy.xyz/writing/fixture/',
      )
      assert.match(
        renderToStaticMarkup(createElement(App)),
        /WRITING_ONLY_FIXTURE/,
      )
      globalThis.window.location = new URL(
        'https://leeeeeoy.xyz/lab/private-draft/',
      )
      const missing = renderToStaticMarkup(createElement(App))
      assert.doesNotMatch(missing, /DRAFT_BODY|<article/)
      assert.match(missing, /404/)
    }
    await server.close()
    server = null
    await build({
      root: web,
      configFile: join(web, 'vite.config.ts'),
      logLevel: 'silent',
    })
    let output = ''
    for (const file of await readdir(join(web, 'dist', 'assets')))
      output += await readFile(join(web, 'dist', 'assets', file), 'utf8')
    assert.match(output, /렌더링 검증 자료/)
    assert.match(output, /WRITING_ONLY_FIXTURE/)
    assert.doesNotMatch(
      output,
      /DRAFT_BODY_SHOULD_NEVER_SHIP|IMPLICIT_DRAFT_SHOULD_NEVER_SHIP|private-draft|implicit-draft/,
    )
    await writeFile(
      join(root, 'content', 'lab', 'invalid.md'),
      minimal().replace('title: Title', 'title: 3'),
    )
    await assert.rejects(
      build({
        root: web,
        configFile: join(web, 'vite.config.ts'),
        logLevel: 'silent',
      }),
      /invalid.md: title/,
    )
  } finally {
    await server?.close()
    globalThis.window = originals.window
    globalThis.document = originals.document
    if (originals.storage)
      Object.defineProperty(globalThis, 'localStorage', originals.storage)
    else delete globalThis.localStorage
    await rm(root, { recursive: true, force: true })
  }
})
