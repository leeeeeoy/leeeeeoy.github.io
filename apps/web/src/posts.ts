import posts from 'virtual:posts'

export type Section = 'lab' | 'writing'
export interface Post {
  section: Section
  slug: string
  title: string
  date: string
  summary: string
  tags: string[]
  updated?: string
  body: string
}

export { posts }

export function getPost(section: Section, slug: string) {
  return posts.find((post) => post.section === section && post.slug === slug)
}
