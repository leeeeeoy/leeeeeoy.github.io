import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

const content = JSON.parse(
  await readFile(new URL('../src/content.json', import.meta.url), 'utf8'),
)
const appSource = await readFile(new URL('../src/App.tsx', import.meta.url), 'utf8')
const htmlSource = await readFile(new URL('../index.html', import.meta.url), 'utf8')
const stylesSource = await readFile(
  new URL('../src/styles.css', import.meta.url),
  'utf8',
)
const robotsSource = await readFile(
  new URL('../public/robots.txt', import.meta.url),
  'utf8',
)
const sitemapSource = await readFile(
  new URL('../public/sitemap.xml', import.meta.url),
  'utf8',
)

test('public portfolio content is complete and excludes private contact data', () => {
  assert.equal(content.experiences.length, 3)
  assert.equal(content.projects.length, 3)
  assert.ok(content.metrics.length >= 3)
  assert.equal(content.profile.eyebrow, 'SOFTWARE ENGINEER · SINCE 2022')
  assert.ok(content.experiences.every(({ highlights }) => highlights.length >= 3))
  assert.ok(content.projects.every(({ highlights }) => highlights.length >= 3))
  assert.deepEqual(
    content.experiences.map(({ website }) => website),
    [
      'https://clify.co.kr/',
      'https://www.seoulexchange.kr/',
      'https://www.dozn.co.kr/',
    ],
  )
  assert.ok(
    content.experiences.every(({ caseStudies }) =>
      caseStudies.every(({ problem, analysis, action, result }) =>
        [problem, analysis, action, result].every(Boolean),
      ),
    ),
  )
  assert.match(appSource, /className="company-link"/)

  const serialized = JSON.stringify(content)
  assert.doesNotMatch(serialized, /01[016789][-. ]?\d{3,4}[-. ]?\d{4}/)
  assert.doesNotMatch(serialized, /[\w.+-]+@[\w.-]+\.[a-z]{2,}/i)
  assert.doesNotMatch(serialized, /서울특별시\s+\S+구|상세\s?주소/)

  for (const project of content.projects) {
    assert.match(project.image.src, /^https:\/\/assets\.leeeeeoy\.xyz\//)
    assert.ok(project.image.width > 0 && project.image.height > 0)
  }
})

test('Clarity loads only after consent and only on production', () => {
  assert.match(appSource, /xti7rw64s1/)
  assert.match(appSource, /portfolio\.leeeeeoy\.xyz/)
  assert.match(appSource, /analytics_Storage: 'granted'/)
  assert.match(appSource, /analytics_Storage: 'denied'/)
  assert.match(appSource, /if \(consent === 'granted'\) loadClarity\(\)/)
  assert.match(appSource, /localStorage\.setItem\(CLARITY_CONSENT_KEY/)
})

test('theme follows the system preference and remembers an explicit choice', () => {
  assert.match(htmlSource, /prefers-color-scheme: dark/)
  assert.match(htmlSource, /localStorage\.getItem\('portfolio-theme'\)/)
  assert.match(appSource, /localStorage\.setItem\(THEME_KEY, nextTheme\)/)
  assert.match(stylesSource, /:root\[data-theme='dark'\]/)
})

test('motion is progressive and respects reduced-motion preferences', () => {
  assert.match(appSource, /new IntersectionObserver/)
  assert.match(appSource, /observer\.unobserve\(entry\.target\)/)
  assert.match(appSource, /data-reveal/)
  assert.match(stylesSource, /@keyframes hero-enter/)
  assert.match(stylesSource, /@keyframes disclosure-enter/)
  assert.match(stylesSource, /@media \(hover: hover\) and \(pointer: fine\)/)
  assert.match(stylesSource, /@media \(prefers-reduced-motion: reduce\)/)
})

test('social previews use the optimized R2 image', () => {
  assert.match(
    htmlSource,
    /https:\/\/assets\.leeeeeoy\.xyz\/portfolio-v2\/og\.jpg/,
  )
  assert.match(htmlSource, /property="og:image:width" content="1200"/)
  assert.match(htmlSource, /property="og:image:height" content="630"/)
  assert.match(htmlSource, /name="twitter:card" content="summary_large_image"/)
})

test('search metadata describes the portfolio and keeps it crawlable', () => {
  assert.match(htmlSource, /name="robots" content="max-image-preview:large"/)
  assert.match(htmlSource, /property="og:site_name" content="Yoel Jang"/)
  assert.match(htmlSource, /name="twitter:title"/)
  assert.match(htmlSource, /name="twitter:description"/)

  const structuredData = JSON.parse(
    htmlSource.match(
      /<script type="application\/ld\+json">([\s\S]*?)<\/script>/,
    )[1],
  )
  assert.deepEqual(
    structuredData['@graph'].map(({ '@type': type }) => type),
    ['WebSite', 'ProfilePage', 'Person'],
  )
  assert.equal(
    structuredData['@graph'][1].mainEntity['@id'],
    structuredData['@graph'][2]['@id'],
  )
  assert.match(robotsSource, /Sitemap: https:\/\/portfolio\.leeeeeoy\.xyz\/sitemap\.xml/)
  assert.match(sitemapSource, /<loc>https:\/\/portfolio\.leeeeeoy\.xyz\/<\/loc>/)
})
