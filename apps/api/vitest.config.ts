import { cloudflareTest } from "@cloudflare/vitest-plugin";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [
    cloudflareTest({
      wrangler: { configPath: "./wrangler.toml" },
      miniflare: {
        bindings: {
          VISIT_HASH_SECRET: "local-test-only-secret-at-least-32-characters",
          ENVIRONMENT: "test",
        },
      },
    }),
  ],
  test: {
    setupFiles: ["./src/__tests__/setup.ts"],
  },
});
