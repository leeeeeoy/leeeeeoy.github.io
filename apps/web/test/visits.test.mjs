import assert from 'node:assert/strict'
import test from 'node:test'
import { createServer } from 'vite'

const data = {
  today: 2,
  total: 5,
  since: '2026-10-25',
  day: '2026-10-25',
  timezone: 'Asia/Seoul',
}
async function withClient(host, run) {
  const original = { window: globalThis.window, fetch: globalThis.fetch }
  const server = await createServer({
    server: { middlewareMode: true, hmr: false, ws: false },
    optimizeDeps: { noDiscovery: true, include: [] },
  })
  globalThis.window = { location: new URL(`https://${host}/`) }
  try {
    await run((await server.ssrLoadModule('/src/visits.ts')).loadVisitStats)
  } finally {
    globalThis.window = original.window
    globalThis.fetch = original.fetch
    await server.close()
  }
}

test('visit totals are readable without consent and duplicate mount does not POST twice', async () => {
  await withClient('leeeeeoy.xyz', async (load) => {
    const methods = []
    globalThis.fetch = async (_, options) => {
      methods.push(options.method)
      return Response.json(data)
    }
    assert.deepEqual(await load(null), data)
    const first = load('granted')
    const second = load('granted')
    assert.equal(first, second)
    assert.deepEqual(await first, data)
    assert.deepEqual(methods, ['GET', 'POST'])
  })
})
test('withdrawal is queued after an in-flight registration and clears the cookie before reading', async () => {
  await withClient('leeeeeoy.xyz', async (load) => {
    const methods = []
    let release
    const gate = new Promise((resolve) => {
      release = resolve
    })
    globalThis.fetch = async (_, options) => {
      methods.push(options.method)
      if (options.method === 'POST') await gate
      return options.method === 'DELETE'
        ? new Response(null, { status: 204 })
        : Response.json(data)
    }
    const registration = load('granted')
    const withdrawal = load('denied')
    await Promise.resolve()
    assert.deepEqual(methods, ['POST'])
    release()
    await registration
    await withdrawal
    assert.deepEqual(methods, ['POST', 'DELETE', 'GET'])
  })
})
test('preview only reads isolated totals and failures are not displayed as zero visits', async () => {
  await withClient('preview-portfolio.leeeeeoy.xyz', async (load) => {
    const methods = []
    globalThis.fetch = async (_, options) => {
      methods.push(options.method)
      return Response.json(data)
    }
    assert.deepEqual(await load('granted'), data)
    assert.deepEqual(await load('denied'), data)
    assert.deepEqual(methods, ['GET', 'GET'])
  })
  await withClient('leeeeeoy.xyz', async (load) => {
    globalThis.fetch = async () => new Response('Unavailable', { status: 503 })
    assert.equal(await load('granted'), null)
  })
  await withClient('leeeeeoy.xyz', async (load) => {
    globalThis.fetch = async () => Response.json({ ...data, total: -1 })
    assert.equal(await load(null), null)
  })
})
