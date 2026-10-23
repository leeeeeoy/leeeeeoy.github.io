//go:build integration

package integrity

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

func TestP0(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	pool, err := Open(ctx, os.Getenv("LAB_DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	var connections []*pgxpool.Conn
	for range 3 {
		conn, err := pool.Acquire(ctx)
		if err != nil {
			t.Fatal(err)
		}
		defer conn.Release()
		connections = append(connections, conn)
	}
	pids := map[uint32]bool{}
	for _, conn := range connections {
		pids[conn.Conn().PgConn().PID()] = true
		var isolation, statementTimeout string
		if err := conn.QueryRow(ctx, `SELECT current_setting('transaction_isolation'), current_setting('statement_timeout')`).Scan(&isolation, &statementTimeout); err != nil {
			t.Fatal(err)
		}
		if isolation != "read committed" || statementTimeout != "5s" {
			t.Fatalf("isolation=%s statement_timeout=%s", isolation, statementTimeout)
		}
	}
	if len(pids) != 3 {
		t.Fatal("participants and observer must have distinct DB sessions")
	}
	t.Logf("distinct_sessions=%d pool_max=%d isolation=read_committed", len(pids), pool.Config().MaxConns)

	var nonce [8]byte
	if _, err := rand.Read(nonce[:]); err != nil {
		t.Fatal(err)
	}
	resources := []string{"R1_" + hex.EncodeToString(nonce[:]), "R2_" + hex.EncodeToString(nonce[:])}
	writer, observer := connections[0], connections[2]
	if _, err := writer.Exec(ctx, `INSERT INTO resources(id) SELECT unnest($1::text[])`, resources); err != nil {
		t.Fatal(err)
	}
	// Cleanup is scoped to this attempt's generated synthetic resource IDs.
	defer func() {
		cleanup, stop := context.WithTimeout(context.Background(), 5*time.Second)
		defer stop()
		if _, err := writer.Exec(cleanup, `DELETE FROM slots WHERE resource_id = ANY($1)`, resources); err != nil {
			t.Error(err)
		}
		if _, err := writer.Exec(cleanup, `DELETE FROM resources WHERE id = ANY($1)`, resources); err != nil {
			t.Error(err)
		}
		var remaining int
		if err := observer.QueryRow(cleanup, `SELECT count(*) FROM resources WHERE id = ANY($1)`, resources).Scan(&remaining); err != nil || remaining != 0 {
			t.Errorf("cleanup remaining=%d error=%v", remaining, err)
		}
	}()

	base := time.Date(2030, 1, 1, 13, 0, 0, 0, time.UTC)
	expectedRows := 0
	for _, tc := range []struct {
		name       string
		resource   int
		start, end int
		active     bool
		conflicts  int64
		invalid    bool
	}{
		{"first", 0, 0, 30, true, 0, false},
		{"adjacent", 0, 30, 60, true, 0, false},
		{"other_resource", 1, 0, 30, true, 0, false},
		{"inactive_overlap", 0, 0, 30, false, 0, false},
		{"zero_length", 0, 10, 10, true, 0, true},
		{"reversed", 0, 20, 10, true, 0, true},
		{"partial_overlap", 0, 15, 45, true, 2, false},
		{"identical_overlap", 0, 0, 30, true, 4, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			caseCtx, stop := context.WithTimeout(ctx, 5*time.Second)
			defer stop()
			_, err := writer.Exec(caseCtx, `INSERT INTO slots(resource_id, starts_at, ends_at, active) VALUES ($1,$2,$3,$4)`,
				resources[tc.resource], base.Add(time.Duration(tc.start)*time.Minute), base.Add(time.Duration(tc.end)*time.Minute), tc.active)
			if tc.invalid {
				var pgErr *pgconn.PgError
				if !errors.As(err, &pgErr) || pgErr.Code != "23514" {
					t.Fatalf("expected check violation, got %v", err)
				}
			} else if err != nil {
				t.Fatal(err)
			}
			if !tc.invalid {
				expectedRows++
			}
			state, err := Inspect(caseCtx, observer.Conn(), resources)
			if err != nil || state.ConflictPairs != tc.conflicts || len(state.Slots) != expectedRows {
				t.Fatalf("rows=%d want=%d conflicts=%d want=%d error=%v", len(state.Slots), expectedRows, state.ConflictPairs, tc.conflicts, err)
			}
			data, err := json.Marshal(state)
			if err != nil {
				t.Fatal(err)
			}
			t.Logf("final_state=%s", data)
		})
	}
	t.Run("reject_identity_mismatch", func(t *testing.T) {
		if _, err := writer.Exec(ctx, `UPDATE lab_identity SET token = 'intentional-mismatch'`); err != nil {
			t.Fatal(err)
		}
		defer func() {
			cleanup, stop := context.WithTimeout(context.Background(), 5*time.Second)
			defer stop()
			if _, err := writer.Exec(cleanup, `UPDATE lab_identity SET token = 'concurrency-integrity-p0-v1'`); err != nil {
				t.Error(err)
			}
		}()
		unexpected, err := Open(ctx, os.Getenv("LAB_DATABASE_URL"))
		if unexpected != nil {
			unexpected.Close()
		}
		if err == nil {
			t.Fatal("unverified database identity accepted")
		}
	})
	var idleTransactions int
	if err := observer.QueryRow(ctx, `SELECT count(*) FROM pg_stat_activity
		WHERE application_name = 'concurrency-integrity-p0-test' AND state LIKE 'idle in transaction%'`).Scan(&idleTransactions); err != nil || idleTransactions != 0 {
		t.Fatalf("idle_transactions=%d error=%v", idleTransactions, err)
	}
	t.Log("idle_transactions=0; final state observations used independent session")
}
