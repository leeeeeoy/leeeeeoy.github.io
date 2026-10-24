package booking

import (
	"regexp"
	"time"
)

var identifier = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,48}$`)

func ValidID(id string) bool { return identifier.MatchString(id) }

type Booking struct {
	ID            string    `json:"id"`
	UserID        int64     `json:"user_id"`
	ResourceID    int32     `json:"resource_id"`
	Start         time.Time `json:"start"`
	End           time.Time `json:"end"`
	Amount        int       `json:"amount"`
	Points        int       `json:"points"`
	PaymentID     string    `json:"payment_id,omitempty"`
	AppointmentID string    `json:"appointment_id,omitempty"`
	Status        string    `json:"status,omitempty"`
}

func (b Booking) Validate() error {
	if !ValidID(b.ID) || b.UserID <= 0 || b.ResourceID <= 0 || !ValidInterval(b.Start, b.End) || b.Amount <= 0 || b.Amount > 1000000 || b.Points < 0 || b.Points > b.Amount {
		return Fail(Invalid, "invalid_booking")
	}
	if (b.Amount > b.Points && !ValidID(b.PaymentID)) || (b.PaymentID != "" && !ValidID(b.PaymentID)) || b.AppointmentID != "" || b.Status != "" {
		return Fail(Invalid, "invalid_payment_or_server_fields")
	}
	return nil
}
func ValidInterval(start, end time.Time) bool {
	return !start.IsZero() && end.After(start) && end.Sub(start) <= 24*time.Hour
}

type User struct {
	ID     int64 `json:"id"`
	Points int   `json:"points"`
}
type Interval struct {
	Start time.Time `json:"start"`
	End   time.Time `json:"end"`
}
type ChangeResult struct {
	Status  string `json:"status,omitempty"`
	Updated bool   `json:"updated,omitempty"`
}
