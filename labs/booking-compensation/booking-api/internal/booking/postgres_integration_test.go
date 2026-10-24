package booking

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestPostgresTransactionBoundaries(t *testing.T) {
	raw := os.Getenv("BOOKING_TEST_DATABASE_URL")
	if raw == "" {
		t.Skip("set BOOKING_TEST_DATABASE_URL to the local lab DB to run storage integration tests")
	}
	cfg, err := pgxpool.ParseConfig(raw)
	if err != nil {
		t.Fatal("invalid local integration test URL")
	}
	c := cfg.ConnConfig
	if c.Host != "127.0.0.1" || c.Port != 15490 || c.Database != "bookings" || c.User != "lab" {
		t.Fatal("storage tests require the dedicated loopback booking lab DB")
	}
	var nonce [8]byte
	if _, err := rand.Read(nonce[:]); err != nil {
		t.Fatal(err)
	}
	schema := "booking_storage_" + hex.EncodeToString(nonce[:])
	t.Logf("isolated schema: %s", schema)
	cfg.MaxConns = 4
	c.RuntimeParams["search_path"] = schema
	c.RuntimeParams["application_name"] = "booking-storage-test"
	c.RuntimeParams["statement_timeout"] = "3000"
	c.RuntimeParams["lock_timeout"] = "1000"
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	db, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(db.Close)
	if _, err := db.Exec(ctx, "CREATE SCHEMA "+pgx.Identifier{schema}.Sanitize()); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		cleanup, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if _, err := db.Exec(cleanup, "DROP SCHEMA "+pgx.Identifier{schema}.Sanitize()+" CASCADE"); err != nil {
			t.Error(err)
		}
	})
	ddl, err := os.ReadFile("../../db/schema.sql")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(ctx, string(ddl)); err != nil {
		t.Fatal(err)
	}

	input := func(t *testing.T, id string, userID int64, points int) Booking {
		t.Helper()
		if _, err := db.Exec(ctx, "INSERT INTO users VALUES ($1,100)", userID); err != nil {
			t.Fatal(err)
		}
		start := time.Date(2030, 1, 1, 12, 0, 0, 0, time.UTC)
		return Booking{ID: id, UserID: userID, ResourceID: 1, Start: start, End: start.Add(time.Hour), Amount: 100, Points: points, PaymentID: "payment-" + id}
	}
	type state struct {
		booking, payment        string
		points, debits, credits int
	}
	assertState := func(t *testing.T, b Booking, want state) {
		t.Helper()
		var got state
		err := db.QueryRow(ctx, `SELECT
            COALESCE((SELECT status FROM bookings WHERE id=$1),''),
            COALESCE((SELECT status FROM payments WHERE booking_id=$1),''),
            (SELECT points FROM users WHERE id=$2),
            (SELECT count(*) FROM point_entries WHERE booking_id=$1 AND kind='DEBIT'),
            (SELECT count(*) FROM point_entries WHERE booking_id=$1 AND kind='CREDIT')`, b.ID, b.UserID).
			Scan(&got.booking, &got.payment, &got.points, &got.debits, &got.credits)
		if err != nil || got != want {
			t.Fatalf("local state: got %+v, want %+v, error %v", got, want, err)
		}
	}

	t.Run("debit ledger failure rolls back booking and balance", func(t *testing.T) {
		b := input(t, "create-ledger-failure", 1, 40)
		if _, err := db.Exec(ctx, `ALTER TABLE point_entries ADD CHECK (booking_id <> 'create-ledger-failure')`); err != nil {
			t.Fatal(err)
		}
		calls := &storageCalls{}
		_, err := NewService(db, calls, calls, calls).Create(ctx, b)
		var failure *Error
		if !errors.As(err, &failure) || failure.Code != "local_save_failed" || calls.compensations != 1 {
			t.Fatalf("create failure: %v, compensation calls %d", err, calls.compensations)
		}
		assertState(t, b, state{points: 100})
	})
	t.Run("credit ledger failure rolls back cancellation and balance", func(t *testing.T) {
		b := input(t, "cancel-ledger-failure", 2, 40)
		calls := &storageCalls{verify: func() {
			// An independent connection must not see any partial writes before commit.
			assertState(t, b, state{points: 100})
		}}
		service := NewService(db, calls, calls, calls)
		if _, err := service.Create(ctx, b); err != nil {
			t.Fatal(err)
		}
		assertState(t, b, state{booking: "PENDING", payment: "CAPTURED", points: 60, debits: 1})
		if _, err := db.Exec(ctx, `ALTER TABLE point_entries ADD CHECK (booking_id <> 'cancel-ledger-failure' OR kind <> 'CREDIT')`); err != nil {
			t.Fatal(err)
		}
		_, err := service.Cancel(ctx, b.ID)
		var failure *Error
		if !errors.As(err, &failure) || failure.Code != "local_cancel_failed" || calls.restores != 1 || calls.refunds != 0 {
			t.Fatalf("cancel failure: %v, restore/refund calls %d/%d", err, calls.restores, calls.refunds)
		}
		assertState(t, b, state{booking: "PENDING", payment: "CAPTURED", points: 60, debits: 1})
	})
	t.Run("zero points never creates point ledger entries", func(t *testing.T) {
		b := input(t, "zero-points", 3, 0)
		calls := &storageCalls{}
		service := NewService(db, calls, calls, calls)
		if _, err := service.Create(ctx, b); err != nil {
			t.Fatal(err)
		}
		assertState(t, b, state{booking: "PENDING", payment: "CAPTURED", points: 100})
		for range 2 {
			if _, err := service.Cancel(ctx, b.ID); err != nil {
				t.Fatal(err)
			}
		}
		assertState(t, b, state{booking: "CANCELLED", payment: "REFUNDED", points: 100})
		if calls.refunds != 1 {
			t.Fatalf("refund called %d times", calls.refunds)
		}
	})
}

// Only external effects are faked; SQL and Service transaction handling are real.
type storageCalls struct {
	compensations, restores, refunds int
	verify                           func()
}

func (c *storageCalls) Create(_ context.Context, b Booking) (string, error) {
	return "appointment-" + b.ID, nil
}
func (c *storageCalls) Cancel(context.Context, string) error { return nil }
func (c *storageCalls) Compensate(context.Context, string) error {
	c.compensations++
	return nil
}
func (c *storageCalls) Restore(context.Context, string) error {
	c.restores++
	return nil
}
func (c *storageCalls) Verify(context.Context, string, int) error {
	if c.verify != nil {
		c.verify()
	}
	return nil
}
func (c *storageCalls) Refund(context.Context, string) error {
	c.refunds++
	return nil
}
func (c *storageCalls) Send(context.Context, string, string) error { return nil }
