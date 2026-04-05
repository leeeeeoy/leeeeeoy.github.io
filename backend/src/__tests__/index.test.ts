import { describe, it, expect } from 'vitest'
import { env } from 'cloudflare:test'
import app from '../index'

describe('GET /', () => {
  it('returns API info', async () => {
    const res = await app.fetch(new Request('http://localhost/'), env)
    expect(res.status).toBe(200)
    const body = await res.json() as { message: string; version: string }
    expect(body.message).toBe('leeeeeoy portfolio API')
  })
})
