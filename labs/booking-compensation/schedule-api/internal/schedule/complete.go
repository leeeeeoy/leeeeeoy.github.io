package schedule

import (
	"context"
)

func (s *Service) Complete(ctx context.Context, id string) (Appointment, error) {
	tx, err := s.store.begin(ctx)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	defer rollback(tx)
	v, _, err := s.store.lockAppointment(ctx, tx, id)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	if v.Status == "COMPLETED" {
		return v, nil
	}
	if v.Status != "PENDING" {
		return Appointment{}, Fail(Conflict, "not_pending")
	}
	if err = s.store.markCompleted(ctx, tx, id); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.adjustCompletedCount(ctx, tx, v.ResourceID, 1); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.recordEvent(ctx, tx, id, "COMPLETE"); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return Appointment{}, databaseError(err)
	}
	v.Status = "COMPLETED"
	s.dispatchCallback(v, "complete")
	return v, nil
}
