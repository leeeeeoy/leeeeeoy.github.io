import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'
import test from 'node:test'

const content = JSON.parse(
  await readFile(new URL('../src/content.json', import.meta.url), 'utf8'),
)
const appSource = await readFile(new URL('../src/App.tsx', import.meta.url), 'utf8')
const portfolioSource = await readFile(
  new URL('../src/pages/PortfolioPage.tsx', import.meta.url),
  'utf8',
)
const notesPageSource = await readFile(
  new URL('../src/pages/NotesPage.tsx', import.meta.url),
  'utf8',
)
const notesSource = await readFile(
  new URL('../src/notes.ts', import.meta.url),
  'utf8',
)
const siteChromeSource = await readFile(
  new URL('../src/components/SiteChrome.tsx', import.meta.url),
  'utf8',
)
const htmlSource = await readFile(new URL('../index.html', import.meta.url), 'utf8')
const stylesSource = await readFile(
  new URL('../src/styles.css', import.meta.url),
  'utf8',
)
const redirectsSource = await readFile(
  new URL('../public/_redirects', import.meta.url),
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

test('public portfolio content includes approved contact and excludes private data', () => {
  assert.equal(content.experiences.length, 3)
  assert.equal(content.projects.length, 3)
  assert.equal(content.featuredImpacts.length, 4)
  assert.ok(
    content.featuredImpacts.every(({ context, decision, outcome }) =>
      [context, decision, outcome].every(Boolean),
    ),
  )
  assert.doesNotMatch(
    JSON.stringify(content.featuredImpacts),
    /서비스 규모|등록 사용자|다운로드/,
  )
  assert.equal(content.profile.eyebrow, 'SOFTWARE ENGINEER · SINCE 2022')
  assert.equal(content.profile.role, 'Software Engineer')
  assert.equal(content.profile.email, 'hoheho18@gmail.com')
  assert.equal(
    content.experiences[0].metrics[0].label,
    '서비스 규모 · 등록 사용자',
  )
  assert.ok(
    content.experiences
      .flatMap(({ metrics }) => metrics)
      .filter(({ label }) => /다운로드|회원|사용자|MAU|관리 단지/.test(label))
      .every(({ label }) => label.startsWith('서비스 규모 ·')),
  )
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
  const pleasantProject = content.experiences.find(
    ({ company }) => company === '유쾌한프로젝트',
  )
  assert.match(JSON.stringify(pleasantProject), /LCOV.*76\.5%/)
  assert.match(JSON.stringify(pleasantProject), /Codemagic/)
  assert.deepEqual(pleasantProject.caseStudies[1].flow.map(({ steps }) => steps.length), [5, 5])
  assert.deepEqual(pleasantProject.caseStudies[3].flow.map(({ steps }) => steps.length), [3, 3])
  const seoulExchange = content.experiences.find(
    ({ company }) => company === '서울거래',
  )
  assert.equal(
    seoulExchange.caseStudies[0].title,
    '인수인계 없는 운영 앱의 병행 리빌드',
  )
  assert.match(seoulExchange.caseStudies[0].result, /출시 직전 검증 단계/)
  assert.match(seoulExchange.caseStudies[0].result, /운영 출시는 진행하지 못했지만/)
  assert.match(JSON.stringify(seoulExchange.highlights), /WebSocket 단절 시 재연결/)
  const dozn = content.experiences.find(({ company }) => company === '더즌')
  assert.match(dozn.summary, /기존 React Native 앱을 대체하는 Flutter 앱/)
  assert.match(dozn.caseStudies[0].result, /2022년 9월 Flutter 앱을 출시/)
  assert.match(JSON.stringify(dozn.highlights), /비회원도 전자투표에 참여/)
  assert.doesNotMatch(dozn.summary, /모바일·웹 전반.*주도/)
  assert.match(portfolioSource, /className="company-link"/)
  assert.match(portfolioSource, /content\.featuredImpacts\.map/)
  assert.match(portfolioSource, /caseStudy\.flow\.map/)
  assert.match(siteChromeSource, /<dialog/)
  assert.match(siteChromeSource, /Built with/)
  assert.match(siteChromeSource, /built-with-cloudflare\.svg/)
  assert.match(siteChromeSource, /github-invertocat-white\.svg/)
  assert.match(siteChromeSource, /현재 Frontend 요청 경로에서는 사용하지 않습니다/)
  assert.deepEqual(content.profile.links.map(({ label }) => label), [
    'GitHub',
    'Blog',
    'LinkedIn',
  ])
  assert.match(portfolioSource, /<LinkIcon label="Email"/)

  const serialized = JSON.stringify(content)
  assert.doesNotMatch(serialized, /01[016789][-. ]?\d{3,4}[-. ]?\d{4}/)
  assert.deepEqual(
    serialized.match(/[\w.+-]+@[\w.-]+\.[a-z]{2,}/gi),
    ['hoheho18@gmail.com'],
  )
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
  assert.match(portfolioSource + notesPageSource, /data-reveal/)
  assert.match(stylesSource, /@keyframes hero-enter/)
  assert.match(stylesSource, /@keyframes disclosure-enter/)
  assert.match(stylesSource, /@media \(hover: hover\) and \(pointer: fine\)/)
  assert.match(stylesSource, /@media \(prefers-reduced-motion: reduce\)/)
})

test('engineering notes have list and detail routes without a router dependency', () => {
  assert.match(appSource, /window\.location\.pathname\.split\('\/'\)/)
  assert.match(appSource, /<NotesPage slug=\{noteSlug\}/)
  assert.match(siteChromeSource, /href="\/notes\/"/)
  assert.match(notesPageSource, /notes\.find/)
  assert.match(notesPageSource, /href=\{`\/notes\/\$\{item\.slug\}\/`\}/)
  assert.match(notesSource, /id: 'Engineering'/)
  assert.match(notesSource, /id: 'Decision'/)
  assert.match(notesSource, /notes: Note\[\] = \[\]/)
  assert.match(notesPageSource, /noteCategories\.map/)
  assert.match(notesPageSource, /notes\.filter/)
  assert.match(redirectsSource, /\/notes\/\* \/index\.html 200/)
})

test('section navigation keeps the URL free of hash fragments', () => {
  assert.doesNotMatch(appSource + siteChromeSource, /href=["'][^"']*#/)
  assert.match(siteChromeSource, /sessionStorage\.setItem\(SCROLL_TARGET_KEY/)
  assert.match(appSource, /sessionStorage\.removeItem\(SCROLL_TARGET_KEY\)/)
  assert.match(appSource, /document\.getElementById\('content'\)\?\.focus\(\)/)
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
