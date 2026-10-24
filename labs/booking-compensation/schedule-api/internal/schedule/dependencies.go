package schedule

import "context"

type callbacks interface {
	Send(context.Context, string, string, Interval) error
}
type notifier interface {
	Send(context.Context, string, string) error
}
