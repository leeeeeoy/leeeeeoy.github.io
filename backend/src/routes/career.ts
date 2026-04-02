import { Hono } from 'hono'
import type { Bindings } from '../types'

const router = new Hono<{ Bindings: Bindings }>()

const parseJson = (val: unknown): unknown[] => {
  if (!val || typeof val !== 'string') return []
  try { return JSON.parse(val) } catch { return [] }
}

router.get('/', async (c) => {
  const { results: careers } = await c.env.DB.prepare(
    'SELECT * FROM career ORDER BY sort_order'
  ).all()

  const { results: rawDetails } = await c.env.DB.prepare(`
    SELECT
      cd.*,
      (
        SELECT json_group_array(json_object(
          'id', s.id, 'name', s.name,
          'icon_url', s.icon_url, 'category', s.category
        ))
        FROM career_detail_skill cds
        JOIN skill s ON cds.skill_id = s.id
        WHERE cds.career_detail_id = cd.id
      ) AS skills_json
    FROM career_detail cd
    ORDER BY cd.career_id, cd.sort_order
  `).all()

  const details = rawDetails.map((d) => {
    const { skills_json, screenshots, features, tasks, issues, ...rest } = d as Record<string, unknown>
    return {
      ...rest,
      skills: parseJson(skills_json),
      screenshots: parseJson(screenshots),
      features: parseJson(features),
      tasks: parseJson(tasks),
      issues: parseJson(issues),
    }
  })

  const detailsByCareer = details.reduce((acc, d) => {
    const careerId = (d as Record<string, unknown>).career_id as number
    if (!acc[careerId]) acc[careerId] = []
    acc[careerId].push(d)
    return acc
  }, {} as Record<number, unknown[]>)

  const result = careers.map((career) => ({
    ...career,
    details: detailsByCareer[(career as Record<string, unknown>).id as number] ?? [],
  }))

  c.header('Cache-Control', 'public, max-age=3600')
  return c.json(result)
})

export default router
