import { beforeEach, afterEach, describe, it, expect, vi } from "vitest";
import { env } from "cloudflare:workers";
import app from "../index";
import type { Bindings } from "../types";

const bindings = env as Bindings;
const origin = "https://leeeeeoy.xyz";
function visit(
  ip = "192.0.2.1",
  cookie = "",
  extra: Record<string, string> = {},
  options = bindings,
) {
  return app.fetch(
    new Request(`${origin}/api/visits`, {
      method: "POST",
      headers: {
        Origin: origin,
        "CF-Connecting-IP": ip,
        "User-Agent": "Test browser",
        "X-Visit-Consent": "granted",
        Cookie: cookie,
        ...extra,
      },
    }),
    options,
  );
}
async function stats() {
  return (
    await app.fetch(new Request(`${origin}/api/visits`), bindings)
  ).json() as Promise<{
    today: number;
    total: number;
    day: string;
    since: string | null;
  }>;
}
function cookie(response: Response) {
  return response.headers.get("Set-Cookie")!.split(";")[0];
}

describe("visit counter on real local D1", () => {
  beforeEach(async () => {
    // The current Workers plugin isolates storage per file, not per test.
    await bindings.DB.exec("DROP TRIGGER IF EXISTS fail_keys");
    await bindings.DB.batch([
      bindings.DB.prepare("DELETE FROM visit_keys"),
      bindings.DB.prepare("DELETE FROM visit_days"),
    ]);
    vi.setSystemTime(new Date("2026-10-25T01:00:00Z"));
  });
  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });
  it("GET does not record or create identifiers; initial zero is real", async () => {
    const r = await app.fetch(new Request(`${origin}/api/visits`), bindings);
    expect(r.status).toBe(200);
    expect(r.headers.get("Set-Cookie")).toBeNull();
    expect(r.headers.get("Cache-Control")).toBe("no-store");
    expect(await r.json()).toMatchObject({
      today: 0,
      total: 0,
      since: null,
      timezone: "Asia/Seoul",
    });
    expect(
      (await bindings.DB.prepare("SELECT COUNT(*) n FROM visit_keys").first())!
        .n,
    ).toBe(0);
  });
  it("deduplicates same IP despite cleared/changed browser cookies", async () => {
    await visit();
    await visit();
    await visit("192.0.2.1", "leeeeeoy_visit=bad-input");
    expect(await stats()).toMatchObject({ today: 1, total: 1 });
  });
  it("deduplicates a browser after an IP change", async () => {
    const first = await visit();
    await visit("192.0.2.2", cookie(first));
    expect(await stats()).toMatchObject({ total: 1 });
  });
  it("counts independent IPs and browsers without lost updates", async () => {
    const results = await Promise.all(
      Array.from({ length: 20 }, (_, n) => visit(`192.0.2.${n + 1}`)),
    );
    expect(results.every((r) => r.status === 200)).toBe(true);
    expect(await stats()).toMatchObject({ today: 20, total: 20 });
  });
  it("counts simultaneous identical IPs once in the DB, not only in responses", async () => {
    const results = await Promise.all(
      Array.from({ length: 25 }, () => visit()),
    );
    expect(results.every((r) => r.status === 200)).toBe(true);
    expect(await stats()).toMatchObject({ today: 1, total: 1 });
  });
  it("uses a sliding inactivity window and counts again at the exact boundary", async () => {
    const first = await visit();
    vi.setSystemTime(new Date("2026-10-25T01:29:59Z"));
    await visit("192.0.2.1", cookie(first));
    vi.setSystemTime(new Date("2026-10-25T01:30:00Z"));
    await visit("192.0.2.1", cookie(first));
    expect(await stats()).toMatchObject({ total: 1 });
    vi.setSystemTime(new Date("2026-10-25T02:00:00Z"));
    await visit("192.0.2.1", cookie(first));
    expect(await stats()).toMatchObject({ total: 2 });
  });
  it("starts a new KST day, preserves totals and cleans expired keys", async () => {
    vi.setSystemTime(new Date("2026-10-25T14:59:59Z"));
    const first = await visit();
    vi.setSystemTime(new Date("2026-10-25T15:00:00Z"));
    await visit("192.0.2.1", cookie(first));
    expect(await stats()).toMatchObject({
      day: "2026-10-26",
      today: 1,
      total: 2,
      since: "2026-10-25",
    });
    expect(
      (await bindings.DB.prepare("SELECT COUNT(*) n FROM visit_keys").first())!
        .n,
    ).toBe(2);
  });
  it("stores only daily HMACs and timestamps; cookie is bounded and HttpOnly", async () => {
    const response = await visit(
      "192.0.2.123",
      "",
      {},
      { ...bindings, ENVIRONMENT: "production" },
    );
    const h = response.headers.get("Set-Cookie")!;
    expect(h).toMatch(/HttpOnly/);
    expect(h).toMatch(/Secure/);
    expect(h).toMatch(/SameSite=Lax/);
    const rows = await bindings.DB.prepare("SELECT * FROM visit_keys").all();
    expect(rows.results).toHaveLength(2);
    for (const row of rows.results)
      expect(row.key_hash).toMatch(/^[a-f0-9]{64}$/);
    expect(JSON.stringify(rows)).not.toContain("192.0.2.123");
    expect(JSON.stringify(rows)).not.toContain(cookie(response).split("=")[1]);
  });
  it("requires consent and a canonical Origin; excludes Preview and obvious bots", async () => {
    const rejected: Record<string, string>[] = [
      { Origin: "https://evil.invalid" },
      { Origin: "https://preview-portfolio.leeeeeoy.xyz" },
      { "X-Visit-Consent": "denied" },
      { "User-Agent": "ExampleBot" },
    ];
    for (const headers of rejected)
      expect((await visit("192.0.2.1", "", headers)).status).toBe(403);
    expect(
      (
        await visit(
          "192.0.2.1",
          "",
          {},
          { ...bindings, ENVIRONMENT: "preview" },
        )
      ).status,
    ).toBe(403);
    expect(
      (
        await visit(
          "192.0.2.1",
          "",
          { Origin: "http://127.0.0.1:5184" },
          { ...bindings, ENVIRONMENT: "production" },
        )
      ).status,
    ).toBe(403);
    expect(await stats()).toMatchObject({ total: 0 });
  });
  it("fails closed when trusted IP or secret is missing", async () => {
    expect((await visit("", "", {})).status).toBe(503);
    expect(
      (await visit("192.0.2.1", "", {}, { ...bindings, VISIT_HASH_SECRET: "" }))
        .status,
    ).toBe(503);
    expect(await stats()).toMatchObject({ total: 0 });
  });
  it("rolls back the counter when the key write fails", async () => {
    await bindings.DB.exec(
      "CREATE TRIGGER fail_keys BEFORE INSERT ON visit_keys BEGIN SELECT RAISE(ABORT, 'forced test failure'); END;",
    );
    expect((await visit()).status).toBe(503);
    expect(await stats()).toMatchObject({ total: 0 });
    expect(
      (await bindings.DB.prepare("SELECT COUNT(*) n FROM visit_days").first())!
        .n,
    ).toBe(0);
  });
  it("clears the browser cookie on withdrawal without falsifying historical totals", async () => {
    const first = await visit();
    const response = await app.fetch(
      new Request(`${origin}/api/visits`, {
        method: "DELETE",
        headers: { Origin: origin, Cookie: cookie(first) },
      }),
      bindings,
    );
    expect(response.status).toBe(204);
    expect(response.headers.get("Set-Cookie")).toMatch(/Max-Age=0/);
    expect(await stats()).toMatchObject({ total: 1 });
  });
  it("rejects excess reads and writes before D1 work or cookie creation", async () => {
    const prepare = vi.spyOn(bindings.DB, "prepare");
    const limiter = { limit: vi.fn(async () => ({ success: false })) };
    const limited = { ...bindings, VISIT_REQUEST_LIMITER: limiter };
    const read = await app.fetch(new Request(`${origin}/api/visits`), limited);
    const write = await visit("192.0.2.1", "", {}, limited);
    for (const response of [read, write]) {
      expect(response.status).toBe(429);
      expect(response.headers.get("Retry-After")).toBe("60");
      expect(response.headers.get("Set-Cookie")).toBeNull();
    }
    expect(prepare).not.toHaveBeenCalled();
    expect(limiter.limit).toHaveBeenNthCalledWith(1, { key: "visits" });
    expect(limiter.limit).toHaveBeenNthCalledWith(2, { key: "visits" });
    expect(await stats()).toMatchObject({ total: 0 });
  });
  it("fails closed on admission errors but still permits consent withdrawal", async () => {
    const prepare = vi.spyOn(bindings.DB, "prepare");
    const limiter = {
      limit: vi.fn(async () => {
        throw new Error("forced admission failure");
      }),
    };
    const unavailable = { ...bindings, VISIT_REQUEST_LIMITER: limiter };
    expect((await visit("192.0.2.1", "", {}, unavailable)).status).toBe(503);
    expect(prepare).not.toHaveBeenCalled();
    limiter.limit.mockClear();
    const withdrawal = await app.fetch(
      new Request(`${origin}/api/visits`, {
        method: "DELETE",
        headers: { Origin: origin },
      }),
      unavailable,
    );
    expect(withdrawal.status).toBe(204);
    expect(withdrawal.headers.get("Set-Cookie")).toMatch(/Max-Age=0/);
    expect(limiter.limit).not.toHaveBeenCalled();
  });
  it("imports one request-scoped HMAC key and preserves known fingerprints", async () => {
    const imports = vi.spyOn(crypto.subtle, "importKey");
    await visit(
      "192.0.2.123",
      "leeeeeoy_visit=11111111-1111-4111-8111-111111111111",
    );
    expect(imports).toHaveBeenCalledTimes(1);
    const rows = await bindings.DB.prepare("SELECT key_hash FROM visit_keys").all();
    expect(rows.results.map((row) => row.key_hash).sort()).toEqual([
      "95792b9a92434abdd42e4939e8de41d6c55e934f2e3593d183ebff48a59f3ccc",
      "a98a2490bc12ead79a1bd9422b5592988ed9cd1f5ddeb4087f3e5ae9b2549099",
    ]);
  });
  it("bounds expired-key cleanup without changing current-day counts", async () => {
    await bindings.DB.batch(
      Array.from({ length: 300 }, (_, n) =>
        bindings.DB.prepare(
          "INSERT INTO visit_keys VALUES (?, 0, ?)",
        ).bind(`expired-${n}`, Date.now() - 1),
      ),
    );
    expect((await visit()).status).toBe(200);
    expect(
      (await bindings.DB.prepare(
        "SELECT COUNT(*) n FROM visit_keys WHERE expires_at <= ?",
      ).bind(Date.now()).first())!.n,
    ).toBe(172);
    expect(await stats()).toMatchObject({ total: 1, today: 1 });
  });
});
