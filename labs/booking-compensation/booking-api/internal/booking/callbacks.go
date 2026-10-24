package booking

import "context"

func (s *Service) CancelFromSchedule(ctx context.Context, appointment string) (ChangeResult, error) {
	id, err := s.store.bookingForAppointment(ctx, appointment)
	if err != nil {
		return ChangeResult{}, databaseError(err)
	}
	return s.cancel(ctx, id, false)
}

func (s *Service) RescheduleFromSchedule(ctx context.Context, id string, v Interval) (ChangeResult, error) {
	if !ValidInterval(v.Start, v.End) {
		return ChangeResult{}, Fail(Invalid, "invalid_interval")
	}
	return s.applyChange(ctx, id, &v)
}

func (s *Service) CompleteFromSchedule(ctx context.Context, id string) (ChangeResult, error) {
	return s.applyChange(ctx, id, nil)
}

func (s *Service) applyChange(ctx context.Context, appointment string, interval *Interval) (ChangeResult, error) {
	id, err := s.store.bookingForAppointment(ctx, appointment)
	if err != nil {
		return ChangeResult{}, databaseError(err)
	}
	tx, err := s.store.begin(ctx)
	if err != nil {
		return ChangeResult{}, databaseError(err)
	}
	defer rollback(tx)
	userID, err := s.store.bookingUserID(ctx, tx, id)
	if err != nil {
		return ChangeResult{}, databaseError(err)
	}
	// Match creation's user-before-booking lock order, then re-read the booking.
	if _, err = s.store.lockUser(ctx, tx, userID); err != nil {
		return ChangeResult{}, databaseError(err)
	}
	b, err := s.store.lockBooking(ctx, tx, id)
	if err != nil {
		return ChangeResult{}, databaseError(err)
	}
	if b.Status == "CANCELLED" {
		return ChangeResult{Status: "CANCELLED"}, nil
	}
	if interval != nil {
		if b.Status != "PENDING" {
			return ChangeResult{}, Fail(Conflict, "not_pending")
		}
		err = s.store.reschedule(ctx, tx, id, *interval)
	} else {
		err = s.store.complete(ctx, tx, id)
	}
	if err != nil {
		return ChangeResult{}, databaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return ChangeResult{}, databaseError(err)
	}
	return ChangeResult{Updated: true}, nil
}
