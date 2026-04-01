import { Hono } from 'hono'
import { cors } from 'hono/cors'

type Bindings = {
  DB: D1Database
  BUCKET: R2Bucket
  ENVIRONMENT: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.use('*', cors({
  origin: ['http://localhost:*', 'https://leeeeeoy.dev'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
}))

app.get('/', (c) => {
  return c.json({ message: 'leeeeeoy portfolio API', version: '1.0.0' })
})

// TODO: 라우터 추가 예정
// import profileRouter from './routes/profile'
// import careerRouter from './routes/career'
// import projectRouter from './routes/project'
// import skillRouter from './routes/skill'
// app.route('/api/profile', profileRouter)
// app.route('/api/careers', careerRouter)
// app.route('/api/projects', projectRouter)
// app.route('/api/skills', skillRouter)

export default app
