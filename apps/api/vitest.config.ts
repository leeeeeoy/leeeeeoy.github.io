import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

export default defineWorkersConfig({
  test: {
    setupFiles: ["./src/__tests__/setup.ts"],
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.toml" },
        miniflare: {
          bindings: {
            VISIT_HASH_SECRET: "local-test-only-secret-at-least-32-characters",
            ENVIRONMENT: "test",
          },
        },
      },
    },
  },
});
