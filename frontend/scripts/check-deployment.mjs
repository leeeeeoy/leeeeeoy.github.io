import assert from 'node:assert/strict'
import { createHash } from 'node:crypto'
import { readFile } from 'node:fs/promises'

const base = process.argv[2]
assert.ok(base, 'Usage: node scripts/check-deployment.mjs https://portfolio.example.com')
if (process.argv.includes('--protected')) {
  const response = await fetch(base, { redirect: 'manual', headers: { Accept: 'text/html' } })
  if (response.status === 302) {
    assert.match(response.headers.get('location'), /\.cloudflareaccess\.com\//)
  } else {
    assert.equal(response.status, 403, 'Unauthenticated preview must be denied')
    assert.match(response.headers.get('www-authenticate') ?? '', /Cloudflare-Access/)
  }
  console.log('PASS: unauthenticated preview is protected by Access')
  process.exit(0)
}
const html = await readFile(new URL('../dist/index.html', import.meta.url), 'utf8')
const assets = [...html.matchAll(/(?:src|href)="(\/assets\/[^"]+)"/g)].map(([_, path]) => path)
assert.ok(assets.length >= 2)
for (const path of ['/', '/?lang=en', '/notes/', '/notes/?lang=en']) {
  const response = await fetch(new URL(path, base))
  assert.equal(response.status, 200, path)
  assert.equal(response.headers.get('x-content-type-options'), 'nosniff', path)
  assert.equal(response.headers.get('x-frame-options'), 'DENY', path)
  assert.match(response.headers.get('content-security-policy'), /frame-ancestors 'none'/, path)
  assert.match(response.headers.get('cache-control'), /max-age=0/, path)
  const body = await response.text()
  for (const asset of assets) assert.ok(body.includes(asset), `${path}: current build ${asset}`)
}
for (const path of assets) {
  const response = await fetch(new URL(path, base))
  assert.equal(response.status, 200, path)
  assert.match(response.headers.get('cache-control'), /max-age=31536000, immutable/, path)
  const actual = Buffer.from(await response.arrayBuffer())
  const expected = await readFile(new URL(`../dist${path}`, import.meta.url))
  const hash = (value) => createHash('sha256').update(value).digest('hex')
  assert.equal(hash(actual), hash(expected), path)
}
console.log(`PASS: routes, headers, cache policy, and ${assets.length} deployed assets`)
