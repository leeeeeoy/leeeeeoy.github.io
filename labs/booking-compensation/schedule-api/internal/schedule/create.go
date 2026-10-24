package schedule

import (
	"context"
	"crypto/rand"
	"encoding/hex"
)

func (s *Service) Create(ctx context.Context, v Appointment) (Appointment, error) {
	if !v.Valid() {
		return Appointment{}, Fail(Invalid, "invalid_appointment")
	}
	tx, err := s.store.beginCreate(ctx)
	if err != nil {
		return Appointment{}, databaseError(err)
	}
	defer rollback(tx)
	if err = s.store.lockResourceDays(ctx, tx, v); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.checkAvailability(ctx, tx, v); err != nil {
		return Appointment{}, err
	}
	var id [12]byte
	if _, err = rand.Read(id[:]); err != nil {
		return Appointment{}, databaseError(err)
	}
	v.ID = hex.EncodeToString(id[:])
	v.Status = "PENDING"
	if err = s.store.insertAppointment(ctx, tx, v); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = s.store.recordEvent(ctx, tx, v.ID, "CREATE"); err != nil {
		return Appointment{}, databaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return Appointment{}, databaseError(err)
	}
	return v, nil
}
