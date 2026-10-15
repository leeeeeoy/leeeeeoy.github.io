import { readdir, readFile } from 'node:fs/promises'
import { join } from 'node:path'
import { parseDocument } from 'yaml'
import type { Post, Section } from '../src/posts.ts'

export function parsePost(
  source: string,
  section: Section,
  slug: string,
  file: string,
): Post & { draft: boolean } {
  const fail = (message: string): never => {
    throw new Error(`${file}: ${message}`)
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug))
    fail('slug must be a lowercase, hyphen-separated filename')
  const normalized = source.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n')
  const match = normalized.match(/^---\n([\s\S]*?)\n---(?:\n|$)/)
  if (!match) return fail('YAML frontmatter between --- lines is required')
  const document = parseDocument(match[1], { prettyErrors: false })
  if (document.errors.length || document.warnings.length)
    fail(
      `invalid YAML: ${[...document.errors, ...document.warnings].map((error) => error.message).join('; ')}`,
    )
  let metadata: unknown
  try {
    metadata = document.toJS()
  } catch {
    return fail('invalid YAML values or excessive aliases')
  }
  if (!metadata || typeof metadata !== 'object' || Array.isArray(metadata))
    fail('frontmatter must be a mapping')
  const data = metadata as Record<string, unknown>
  for (const key of Object.keys(data)) {
    if (!['title', 'date', 'summary', 'tags', 'draft', 'updated'].includes(key))
      fail(`unsupported field: ${key}`)
  }
  const text = (key: string) => {
    const value = data[key]
    if (typeof value !== 'string' || !value.trim())
      return fail(`${key} must be a non-empty string`)
    return value.trim()
  }
  const date = (key: string) => {
    const value = text(key)
    const parsed = new Date(`${value}T00:00:00Z`)
    if (
      !/^\d{4}-\d{2}-\d{2}$/.test(value) ||
      value.startsWith('0000') ||
      Number.isNaN(parsed.getTime()) ||
      parsed.toISOString().slice(0, 10) !== value
    )
      fail(`${key} must be a valid YYYY-MM-DD calendar date`)
    return value
  }
  const title = text('title')
  const published = date('date')
  const summary = text('summary')
  const updated = data.updated === undefined ? undefined : date('updated')
  if (updated && updated < published) fail('updated must not precede date')
  if (data.draft !== undefined && typeof data.draft !== 'boolean')
    fail('draft must be a boolean')
  if (
    data.tags !== undefined &&
    (!Array.isArray(data.tags) ||
      data.tags.some((tag) => typeof tag !== 'string' || !tag.trim()))
  )
    fail('tags must be an array of non-empty strings')
  return {
    section,
    slug,
    title,
    date: published,
    summary,
    updated,
    tags: (data.tags as string[] | undefined)?.map((tag) => tag.trim()) ?? [],
    draft: data.draft !== false,
    body: normalized.slice(match[0].length),
  }
}

export async function collectPosts(root: string): Promise<Post[]> {
  const posts: (Post & { draft: boolean })[] = []
  for (const section of ['lab', 'writing'] as const) {
    const entries = await readdir(join(root, section), { withFileTypes: true })
    for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
      if (entry.name === '.gitkeep') continue
      const file = join(root, section, entry.name)
      if (!entry.isFile() || !/\.md$/i.test(entry.name))
        throw new Error(`${file}: only flat Markdown files are allowed`)
      const slug = entry.name.slice(0, -3)
      const post = parsePost(await readFile(file, 'utf8'), section, slug, file)
      posts.push(post)
    }
  }
  return publishPosts(posts)
}

export function publishPosts(posts: (Post & { draft: boolean })[]): Post[] {
  const seen = new Set<string>()
  for (const post of posts) {
    const key = `${post.section}/${post.slug}`
    if (seen.has(key))
      throw new Error(
        `content/${key}.md: duplicate slug in ${post.section}: ${post.slug}`,
      )
    seen.add(key)
  }
  return posts
    .flatMap(({ draft, ...post }) => (draft ? [] : [post]))
    .sort(
      (a, b) => b.date.localeCompare(a.date) || a.slug.localeCompare(b.slug),
    )
}
