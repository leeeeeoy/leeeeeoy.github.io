import { fileURLToPath } from 'node:url'
import { collectPosts } from './content.ts'

const posts = await collectPosts(
  fileURLToPath(new URL('../../../content/', import.meta.url)),
)
console.log(`Content valid: ${posts.length} published posts`)
