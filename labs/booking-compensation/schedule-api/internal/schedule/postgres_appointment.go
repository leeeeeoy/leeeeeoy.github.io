package schedule

import (
	"context"

	"github.com/jackc/pgx/v5"
)

func (s *store) checkAvailability(ctx context.Context, tx pgx.Tx, v Appointment) error {
	var occupied bool
	err := tx.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM appointments WHERE id<>$1 AND resource_id=$2 AND status<>'CANCELLED' AND starts_at<$4 AND $3<ends_at)`, v.ID, v.ResourceID, v.Start, v.End).Scan(&occupied)
	if err != nil {
		return databaseError(err)
	}
	if occupied {
		return Fail(Conflict, "slot_occupied")
	}
	return nil
}

func (s *store) insertAppointment(ctx context.Context, tx pgx.Tx, v Appointment) error {
	_, err := tx.Exec(ctx, `INSERT INTO appointments(id,resource_id,booking_id,starts_at,ends_at,status) VALUES($1,$2,NULLIF($3,''),$4,$5,'PENDING')`, v.ID, v.ResourceID, v.BookingID, v.Start, v.End)
	return err
}

func (s *store) recordEvent(ctx context.Context, tx pgx.Tx, id, kind string) error {
	_, err := tx.Exec(ctx, `INSERT INTO appointment_events(appointment_id,kind) VALUES($1,$2)`, id, kind)
	return err
}

func (s *store) lockAppointment(ctx context.Context, tx pgx.Tx, id string) (Appointment, string, error) {
	var v Appointment
	var from string
	err := tx.QueryRow(ctx, `SELECT id,resource_id,COALESCE(booking_id,''),starts_at,ends_at,status,COALESCE(cancelled_from,'') FROM appointments WHERE id=$1 FOR UPDATE`, id).Scan(&v.ID, &v.ResourceID, &v.BookingID, &v.Start, &v.End, &v.Status, &from)
	return v, from, err
}

func (s *store) markCancelled(ctx context.Context, tx pgx.Tx, id string) error {
	_, err := tx.Exec(ctx, `UPDATE appointments SET cancelled_from=status,status='CANCELLED' WHERE id=$1`, id)
	return err
}

func (s *store) restoreStatus(ctx context.Context, tx pgx.Tx, id string) error {
	_, err := tx.Exec(ctx, `UPDATE appointments SET status=cancelled_from,cancelled_from=NULL WHERE id=$1`, id)
	return err
}

func (s *store) markCompleted(ctx context.Context, tx pgx.Tx, id string) error {
	_, err := tx.Exec(ctx, `UPDATE appointments SET status='COMPLETED' WHERE id=$1`, id)
	return err
}

func (s *store) updateInterval(ctx context.Context, tx pgx.Tx, v Appointment) error {
	_, err := tx.Exec(ctx, `UPDATE appointments SET starts_at=$2,ends_at=$3 WHERE id=$1`, v.ID, v.Start, v.End)
	return err
}

func (s *store) get(ctx context.Context, id string) (Appointment, error) {
	var v Appointment
	err := s.db.QueryRow(ctx, `SELECT id,resource_id,COALESCE(booking_id,''),starts_at,ends_at,status FROM appointments WHERE id=$1`, id).Scan(&v.ID, &v.ResourceID, &v.BookingID, &v.Start, &v.End, &v.Status)
	return v, err
}
