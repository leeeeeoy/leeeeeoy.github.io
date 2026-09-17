import { ui } from './content'

export const noteCategories = [
  {
    id: 'Engineering',
    title: 'Engineering',
    description:
      ui.engineeringDescription,
  },
  {
    id: 'Decision',
    title: 'Decisions',
    description:
      ui.decisionsDescription,
  },
] as const

export type Note = {
  slug: string
  title: string
  summary: string
  category: (typeof noteCategories)[number]['id']
  tags: string[]
  sections: {
    heading: string
    paragraphs: string[]
  }[]
}

export const notes: Note[] = []
