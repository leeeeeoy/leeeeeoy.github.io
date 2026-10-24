CREATE TABLE resources (
    id integer PRIMARY KEY,
    completed_count integer NOT NULL DEFAULT 0 CHECK (completed_count >= 0)
);
CREATE TABLE appointments (
    id text PRIMARY KEY,
    resource_id integer NOT NULL REFERENCES resources(id),
    booking_id text,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL CHECK (ends_at > starts_at),
    status text NOT NULL CHECK (status IN ('PENDING','CANCELLED','COMPLETED')),
    cancelled_from text CHECK (cancelled_from IN ('PENDING','COMPLETED'))
);
CREATE INDEX appointments_resource_active ON appointments(resource_id,starts_at) WHERE status <> 'CANCELLED';
CREATE TABLE appointment_events (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id text NOT NULL REFERENCES appointments(id),
    kind text NOT NULL CHECK (kind IN ('CREATE','CANCEL','RESTORE','RESCHEDULE','COMPLETE')),
    occurred_at timestamptz NOT NULL DEFAULT now()
);
