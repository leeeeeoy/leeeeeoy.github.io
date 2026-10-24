package schedule

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Service struct {
	store     *store
	callbacks callbacks
	notifier  notifier
}

// NewService uses db without taking ownership of its lifetime.
func NewService(db *pgxpool.Pool, callbacks callbacks, notifier notifier) *Service {
	return &Service{store: &store{db: db}, callbacks: callbacks, notifier: notifier}
}

func (s *Service) Ready(ctx context.Context) error { return s.store.ready(ctx) }

func (s *Service) Get(ctx context.Context, id string) (Appointment, error) {
	v, err := s.store.get(ctx, id)
	if err != nil {
		return v, databaseError(err)
	}
	return v, nil
}
