package booking

import (
	"context"

	"github.com/jackc/pgx/v5"
)

func (s *store) lockUser(ctx context.Context, tx pgx.Tx, id int64) (int, error) {
	var balance int
	err := tx.QueryRow(ctx, `SELECT points FROM users WHERE id=$1 FOR UPDATE`, id).Scan(&balance)
	return balance, err
}

func (s *store) debitPoints(ctx context.Context, tx pgx.Tx, bookingID string, userID int64, amount int) error {
	if _, err := tx.Exec(ctx, `UPDATE users SET points=points-$2 WHERE id=$1`, userID, amount); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, `INSERT INTO point_entries VALUES($1,$2,'DEBIT',$3)`, bookingID, userID, amount)
	return err
}

func (s *store) creditPoints(ctx context.Context, tx pgx.Tx, bookingID string, userID int64, amount int) error {
	if _, err := tx.Exec(ctx, `UPDATE users SET points=points+$2 WHERE id=$1`, userID, amount); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, `INSERT INTO point_entries VALUES($1,$2,'CREDIT',$3)`, bookingID, userID, amount)
	return err
}

func (s *store) user(ctx context.Context, id string) (User, error) {
	var u User
	err := s.db.QueryRow(ctx, `SELECT id,points FROM users WHERE id=$1`, id).Scan(&u.ID, &u.Points)
	return u, err
}
