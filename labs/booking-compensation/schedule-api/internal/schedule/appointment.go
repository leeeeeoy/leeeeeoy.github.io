package schedule

import (
	"regexp"
	"time"
)

var identifier = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,48}$`)

type Appointment struct {
	ID         string    `json:"id,omitempty"`
	ResourceID int32     `json:"resource_id"`
	BookingID  string    `json:"booking_id,omitempty"`
	Start      time.Time `json:"start"`
	End        time.Time `json:"end"`
	Status     string    `json:"status,omitempty"`
}

func (v Appointment) Valid() bool {
	return v.ID == "" && v.Status == "" && v.ResourceID > 0 && (v.BookingID == "" || identifier.MatchString(v.BookingID)) && ValidInterval(v.Start, v.End)
}

type Interval struct {
	Start time.Time `json:"start"`
	End   time.Time `json:"end"`
}

func ValidInterval(start, end time.Time) bool {
	return !start.IsZero() && end.After(start) && end.Sub(start) <= 24*time.Hour
}
