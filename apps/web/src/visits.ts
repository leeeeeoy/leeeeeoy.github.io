export type VisitStats = {
  today: number
  total: number
  day: string
  since: string | null
  timezone: string
}
let previousConsent: string | null | undefined
let latest: Promise<VisitStats | null> | undefined
let queue: Promise<unknown> = Promise.resolve()

export function loadVisitStats(consent: 'granted' | 'denied' | null) {
  const preview = window.location.hostname === 'preview-portfolio.leeeeeoy.xyz'
  if (
    !preview &&
    !['leeeeeoy.xyz', 'localhost', '127.0.0.1'].includes(
      window.location.hostname,
    )
  )
    return Promise.resolve(null)
  if (latest && previousConsent === consent) return latest
  previousConsent = consent
  // Serialize changes so withdrawing consent clears the cookie after an in-flight POST.
  latest = queue
    .then(async () => {
      if (!preview && consent === 'denied') {
        const withdrawal = await fetch('/api/visits', {
          method: 'DELETE',
          credentials: 'same-origin',
          signal: AbortSignal.timeout(5000),
        })
        if (!withdrawal.ok) return null
      }
      const response = await fetch('/api/visits', {
        method: !preview && consent === 'granted' ? 'POST' : 'GET',
        credentials: 'same-origin',
        headers:
          !preview && consent === 'granted'
            ? { 'X-Visit-Consent': 'granted' }
            : {},
        cache: 'no-store',
        signal: AbortSignal.timeout(5000),
      })
      if (!response.ok) return null
      const value = (await response.json()) as VisitStats
      if (
        !Number.isSafeInteger(value.today) ||
        !Number.isSafeInteger(value.total) ||
        value.today < 0 ||
        value.total < value.today ||
        value.timezone !== 'Asia/Seoul' ||
        (value.since !== null &&
          (typeof value.since !== 'string' ||
            !/^\d{4}-\d{2}-\d{2}$/.test(value.since))) ||
        !/^\d{4}-\d{2}-\d{2}$/.test(value.day)
      )
        return null
      return value
    })
    .catch(() => null)
  queue = latest
  return latest
}
