package schedule

import (
	"context"
)

func (s *Service) Reschedule(ctx context.Context, id string, interval Interval) (Appointment, error) {
	if !ValidInterval(interval.Start, interval.End) {
		return Appointment{}, Fail(Invalid, "invalid_interval")
	}
	tx, err := s.store.begin(ctx)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	defer rollback(tx)
	v, _, err := s.store.lockAppointment(ctx, tx, id)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	if v.Status != "PENDING" {
		return Appointment{}, Fail(Conflict, "not_pending")
	}
	v.Start, v.End = interval.Start, interval.End
	if err = s.store.lockResourceDays(ctx, tx, v); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.checkAvailability(ctx, tx, v); err != nil {
		return Appointment{}, err
	}
	if err = s.store.updateInterval(ctx, tx, v); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.recordEvent(ctx, tx, id, "RESCHEDULE"); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return Appointment{}, databaseError(err)
	}
	s.dispatchCallback(v, "reschedule")
	return v, nil
}
