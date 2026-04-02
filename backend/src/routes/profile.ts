import { Hono } from 'hono'
import type { Bindings } from '../types'

const router = new Hono<{ Bindings: Bindings }>()

router.get('/', async (c) => {
  const profile = await c.env.DB.prepare(
    'SELECT * FROM profile WHERE id = 1'
  ).first()

  if (!profile) return c.json({ error: 'Not found' }, 404)

  c.header('Cache-Control', 'public, max-age=3600')
  return c.json(profile)
})

export default router
