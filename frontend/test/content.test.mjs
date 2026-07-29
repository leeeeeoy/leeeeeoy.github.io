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

test('public portfolio content is complete and excludes private contact data', () => {
  assert.equal(content.experiences.length, 3)
  assert.equal(content.projects.length, 3)
  assert.ok(content.metrics.length >= 3)
  assert.equal(content.profile.eyebrow, 'SOFTWARE ENGINEER · SINCE 2022')
  assert.ok(content.experiences.every(({ highlights }) => highlights.length >= 3))
  assert.ok(content.projects.every(({ highlights }) => highlights.length >= 3))

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
