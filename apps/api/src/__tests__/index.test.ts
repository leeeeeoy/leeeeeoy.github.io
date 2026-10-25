import { describe, it, expect } from 'vitest'
import { env } from 'cloudflare:workers'
import app from '../index'
import type { Bindings } from '../types'

describe('GET /', () => {
  it('returns API info', async () => {
    const res = await app.fetch(new Request('http://localhost/'), env as Bindings)
    expect(res.status).toBe(200)
    const body = await res.json() as { message: string; version: string }
    expect(body.message).toBe('leeeeeoy portfolio API')
  })
})
