package schedule

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
)

func (s *store) lockResourceDays(ctx context.Context, tx pgx.Tx, v Appointment) error {
	first := v.Start.UTC().Truncate(24 * time.Hour)
	last := v.End.Add(-time.Nanosecond).UTC().Truncate(24 * time.Hour)
	for day := first; !day.After(last); day = day.Add(24 * time.Hour) {
		if _, err := tx.Exec(ctx, `SELECT pg_advisory_xact_lock($1,$2)`, v.ResourceID, int32(day.Unix()/86400)); err != nil {
			return err
		}
	}
	return nil
}

func (s *store) adjustCompletedCount(ctx context.Context, tx pgx.Tx, resource int32, delta int) error {
	_, err := tx.Exec(ctx, `UPDATE resources SET completed_count=completed_count+$2 WHERE id=$1`, resource, delta)
	return err
}
