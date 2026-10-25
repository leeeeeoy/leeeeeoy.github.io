import { useEffect, useState } from 'react'
import { language, ui } from '../content'
import { loadVisitStats, type VisitStats } from '../visits'

export default function VisitCounter({
  consent,
}: {
  consent: 'granted' | 'denied' | null
}) {
  const [stats, setStats] = useState<VisitStats | null>(null)
  useEffect(() => {
    let active = true
    void loadVisitStats(consent).then((value) => {
      if (active) setStats(value)
    })
    return () => {
      active = false
    }
  }, [consent])
  if (!stats) return null
  const number = new Intl.NumberFormat(language)
  return (
    <div className="visit-counter" aria-label={ui.visitStats}>
      <p>
        {ui.visitsToday} <strong>{number.format(stats.today)}</strong> ·{' '}
        {ui.visitsTotal} <strong>{number.format(stats.total)}</strong>
      </p>
    </div>
  )
}
