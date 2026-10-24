package booking

import (
	"context"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Service struct {
	store     *store
	scheduler scheduler
	payments  payments
	notifier  notifier
}

// NewService uses db without taking ownership of its lifetime.
func NewService(db *pgxpool.Pool, scheduler scheduler, payments payments, notifier notifier) *Service {
	return &Service{store: &store{db: db}, scheduler: scheduler, payments: payments, notifier: notifier}
}

func (s *Service) Ready(ctx context.Context) error { return s.store.ready(ctx) }

func (s *Service) Get(ctx context.Context, id string) (Booking, error) {
	b, err := s.store.get(ctx, id)
	if err != nil {
		return b, databaseError(err)
	}
	return b, nil
}

func (s *Service) User(ctx context.Context, id string) (User, error) {
	u, err := s.store.user(ctx, id)
	if err != nil {
		return u, databaseError(err)
	}
	return u, nil
}

func (s *Service) notify(id, event string) {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err := s.notifier.Send(ctx, id, event); err != nil {
		slog.Warn("notification_failed", "booking", id, "event", event, "error", err)
	}
}
