CREATE TABLE lab_identity (
    singleton boolean PRIMARY KEY CHECK (singleton),
    token text NOT NULL
);
INSERT INTO lab_identity VALUES (true, 'concurrency-integrity-p0-v1');

CREATE TABLE resources (
    id text PRIMARY KEY
);

-- No overlap exclusion yet: P0 must detect an intentionally seeded violation.
CREATE TABLE slots (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    resource_id text NOT NULL REFERENCES resources(id),
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    active boolean NOT NULL DEFAULT true,
    CHECK (starts_at < ends_at)
);
