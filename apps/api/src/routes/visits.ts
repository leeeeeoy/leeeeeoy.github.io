import { Hono } from "hono";
import { getCookie, setCookie, deleteCookie } from "hono/cookie";
import type { Bindings } from "../types";

const router = new Hono<{ Bindings: Bindings }>();
const cookieName = "leeeeeoy_visit";
const windowMs = 30 * 60 * 1000;
const uuid =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const totalsSQL = `SELECT COALESCE(SUM(visits), 0) AS total,
  COALESCE(SUM(CASE WHEN day = ? THEN visits ELSE 0 END), 0) AS today,
  MIN(CASE WHEN visits > 0 THEN day END) AS since FROM visit_days`;

export function koreaDay(now: number) {
  return new Date(now + 9 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

function allowedOrigin(origin: string | undefined, environment: string) {
  if (origin === "https://leeeeeoy.xyz") return true;
  if (environment !== "local" && environment !== "test") return false;
  if (!origin) return false;
  try {
    const url = new URL(origin);
    return (
      url.protocol === "http:" &&
      ["localhost", "127.0.0.1"].includes(url.hostname)
    );
  } catch {
    return false;
  }
}

async function fingerprint(
  key: CryptoKey,
  day: string,
  kind: string,
  value: string,
) {
  const encoder = new TextEncoder();
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(`${day}|${kind}|${value}`),
  );
  return Array.from(new Uint8Array(signature), (byte) =>
    byte.toString(16).padStart(2, "0"),
  ).join("");
}

router.use("*", async (c, next) => {
  c.header("Cache-Control", "no-store");
  c.header("X-Content-Type-Options", "nosniff");
  if (["GET", "POST"].includes(c.req.method)) {
    try {
      // shortcut: per-location admission is approximate; add edge/global controls if needed.
      const { success } = await c.env.VISIT_REQUEST_LIMITER.limit({ key: "visits" });
      if (!success) {
        c.header("Retry-After", "60");
        return c.json({ error: "Visit request limit reached" }, 429);
      }
    } catch {
      return c.json({ error: "Visit counter unavailable" }, 503);
    }
  }
  await next();
});

router.get("/", async (c) => {
  try {
    const day = koreaDay(Date.now());
    const totals = await c.env.DB.prepare(totalsSQL).bind(day).first();
    return c.json({ ...totals, day, timezone: "Asia/Seoul" });
  } catch {
    return c.json({ error: "Visit statistics unavailable" }, 503);
  }
});

router.post("/", async (c) => {
  if (!allowedOrigin(c.req.header("Origin"), c.env.ENVIRONMENT))
    return c.json({ error: "Origin not allowed" }, 403);
  // Only the production site and explicitly local/test runtimes can record visits.
  if (!["production", "local", "test"].includes(c.env.ENVIRONMENT))
    return c.json({ error: "Counting disabled" }, 403);
  if (c.req.header("X-Visit-Consent") !== "granted")
    return c.json({ error: "Analytics consent required" }, 403);
  if (/bot|spider|crawler|headless/i.test(c.req.header("User-Agent") ?? ""))
    return c.json({ error: "Automated client excluded" }, 403);
  const ip = c.req.header("CF-Connecting-IP");
  if (!ip || !c.env.VISIT_HASH_SECRET || c.env.VISIT_HASH_SECRET.length < 32)
    return c.json({ error: "Visit counter not configured" }, 503);
  const now = Date.now();
  const day = koreaDay(now);
  const saved = getCookie(c, cookieName);
  const browser = saved && uuid.test(saved) ? saved : crypto.randomUUID();
  const expiry = Date.parse(`${day}T00:00:00+09:00`) + 24 * 60 * 60 * 1000;
  try {
    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(c.env.VISIT_HASH_SECRET),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"],
    );
    const [ipHash, browserHash] = await Promise.all([
      fingerprint(key, day, "ip", ip),
      fingerprint(key, day, "browser", browser),
    ]);
    // One D1 transaction: decide, increment, then refresh both dedup keys.
    const result = await c.env.DB.batch<{
      today: number;
      total: number;
      since: string | null;
    }>([
      c.env.DB.prepare(
        `DELETE FROM visit_keys WHERE key_hash IN
          (SELECT key_hash FROM visit_keys WHERE expires_at <= ? LIMIT 128)`,
      ).bind(now),
      c.env.DB.prepare(
        "INSERT OR IGNORE INTO visit_days(day, visits) VALUES (?, 0)",
      ).bind(day),
      c.env.DB.prepare(
        `UPDATE visit_days SET visits = visits + 1 WHERE day = ?
        AND NOT EXISTS (SELECT 1 FROM visit_keys
          WHERE key_hash IN (?, ?) AND last_seen > ?)`,
      ).bind(day, ipHash, browserHash, now - windowMs),
      c.env.DB.prepare(
        `INSERT INTO visit_keys(key_hash, last_seen, expires_at) VALUES (?, ?, ?), (?, ?, ?)
        ON CONFLICT(key_hash) DO UPDATE SET last_seen = MAX(last_seen, excluded.last_seen), expires_at = excluded.expires_at`,
      ).bind(ipHash, now, expiry, browserHash, now, expiry),
      c.env.DB.prepare(totalsSQL).bind(day),
    ]);
    setCookie(c, cookieName, browser, {
      path: "/api/visits",
      httpOnly: true,
      sameSite: "Lax",
      secure: c.env.ENVIRONMENT === "production",
      maxAge: Math.max(1, Math.floor((expiry - now) / 1000)),
    });
    return c.json({ ...result[4].results[0], day, timezone: "Asia/Seoul" });
  } catch {
    return c.json({ error: "Visit counter unavailable" }, 503);
  }
});

router.delete("/", async (c) => {
  if (!allowedOrigin(c.req.header("Origin"), c.env.ENVIRONMENT))
    return c.json({ error: "Origin not allowed" }, 403);
  deleteCookie(c, cookieName, {
    path: "/api/visits",
    secure: c.env.ENVIRONMENT === "production",
    httpOnly: true,
    sameSite: "Lax",
  });
  return c.body(null, 204);
});

export default router;
