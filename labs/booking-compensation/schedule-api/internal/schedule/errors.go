package schedule

type Kind string

const (
	Invalid     Kind = "invalid"
	Conflict    Kind = "conflict"
	NotFound    Kind = "not_found"
	Unavailable Kind = "unavailable"
)

type Error struct {
	Kind Kind
	Code string
}

func (e *Error) Error() string           { return e.Code }
func Fail(kind Kind, code string) *Error { return &Error{Kind: kind, Code: code} }
