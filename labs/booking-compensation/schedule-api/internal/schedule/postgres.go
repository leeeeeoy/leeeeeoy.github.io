package schedule

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type store struct{ db *pgxpool.Pool }

func (s *store) ready(ctx context.Context) error { return s.db.Ping(ctx) }

func (s *store) begin(ctx context.Context) (pgx.Tx, error) { return s.db.Begin(ctx) }

func (s *store) beginCreate(ctx context.Context) (pgx.Tx, error) {
	return s.db.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.ReadCommitted})
}

func rollback(tx pgx.Tx) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	_ = tx.Rollback(ctx)
}

func databaseError(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return Fail(NotFound, "not_found")
	}
	return Fail(Unavailable, "database_operation_failed")
}
