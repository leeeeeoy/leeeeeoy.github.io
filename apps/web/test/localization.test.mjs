import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'
import { createServer } from 'vite'
import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'

const translations = JSON.parse(
  await readFile(new URL('../src/content.json', import.meta.url), 'utf8'),
)

test('both languages keep the same content structure, facts, and public links', () => {
  function compare(ko, en, path = '') {
    assert.equal(typeof en, typeof ko, path)
    if (Array.isArray(ko)) {
      assert.equal(en.length, ko.length, path)
      ko.forEach((value, index) =>
        compare(value, en[index], `${path}.${index}`),
      )
    } else if (ko && typeof ko === 'object') {
      assert.deepEqual(Object.keys(en), Object.keys(ko), path)
      for (const key of Object.keys(ko))
        compare(ko[key], en[key], `${path}.${key}`)
    } else if (typeof ko === 'string') {
      assert.ok(en.trim(), path)
      assert.doesNotMatch(en, /[가-힣]/, path)
      // Existing English labels, metrics, URLs, and technology names stay intact.
      if (!/[가-힣]/.test(ko)) assert.equal(en, ko, path)
    } else assert.equal(en, ko, path)
  }
  compare(translations.ko, translations.en)
  assert.equal(translations.en.experiences[0].company, 'Simpatico Project')
  assert.ok(
    translations.en.featuredImpacts
      .slice(0, 2)
      .every(({ organization }) => organization === 'Simpatico Project'),
  )
  assert.doesNotMatch(
    JSON.stringify(translations),
    /01[016789][-. ]?\d{3,4}[-. ]?\d{4}/,
  )
  assert.match(
    translations.en.experiences[1].caseStudies[0].result,
    /did not reach production during my tenure/,
  )
})

test('language links, metadata, and rendered pages work in both languages', async () => {
  const originalWindow = globalThis.window
  const originalDocument = globalThis.document
  const originalStorage = Object.getOwnPropertyDescriptor(
    globalThis,
    'localStorage',
  )
  Object.defineProperty(globalThis, 'localStorage', {
    configurable: true,
    value: { getItem: () => null },
  })
  const server = await createServer({
    server: { middlewareMode: true, hmr: false, ws: false },
    optimizeDeps: { noDiscovery: true, include: [] },
  })
  try {
    for (const language of ['ko', 'en']) {
      globalThis.window = {
        location: new URL(`https://leeeeeoy.xyz/?lang=${language}`),
      }
      const meta = new Map()
      globalThis.document = {
        documentElement: { dataset: { theme: 'light' } },
        querySelector: (selector) => ({
          setAttribute: (key, value) => meta.set(`${selector}:${key}`, value),
        }),
      }
      server.moduleGraph.invalidateAll()
      const content = await server.ssrLoadModule('/src/content.ts')
      assert.equal(content.getLanguage('?lang=en'), 'en')
      for (const query of ['', '?lang=fr', '?lang=EN'])
        assert.equal(content.getLanguage(query), 'ko')
      assert.equal(
        content.localizedHref('/notes/?ref=test#part', 'en'),
        '/notes/?ref=test&lang=en#part',
      )
      assert.equal(
        content.localizedHref('/notes/?ref=test&lang=en#part', 'ko'),
        '/notes/?ref=test#part',
      )
      content.applyLanguageMetadata()
      assert.equal(globalThis.document.documentElement.lang, language)
      assert.equal(
        meta.get('meta[name="description"]:content'),
        translations[language].ui.siteDescription,
      )
      const { default: PortfolioPage } = await server.ssrLoadModule(
        '/src/pages/PortfolioPage.tsx',
      )
      const { default: NotesPage } = await server.ssrLoadModule(
        '/src/pages/NotesPage.tsx',
      )
      const { SiteHeader, SiteFooter } = await server.ssrLoadModule(
        '/src/components/SiteChrome.tsx',
      )
      const portfolio = renderToStaticMarkup(createElement(PortfolioPage))
      const notes = renderToStaticMarkup(createElement(NotesPage))
      const missingNote = renderToStaticMarkup(
        createElement(NotesPage, { slug: 'missing' }),
      )
      const header = renderToStaticMarkup(
        createElement(SiteHeader, {
          page: 'home',
          theme: 'light',
          onToggleTheme() {},
        }),
      )
      const footer = renderToStaticMarkup(
        createElement(SiteFooter, { page: 'portfolio', onOpenConsent() {} }),
      )
      assert.ok(
        portfolio.includes(
          translations[language].experiences[1].caseStudies[0].title,
        ),
      )
      assert.ok(notes.includes(translations[language].ui.notesEmpty))
      assert.ok(missingNote.includes(translations[language].ui.noteMissing))
      assert.ok(footer.includes(translations[language].ui.architectureLegacy))
      assert.ok(
        header.includes(
          `href="/portfolio/${language === 'en' ? '?lang=en' : ''}"`,
        ),
      )
      assert.match(header, language === 'en' ? />KR<\/a>/ : />EN<\/a>/)
      assert.ok(
        header.includes('aria-label="GitHub"'),
        'icon-only mobile link keeps an accessible name',
      )
      if (language === 'en')
        assert.doesNotMatch(portfolio + notes + missingNote + footer, /[가-힣]/)

      const { default: App } = await server.ssrLoadModule('/src/App.tsx')
      const routes = [
        ['/', translations[language].ui.homeHeading, 'home'],
        ['/portfolio/', translations[language].profile.headline, 'portfolio'],
        ['/lab/', translations[language].ui.navLab, 'lab'],
        ['/writing/', translations[language].ui.navWriting, 'writing'],
        ['/notes/', translations[language].ui.notesHeading, 'lab'],
        ['/notes/missing/', translations[language].ui.noteMissing, 'lab'],
        ['/lab/missing/', translations[language].ui.recordMissing, 'lab'],
        [
          '/writing/missing/',
          translations[language].ui.recordMissing,
          'writing',
        ],
        ['/missing/', translations[language].ui.pageMissing, null],
      ]
      for (const [path, heading, active] of routes) {
        globalThis.window.location = new URL(
          `https://leeeeeoy.xyz${path}?lang=${language}`,
        )
        const rendered = renderToStaticMarkup(createElement(App))
        assert.ok(
          rendered.includes(heading.split('\n')[0]),
          `${language} ${path}`,
        )
        assert.equal((rendered.match(/<h1(?:\s|>)/g) ?? []).length, 1, path)
        assert.ok(rendered.includes('id="content" tabindex="-1"'), path)
        for (const href of ['/', '/portfolio/', '/lab/', '/writing/']) {
          assert.ok(
            rendered.includes(
              `href="${href}${language === 'en' ? '?lang=en' : ''}"`,
            ),
            path,
          )
        }
        assert.equal(
          (rendered.match(/aria-current="page"/g) ?? []).length,
          active ? 1 : 0,
          path,
        )
        if (active) {
          const activePath = active === 'home' ? '/' : `/${active}/`
          assert.ok(
            rendered.includes(
              `href="${activePath}${language === 'en' ? '?lang=en' : ''}" aria-current="page"`,
            ),
            path,
          )
        }
        if (path === '/portfolio/') {
          assert.ok(
            rendered.includes(portfolio),
            'full portfolio markup must be preserved',
          )
          assert.ok(
            rendered.includes(
              `aria-label="${translations[language].ui.portfolioNavigation}"`,
            ),
          )
        } else {
          assert.doesNotMatch(
            rendered,
            /class="timeline"|class="impact-grid"|class="projects"/,
            path,
          )
        }
        if (path === '/lab/' || path === '/writing/') {
          assert.ok(
            rendered.includes(translations[language].ui.recordsEmpty),
            path,
          )
          assert.doesNotMatch(rendered, /<article/)
        }
        if (path.startsWith('/notes/'))
          assert.ok(
            rendered.includes(translations[language].ui.notesCompatibility),
          )
        content.applyLanguageMetadata()
        const labels = {
          home: translations[language].ui.navHome,
          portfolio: translations[language].ui.navPortfolio,
          lab: translations[language].ui.navLab,
          writing: translations[language].ui.navWriting,
        }
        const expectedLabel = /^\/(lab|writing)\/missing\/$/.test(path)
          ? translations[language].ui.recordMissing
          : path.startsWith('/notes/')
            ? 'Notes'
            : active
              ? labels[active]
              : translations[language].ui.pageMissing
        assert.equal(
          globalThis.document.title,
          `${translations[language].profile.name} — ${expectedLabel}`,
        )
        if (path === '/portfolio/')
          assert.equal(
            meta.get('meta[name="description"]:content'),
            translations[language].ui.metaDescription,
          )
        if (language === 'en') {
          // The Korean-language switch keeps its native-language accessible name.
          assert.doesNotMatch(
            rendered.replace('aria-label="한국어로 보기"', ''),
            /[가-힣]/,
            path,
          )
        }
      }
    }
  } finally {
    await server.close()
    globalThis.window = originalWindow
    globalThis.document = originalDocument
    if (originalStorage)
      Object.defineProperty(globalThis, 'localStorage', originalStorage)
    else delete globalThis.localStorage
  }
})

test('routes and legacy portfolio addresses are explicit and preserve queries', async () => {
  const server = await createServer({
    server: { middlewareMode: true, hmr: false, ws: false },
    optimizeDeps: { noDiscovery: true, include: [] },
  })
  try {
    const { getPage, legacyPortfolioHref } =
      await server.ssrLoadModule('/src/routes.ts')
    for (const [path, page] of [
      ['/', 'home'],
      ['/portfolio', 'portfolio'],
      ['/portfolio/', 'portfolio'],
      ['/lab', 'lab'],
      ['/lab/', 'lab'],
      ['/writing', 'writing'],
      ['/writing/', 'writing'],
      ['/notes', 'notes'],
      ['/notes/', 'notes'],
      ['/notes/missing', 'notes'],
      ['/notes/missing/', 'notes'],
      ['/notes/a/b/', 'not-found'],
      ['/portfolio/a/', 'not-found'],
      ['/lab/a/', 'lab'],
      ['/writing/a/', 'writing'],
      ['/lab/a/b/', 'not-found'],
      ['/lab/%2e%2e/', 'not-found'],
      ['/writing/UPPER/', 'not-found'],
      ['/unknown/', 'not-found'],
    ]) {
      assert.equal(getPage(path), page, path)
    }
    for (const section of ['experience', 'projects', 'skills']) {
      assert.equal(
        legacyPortfolioHref('/', '?lang=en&ref=old', `#${section}`),
        `/portfolio/?lang=en&ref=old#${section}`,
      )
      assert.equal(
        legacyPortfolioHref('/', '?lang=en', '', section),
        '/portfolio/?lang=en',
      )
    }
    assert.equal(legacyPortfolioHref('/', '', ''), null)
    assert.equal(legacyPortfolioHref('/', '', '#other', 'unknown'), null)
    assert.equal(
      legacyPortfolioHref('/portfolio/', '?lang=en', '#skills'),
      null,
    )
  } finally {
    await server.close()
  }
})
