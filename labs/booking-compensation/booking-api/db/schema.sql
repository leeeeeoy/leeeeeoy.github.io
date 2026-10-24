CREATE TABLE users (
    id bigint PRIMARY KEY,
    points integer NOT NULL CHECK (points >= 0)
);
CREATE TABLE bookings (
    id text PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users(id),
    resource_id bigint NOT NULL,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL CHECK (ends_at > starts_at),
    amount integer NOT NULL CHECK (amount > 0),
    points integer NOT NULL CHECK (points >= 0 AND points <= amount),
    appointment_id text UNIQUE NOT NULL,
    status text NOT NULL CHECK (status IN ('PENDING','CANCELLED','COMPLETED'))
);
CREATE INDEX bookings_user_active ON bookings(user_id,starts_at) WHERE status <> 'CANCELLED';
CREATE TABLE point_entries (
    booking_id text NOT NULL REFERENCES bookings(id),
    user_id bigint NOT NULL REFERENCES users(id),
    kind text NOT NULL CHECK (kind IN ('DEBIT','CREDIT')),
    amount integer NOT NULL CHECK (amount > 0),
    PRIMARY KEY (booking_id,kind)
);
CREATE TABLE payments (
    id text PRIMARY KEY,
    booking_id text UNIQUE NOT NULL REFERENCES bookings(id),
    amount integer NOT NULL CHECK (amount > 0),
    status text NOT NULL CHECK (status IN ('CAPTURED','REFUNDED'))
);
