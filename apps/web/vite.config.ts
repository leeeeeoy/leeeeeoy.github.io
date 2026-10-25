import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { fileURLToPath } from 'node:url'
import { sep } from 'node:path'
import { collectPosts } from './scripts/content'

const contentRoot = fileURLToPath(
  new URL('../../content/', import.meta.url),
).replace(/\/$/, '')
const moduleId = '\0virtual:posts'

export default defineConfig({
  server: {
    proxy: {
      '/api/visits': {
        target: 'http://127.0.0.1:8787',
        changeOrigin: true,
        headers: { 'CF-Connecting-IP': '127.0.0.1' },
      },
    },
  },
  preview: {
    proxy: {
      '/api/visits': {
        target: 'http://127.0.0.1:8787',
        changeOrigin: true,
        headers: { 'CF-Connecting-IP': '127.0.0.1' },
      },
    },
  },
  plugins: [
    react(),
    {
      name: 'site-content',
      async buildStart() {
        await collectPosts(contentRoot)
        this.addWatchFile(`${contentRoot}/lab`)
        this.addWatchFile(`${contentRoot}/writing`)
      },
      resolveId(id) {
        if (id === 'virtual:posts') return moduleId
      },
      async load(id) {
        if (id === moduleId)
          return `export default ${JSON.stringify(await collectPosts(contentRoot))}`
      },
      configureServer(server) {
        server.watcher.add(contentRoot)
        server.watcher.on('all', (event, file) => {
          if (
            !['add', 'change', 'unlink'].includes(event) ||
            !file.startsWith(contentRoot + sep) ||
            !/\.md$/i.test(file)
          )
            return
          const module = server.moduleGraph.getModuleById(moduleId)
          if (module) server.moduleGraph.invalidateModule(module)
          server.ws.send({ type: 'full-reload' })
        })
      },
    },
  ],
})
