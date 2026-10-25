# Personal site API and visit counter

The existing Hono Worker and D1 are reused. Portfolio content still comes from
`apps/web/src/content.json`; only visit statistics use a runtime API. Existing
profile/career/project/skill routes and tables are preserved. The published route
is limited to `leeeeeoy.xyz/api/visits`; Workers.dev and version URLs are disabled.

## Counter contract

- `GET /api/visits`: read `{today,total,day,since,timezone}` without recording a
  visit or setting a cookie. `since` is null before the first counted visit.
- `POST /api/visits`: requires canonical Origin, `X-Visit-Consent: granted`, a
  Cloudflare-provided IP and the configured secret. Records a consenting visit.
- `DELETE /api/visits`: same-origin consent withdrawal; expires the browser cookie.
  Historical aggregate counts are preserved.
- The same IP **or** browser within 30 minutes of its last accepted request is
  deduplicated. This is a sliding inactivity window. At midnight Asia/Seoul a new
  day is counted, even if the previous visit was less than 30 minutes earlier.
- Daily HMAC-SHA256 keys include the date and identity type. Raw IPs, cookie UUIDs,
  full user agents, URLs and fingerprints are not stored in D1. HMACs are
  pseudonymous identifiers, not a guarantee of anonymity. No canvas/device
  fingerprinting is used.
- A daily HttpOnly/SameSite=Lax cookie helps deduplicate after an IP change.
  Secure is enabled in production. The cookie expires at KST midnight.
- Expired key rows are deleted on the next registration; with no traffic, deletion
  is delayed. Daily aggregate rows remain for cumulative totals.
- Shared IPs can undercount; simultaneous IP+cookie changes can overcount.
  Obvious bot User-Agents are excluded, but spoofed automation is not prevented.
  These are consenting **visits**, not unique people or all website traffic.
- D1 `batch()` makes cleanup, eligibility, increment, key refresh and totals one
  transaction. No application-side read-then-increment race is used.
- Frontend totals are snapshots on load/consent changes, not a real-time dashboard.
  It does not record on Preview. Failed/malformed API responses hide the counter,
  never replace statistics with invented zeros. The first genuine empty DB is 0.

## Local development

Use this app's lockfile and installed Wrangler; do not use `--remote` for tests.

1. Put a random secret of at least 32 characters in ignored `.dev.vars` as
   `VISIT_HASH_SECRET`, with `ENVIRONMENT="local"`. Never commit or print it.
2. Restore the privately retained `migrations/0001_visit_counter.sql`, then run
   `npx wrangler d1 migrations apply DB --local`. Deployment SQL and data exports
   are intentionally untracked; keep a separate private backup.
3. `npm run dev -- --local --port 8787 --ip 127.0.0.1`
4. In `apps/web`, run `npm run dev`. Vite proxies only `/api/visits` to local port
   8787 with a synthetic local IP. It never proxies local writes to production.
5. Accept the updated analytics notice to register. Declining only reads totals.

`npm test` runs the existing root test plus real local-D1 checks for concurrency,
rollback, clock boundaries, consent, origin, cookie and hash handling.
`npm run typecheck` checks Worker and tests. Web tests also check consent request
serialization, duplicate mounts, Preview read-only behavior and unavailable responses.

## Remote schema and release

The user authorized reuse of existing D1 and schema application on 2026-10-25.
An ignored private export is taken before adding migration `0001_visit_counter`.
The migration only adds `visit_days` and `visit_keys` (plus migration tracking);
it does not delete legacy tables or data. Reapplying through migrations is safe.

A production release is separate: verify the Cloudflare account, backup/migration,
route and required `VISIT_HASH_SECRET` before publishing. The production Worker `leeeeeoy-portfolio-backend` is deployed. **Do not blindly merge the
whole monorepo into main:** that triggers both app deployment workflows. Secret
commands can themselves publish a Worker version, so they require release scope
approval. No remote secret value is supplied by `.dev.vars` automatically.

Missing secret/IP fails closed with 503; failures must never fall back to a fixed
secret or un-hashed identifying data. Production smoke tests must check actual
Cloudflare headers, cookie flags, same-origin routing and duplicate behavior.

References: [D1 batch transactions](https://developers.cloudflare.com/d1/worker-api/d1-database/#batch),
[Web Crypto](https://developers.cloudflare.com/workers/runtime-apis/web-crypto/),
[CF-Connecting-IP](https://developers.cloudflare.com/fundamentals/reference/http-request-headers/#cf-connecting-ip).

## Environments and release (2026-10-25)

The app moved from `apps/legacy-api` to `apps/api`; the production Worker and D1
resource names are unchanged. `develop` deploys web and API with `--env preview`;
`main` deploys production. PRs only run checks. API tests use a synthetic schema
inside `src/__tests__/setup.ts` and do not require ignored deployment migrations,
local `.dev.vars` or existing local D1 state. Ignoring SQL does not hide the schema
from application queries or test fixtures, and does not remove historical files.

Preview uses `leeeeeoy-portfolio-backend-preview` and the separate
`leeeeeoy-portfolio-preview` D1. Its frontend only sends GET to `/api/visits`;
registration is disabled server-side. Empty Preview counts are real zeros, not
production statistics. R2 is deliberately not bound: existing content APIs are
not exposed by the Preview route. Cloudflare Access must continue protecting both
the website and `/api/visits`. No Preview HMAC secret is required while read-only.

The user-provided `VISIT_HASH_SECRET` is stored as an encrypted Worker Secret
(`secret_text`), with the same value preserved from the initial dashboard setting.
CI redeployment and production registration/deduplication have been verified.
Never put this key in plaintext Wrangler vars or reuse the local test secret. Secret setup may publish
a version and belongs to the separately approved production release. Verify the
GitHub `CLOUDFLARE_FRONTEND_API_TOKEN` is shared by Web and API deployment and
must publish both Workers, edit the exact zone route, and read the existing R2
bucket configuration (`Workers R2 Storage Read`). Its existing Secret name
and `CLOUDFLARE_ACCOUNT_ID` are retained; `CLOUDFLARE_API_TOKEN` is no longer
referenced by these workflows.
The production D1 counter schema is already applied; do not reset it or re-import
Preview data. Deployment SQL is applied manually after backup, never implicitly
by CI. A main merge triggers both workflows, so obtain release approval first.

Rollback: redeploy the prior web version and prior API version if one exists. For
the first API release, remove only the newly introduced visitor route if needed;
retain D1 tables and backups. Worker rollback does not roll back D1 data. The
frontend hides the counter on API errors, so portfolio content remains available.

Environment configuration follows [Wrangler environments](https://developers.cloudflare.com/workers/wrangler/environments/).

The repository is now `leeeeeoy/personal-space`. Legacy GitHub Pages and its
`github-pages` environment are disabled; custom domains and Worker/D1/R2 resource
names are unchanged. Historical archive URLs describe their original context.
