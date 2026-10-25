import { env, applyD1Migrations } from "cloudflare:test";
import type { Bindings } from "../types";

// Public synthetic test schema; deployment migrations remain local and untracked.
await applyD1Migrations((env as Bindings).DB, [
  {
    name: "test_visit_counter",
    queries: [
      "CREATE TABLE visit_days (day TEXT PRIMARY KEY, visits INTEGER NOT NULL DEFAULT 0 CHECK (visits >= 0))",
      "CREATE TABLE visit_keys (key_hash TEXT PRIMARY KEY, last_seen INTEGER NOT NULL, expires_at INTEGER NOT NULL)",
      "CREATE INDEX visit_keys_expiry ON visit_keys(expires_at)",
    ],
  },
]);
