package booking

import (
	"context"

	"github.com/jackc/pgx/v5"
)

func (s *store) insertPayment(ctx context.Context, tx pgx.Tx, b Booking) error {
	_, err := tx.Exec(ctx, `INSERT INTO payments VALUES($1,$2,$3,'CAPTURED')`, b.PaymentID, b.ID, b.Amount-b.Points)
	return err
}

func (s *store) paymentID(ctx context.Context, tx pgx.Tx, id string) (string, error) {
	var payment string
	err := tx.QueryRow(ctx, `SELECT id FROM payments WHERE booking_id=$1`, id).Scan(&payment)
	return payment, err
}

func (s *store) markRefunded(ctx context.Context, tx pgx.Tx, id string) error {
	_, err := tx.Exec(ctx, `UPDATE payments SET status='REFUNDED' WHERE id=$1`, id)
	return err
}
