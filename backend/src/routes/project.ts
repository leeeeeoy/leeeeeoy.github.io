import { Hono } from 'hono'
import type { Bindings } from '../types'

const router = new Hono<{ Bindings: Bindings }>()

const parseJson = (val: unknown): unknown[] => {
  if (!val || typeof val !== 'string') return []
  try { return JSON.parse(val) } catch { return [] }
}

router.get('/', async (c) => {
  const { results: rawProjects } = await c.env.DB.prepare(`
    SELECT
      p.*,
      (
        SELECT json_group_array(json_object(
          'id', s.id, 'name', s.name,
          'icon_url', s.icon_url, 'category', s.category
        ))
        FROM project_skill ps
        JOIN skill s ON ps.skill_id = s.id
        WHERE ps.project_id = p.id
      ) AS skills_json
    FROM project p
    ORDER BY p.sort_order
  `).all()

  const projects = rawProjects.map((p) => {
    const { skills_json, screenshots, features, tasks, ...rest } = p as Record<string, unknown>
    return {
      ...rest,
      skills: parseJson(skills_json),
      screenshots: parseJson(screenshots),
      features: parseJson(features),
      tasks: parseJson(tasks),
    }
  })

  c.header('Cache-Control', 'public, max-age=3600')
  return c.json(projects)
})

export default router
