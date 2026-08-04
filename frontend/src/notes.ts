export const noteCategories = [
  {
    id: 'Engineering',
    title: 'Engineering',
    description:
      '성능, 아키텍처, 플랫폼 제약과 외부 연동 문제를 분석하고 해결한 과정을 기록합니다.',
  },
  {
    id: 'Decision',
    title: 'Decisions',
    description:
      '우선순위와 기술 선택, 제품 실험에서 무엇을 근거로 결정했는지 기록합니다.',
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
