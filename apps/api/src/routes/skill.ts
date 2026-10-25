import { Hono } from 'hono'
import type { Bindings } from '../types'

const router = new Hono<{ Bindings: Bindings }>()

router.get('/', async (c) => {
  const { results } = await c.env.DB.prepare(
    'SELECT * FROM skill ORDER BY sort_order'
  ).all<Record<string, unknown>>()

  const grouped: Record<string, Record<string, unknown>[]> = {}
  for (const skill of results) {
    const category = (skill as Record<string, unknown>).category as string
    if (!grouped[category]) grouped[category] = []
    grouped[category].push(skill as Record<string, unknown>)
  }

  c.header('Cache-Control', 'public, max-age=3600')
  return c.json(grouped)
})

export default router
