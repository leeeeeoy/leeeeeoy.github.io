import { Hono } from 'hono'
import { cors } from 'hono/cors'
import type { Bindings } from './types'
import profileRouter from './routes/profile'
import careerRouter from './routes/career'
import projectRouter from './routes/project'
import skillRouter from './routes/skill'

const app = new Hono<{ Bindings: Bindings }>()

app.use('*', cors({
  origin: (origin) => {
    if (!origin) return 'https://leeeeeoy.xyz'
    if (origin.startsWith('http://localhost:')) return origin
    if (origin === 'https://portfolio.leeeeeoy.xyz') return origin
    return null
  },
  allowMethods: ['GET'],
}))

app.get('/', (c) => {
  return c.json({ message: 'leeeeeoy portfolio API', version: '1.0.0' })
})

app.route('/api/profile', profileRouter)
app.route('/api/careers', careerRouter)
app.route('/api/projects', projectRouter)
app.route('/api/skills', skillRouter)

export default app
