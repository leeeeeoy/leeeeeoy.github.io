package booking

import (
	"errors"
)

type Kind string

const (
	Invalid        Kind = "invalid"
	Conflict       Kind = "conflict"
	NotFound       Kind = "not_found"
	Unavailable    Kind = "unavailable"
	Upstream       Kind = "upstream"
	Internal       Kind = "internal"
	PaymentInvalid Kind = "payment_invalid"
)

type Error struct {
	Kind                Kind
	Code                string
	RemoteOutcome       string
	ScheduleCompensated *bool
	ScheduleRestored    *bool
}

func (e *Error) Error() string           { return e.Code }
func Fail(kind Kind, code string) *Error { return &Error{Kind: kind, Code: code} }

func isConflict(err error) bool { var f *Error; return errors.As(err, &f) && f.Kind == Conflict }
