export type EngineeringNote = {
  slug: string
  title: string
  summary: string
  category: 'Troubleshooting' | 'Retrospective'
  tags: string[]
  sections: {
    heading: string
    paragraphs: string[]
  }[]
}

export const engineeringNotes: EngineeringNote[] = []
