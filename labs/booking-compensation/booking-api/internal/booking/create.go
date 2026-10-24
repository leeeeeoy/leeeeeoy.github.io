package booking

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
)

func (s *Service) Create(ctx context.Context, b Booking) (Booking, error) {
	if err := b.Validate(); err != nil {
		return Booking{}, err
	}
	tx, err := s.store.beginCreate(ctx)
	if err != nil {
		return Booking{}, Fail(Unavailable, "database_unavailable")
	}
	defer rollback(tx)
	balance, err := s.store.lockUser(ctx, tx, b.UserID)
	if err != nil {
		return Booking{}, databaseError(err)
	}
	occupied, err := s.store.userOccupied(ctx, tx, b)
	if err != nil {
		return Booking{}, databaseError(err)
	}
	if occupied {
		return Booking{}, Fail(Conflict, "user_slot_occupied")
	}
	b.AppointmentID, err = s.scheduler.Create(ctx, b)
	if err != nil {
		if !isConflict(err) {
			event := "schedule_create_failed"
			var f *Error
			if errors.As(err, &f) {
				event = f.Code
			}
			s.notify(b.ID, event)
		}
		return Booking{}, err
	}
	b.Status = "PENDING"
	if err = s.saveAndVerifyPayment(ctx, tx, b, balance); err != nil {
		cleanup, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		compensated := s.scheduler.Compensate(cleanup, b.AppointmentID) == nil
		s.notify(b.ID, "booking_failed")
		var failure *Error
		if !errors.As(err, &failure) {
			failure = Fail(Internal, "local_save_failed")
		}
		failure.ScheduleCompensated = &compensated
		return Booking{}, failure
	}
	// Keep the baseline commit-time gap; this refactor does not add recovery policy.
	if err = tx.Commit(ctx); err != nil {
		s.notify(b.ID, "booking_commit_failed")
		f := Fail(Internal, "commit_failed")
		f.RemoteOutcome = "unknown"
		return Booking{}, f
	}
	s.notify(b.ID, "booking_created")
	return b, nil
}

func (s *Service) saveAndVerifyPayment(ctx context.Context, tx pgx.Tx, b Booking, balance int) error {
	// Preserve late funds validation and the original external-call/SQL order.
	if balance < b.Points {
		return Fail(Invalid, "insufficient_points")
	}
	if err := s.store.insertBooking(ctx, tx, b); err != nil {
		return Fail(Internal, "local_save_failed")
	}
	if b.Points > 0 {
		if err := s.store.debitPoints(ctx, tx, b.ID, b.UserID, b.Points); err != nil {
			return Fail(Internal, "local_save_failed")
		}
	}
	if b.Amount == b.Points {
		return nil
	}
	if err := s.payments.Verify(ctx, b.PaymentID, b.Amount-b.Points); err != nil {
		return err
	}
	if err := s.store.insertPayment(ctx, tx, b); err != nil {
		return Fail(Internal, "payment_save_failed")
	}
	return nil
}
