package booking

import "context"

// Interfaces describe only the external operations this workflow consumes.
type scheduler interface {
	Create(context.Context, Booking) (string, error)
	Cancel(context.Context, string) error
	Compensate(context.Context, string) error
	Restore(context.Context, string) error
}
type payments interface {
	Verify(context.Context, string, int) error
	Refund(context.Context, string) error
}
type notifier interface {
	Send(context.Context, string, string) error
}
