package schedule

import (
	"context"
	"log/slog"
	"time"
)

func (s *Service) dispatchCallback(v Appointment, action string) {
	if v.BookingID == "" {
		return
	}
	// shortcut: best effort only; moving packages does not add durable delivery.
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := s.callbacks.Send(ctx, v.ID, action, Interval{Start: v.Start, End: v.End}); err != nil {
			slog.Warn("callback_failed", "appointment", v.ID, "action", action, "error", err)
			_ = s.notifier.Send(ctx, v.ID, "callback_failed")
		}
	}()
}
