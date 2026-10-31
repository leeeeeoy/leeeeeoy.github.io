export type Bindings = {
  DB: D1Database;
  VISIT_REQUEST_LIMITER: RateLimit;
  BUCKET: R2Bucket;
  ENVIRONMENT: string;
  ASSETS_BASE_URL: string;
  VISIT_HASH_SECRET: string;
};
