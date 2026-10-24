package schedule

import (
	"testing"
	"time"
)

func TestInterval(t *testing.T) {
	start := time.Date(2030, 1, 1, 12, 0, 0, 0, time.UTC)
	if !ValidInterval(start, start.Add(time.Hour)) {
		t.Fatal("valid interval")
	}
	for _, end := range []time.Time{start, start.Add(-time.Second), start.Add(25 * time.Hour)} {
		if ValidInterval(start, end) {
			t.Fatal("invalid interval accepted")
		}
	}
}

func TestAppointmentInput(t *testing.T) {
	v := Appointment{ResourceID: 1, Start: time.Now()}
	v.End = v.Start.Add(time.Hour)
	if !v.Valid() {
		t.Fatal("valid appointment")
	}
	for _, change := range []func(*Appointment){func(v *Appointment) { v.ResourceID = 0 }, func(v *Appointment) { v.ID = "client-id" }, func(v *Appointment) { v.Status = "COMPLETED" }, func(v *Appointment) { v.BookingID = "../a" }} {
		b := v
		change(&b)
		if b.Valid() {
			t.Fatal("invalid appointment accepted", b)
		}
	}
}
