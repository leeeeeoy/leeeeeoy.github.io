package schedule

import (
	"context"
)

func (s *Service) Cancel(ctx context.Context, id string, publish bool) (Appointment, error) {
	tx, err := s.store.begin(ctx)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	defer rollback(tx)
	v, _, err := s.store.lockAppointment(ctx, tx, id)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	if v.Status == "CANCELLED" {
		return v, nil
	}
	if v.Status == "COMPLETED" {
		if err = s.store.adjustCompletedCount(ctx, tx, v.ResourceID, -1); err != nil {
			return Appointment{}, databaseError(err)
		}
	}
	if err = s.store.markCancelled(ctx, tx, id); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.recordEvent(ctx, tx, id, "CANCEL"); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return Appointment{}, databaseError(err)
	}
	v.Status = "CANCELLED"
	if publish {
		s.dispatchCallback(v, "cancel")
	}
	return v, nil
}

func (s *Service) Restore(ctx context.Context, id string) (Appointment, error) {
	tx, err := s.store.begin(ctx)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	defer rollback(tx)
	v, from, err := s.store.lockAppointment(ctx, tx, id)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	if v.Status != "CANCELLED" {
		return v, nil
	}
	if err = s.store.lockResourceDays(ctx, tx, v); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.checkAvailability(ctx, tx, v); err != nil {
		return Appointment{}, err
	}
	if from == "COMPLETED" {
		if err = s.store.adjustCompletedCount(ctx, tx, v.ResourceID, 1); err != nil {
			return Appointment{}, databaseError(err)
		}
	}
	if err = s.store.restoreStatus(ctx, tx, id); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.recordEvent(ctx, tx, id, "RESTORE"); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return Appointment{}, databaseError(err)
	}
	v.Status = from
	return v, nil
}
