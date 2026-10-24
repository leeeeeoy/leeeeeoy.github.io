package booking

import (
	"context"

	"github.com/jackc/pgx/v5"
)

func (s *store) insertBooking(ctx context.Context, tx pgx.Tx, b Booking) error {
	_, err := tx.Exec(ctx, `INSERT INTO bookings(id,user_id,resource_id,starts_at,ends_at,amount,points,appointment_id,status) VALUES($1,$2,$3,$4,$5,$6,$7,$8,'PENDING')`, b.ID, b.UserID, b.ResourceID, b.Start, b.End, b.Amount, b.Points, b.AppointmentID)
	return err
}

func (s *store) bookingUserID(ctx context.Context, tx pgx.Tx, id string) (int64, error) {
	var userID int64
	err := tx.QueryRow(ctx, `SELECT user_id FROM bookings WHERE id=$1`, id).Scan(&userID)
	return userID, err
}

func (s *store) lockBooking(ctx context.Context, tx pgx.Tx, id string) (Booking, error) {
	var b Booking
	err := tx.QueryRow(ctx, `SELECT id,user_id,appointment_id,points,status FROM bookings WHERE id=$1 FOR UPDATE`, id).Scan(&b.ID, &b.UserID, &b.AppointmentID, &b.Points, &b.Status)
	return b, err
}

func (s *store) markCancelled(ctx context.Context, tx pgx.Tx, id string) error {
	_, err := tx.Exec(ctx, `UPDATE bookings SET status='CANCELLED' WHERE id=$1`, id)
	return err
}

func (s *store) userOccupied(ctx context.Context, tx pgx.Tx, b Booking) (bool, error) {
	var occupied bool
	err := tx.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM bookings WHERE user_id=$1 AND status<>'CANCELLED' AND starts_at<$3 AND $2<ends_at)`, b.UserID, b.Start, b.End).Scan(&occupied)
	return occupied, err
}

func (s *store) bookingForAppointment(ctx context.Context, id string) (string, error) {
	var booking string
	err := s.db.QueryRow(ctx, `SELECT id FROM bookings WHERE appointment_id=$1`, id).Scan(&booking)
	return booking, err
}

func (s *store) reschedule(ctx context.Context, tx pgx.Tx, id string, v Interval) error {
	_, err := tx.Exec(ctx, `UPDATE bookings SET starts_at=$2,ends_at=$3 WHERE id=$1`, id, v.Start, v.End)
	return err
}

func (s *store) complete(ctx context.Context, tx pgx.Tx, id string) error {
	_, err := tx.Exec(ctx, `UPDATE bookings SET status='COMPLETED' WHERE id=$1`, id)
	return err
}

func (s *store) get(ctx context.Context, id string) (Booking, error) {
	var b Booking
	err := s.db.QueryRow(ctx, `SELECT b.id,b.user_id,b.resource_id,b.starts_at,b.ends_at,b.amount,b.points,b.appointment_id,b.status,COALESCE(p.id,'') FROM bookings b LEFT JOIN payments p ON p.booking_id=b.id WHERE b.id=$1`, id).Scan(&b.ID, &b.UserID, &b.ResourceID, &b.Start, &b.End, &b.Amount, &b.Points, &b.AppointmentID, &b.Status, &b.PaymentID)
	return b, err
}
