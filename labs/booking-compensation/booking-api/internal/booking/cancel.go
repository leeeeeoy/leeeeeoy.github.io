package booking

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
)

func (s *Service) Cancel(ctx context.Context, id string) (ChangeResult, error) {
	return s.cancel(ctx, id, true)
}

func (s *Service) cancel(ctx context.Context, id string, sendToSchedule bool) (ChangeResult, error) {
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
	if sendToSchedule {
		if err = s.scheduler.Cancel(ctx, b.AppointmentID); err != nil {
			s.notify(id, "schedule_cancel_failed")
			f := Fail(Upstream, "schedule_cancel_failed")
			f.RemoteOutcome = "unknown"
			return ChangeResult{}, f
		}
	}
	if err = s.cancelAndRefund(ctx, tx, b); err != nil {
		restored := false
		if sendToSchedule {
			cleanup, cancel := context.WithTimeout(context.Background(), 3*time.Second)
			restored = s.scheduler.Restore(cleanup, b.AppointmentID) == nil
			cancel()
		}
		s.notify(id, "booking_cancel_failed")
		f := Fail(Upstream, "local_cancel_failed")
		f.ScheduleRestored = &restored
		return ChangeResult{}, f
	}
	if err = tx.Commit(ctx); err != nil {
		s.notify(id, "cancel_commit_failed")
		return ChangeResult{}, Fail(Internal, "cancel_commit_failed")
	}
	s.notify(id, "booking_cancelled")
	return ChangeResult{Status: "CANCELLED"}, nil
}

func (s *Service) cancelAndRefund(ctx context.Context, tx pgx.Tx, b Booking) error {
	if err := s.store.markCancelled(ctx, tx, b.ID); err != nil {
		return err
	}
	if b.Points > 0 {
		if err := s.store.creditPoints(ctx, tx, b.ID, b.UserID, b.Points); err != nil {
			return err
		}
	}
	id, err := s.store.paymentID(ctx, tx, b.ID)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil
	}
	if err != nil {
		return err
	}
	if err = s.payments.Refund(ctx, id); err != nil {
		return err
	}
	// An external refund survives a later rollback in this local transaction.
	return s.store.markRefunded(ctx, tx, id)
}
