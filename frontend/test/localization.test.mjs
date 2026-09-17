import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'
import { createServer } from 'vite'
import { createElement } from 'react'
import { renderToStaticMarkup } from 'react-dom/server'

const translations = JSON.parse(await readFile(new URL('../src/content.json', import.meta.url), 'utf8'))

test('both languages keep the same content structure, facts, and public links', () => {
  function compare(ko, en, path = '') {
    assert.equal(typeof en, typeof ko, path)
    if (Array.isArray(ko)) {
      assert.equal(en.length, ko.length, path)
      ko.forEach((value, index) => compare(value, en[index], `${path}.${index}`))
    } else if (ko && typeof ko === 'object') {
      assert.deepEqual(Object.keys(en), Object.keys(ko), path)
      for (const key of Object.keys(ko)) compare(ko[key], en[key], `${path}.${key}`)
    } else if (typeof ko === 'string') {
      assert.ok(en.trim(), path)
      assert.doesNotMatch(en, /[가-힣]/, path)
      // Existing English labels, metrics, URLs, and technology names stay intact.
      if (!/[가-힣]/.test(ko)) assert.equal(en, ko, path)
    } else assert.equal(en, ko, path)
  }
  compare(translations.ko, translations.en)
  assert.doesNotMatch(JSON.stringify(translations), /01[016789][-. ]?\d{3,4}[-. ]?\d{4}/)
  assert.match(translations.en.experiences[1].caseStudies[0].result, /did not reach production during my tenure/)
})

test('language links, metadata, and rendered pages work in both languages', async () => {
  const originalWindow = globalThis.window
  const originalDocument = globalThis.document
  const server = await createServer({ server: { middlewareMode: true, hmr: false, ws: false } })
  try {
    for (const language of ['ko', 'en']) {
      globalThis.window = { location: new URL(`https://portfolio.leeeeeoy.xyz/?lang=${language}`) }
      const meta = new Map()
      globalThis.document = {
        documentElement: {},
        querySelector: (selector) => ({ setAttribute: (key, value) => meta.set(`${selector}:${key}`, value) }),
      }
      server.moduleGraph.invalidateAll()
      const content = await server.ssrLoadModule('/src/content.ts')
      assert.equal(content.getLanguage('?lang=en'), 'en')
      for (const query of ['', '?lang=fr', '?lang=EN']) assert.equal(content.getLanguage(query), 'ko')
      assert.equal(content.localizedHref('/notes/?ref=test#part', 'en'), '/notes/?ref=test&lang=en#part')
      assert.equal(content.localizedHref('/notes/?ref=test&lang=en#part', 'ko'), '/notes/?ref=test#part')
      content.applyLanguageMetadata()
      assert.equal(document.documentElement.lang, language)
      assert.equal(meta.get('meta[name="description"]:content'), translations[language].ui.metaDescription)
      const { default: PortfolioPage } = await server.ssrLoadModule('/src/pages/PortfolioPage.tsx')
      const { default: NotesPage } = await server.ssrLoadModule('/src/pages/NotesPage.tsx')
      const { SiteHeader, SiteFooter } = await server.ssrLoadModule('/src/components/SiteChrome.tsx')
      const portfolio = renderToStaticMarkup(createElement(PortfolioPage))
      const notes = renderToStaticMarkup(createElement(NotesPage))
      const missingNote = renderToStaticMarkup(createElement(NotesPage, { slug: 'missing' }))
      const header = renderToStaticMarkup(createElement(SiteHeader, { theme: 'light', onToggleTheme() {} }))
      const footer = renderToStaticMarkup(createElement(SiteFooter, { onOpenConsent() {} }))
      assert.ok(portfolio.includes(translations[language].experiences[1].caseStudies[0].title))
      assert.ok(notes.includes(translations[language].ui.notesEmpty))
      assert.ok(missingNote.includes(translations[language].ui.noteMissing))
      assert.ok(footer.includes(translations[language].ui.architectureLegacy))
      assert.ok(header.includes(`href="/notes/${language === 'en' ? '?lang=en' : ''}"`))
      if (language === 'en') assert.doesNotMatch(portfolio + notes + missingNote + footer, /[가-힣]/)
    }
  } finally {
    await server.close()
    globalThis.window = originalWindow
    globalThis.document = originalDocument
  }
})
