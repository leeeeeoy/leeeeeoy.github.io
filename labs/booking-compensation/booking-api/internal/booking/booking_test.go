package booking

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

func TestBookingInput(t *testing.T) {
	b := Booking{ID: "one", UserID: 1, ResourceID: 1, Start: time.Now(), Amount: 100, Points: 100}
	b.End = b.Start.Add(time.Hour)
	if err := b.Validate(); err != nil {
		t.Fatal(err)
	}
	for _, change := range []func(*Booking){func(b *Booking) { b.Points = 101 }, func(b *Booking) { b.Points = -1 }, func(b *Booking) { b.Points = 1 }, func(b *Booking) { b.Status = "PENDING" }, func(b *Booking) { b.ID = "../a" }, func(b *Booking) { b.UserID = 0 }} {
		v := b
		change(&v)
		if v.Validate() == nil {
			t.Fatal("invalid booking accepted", v)
		}
	}
}
