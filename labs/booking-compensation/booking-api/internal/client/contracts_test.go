package client

import (
	"context"
	"errors"
	"io"
	"net/http"
	"strings"
	"testing"

	"example.com/booking-api/internal/booking"
)

func responseClient(code int, body string) *http.Client {
	return &http.Client{Transport: roundTrip(func(*http.Request) (*http.Response, error) {
		return &http.Response{StatusCode: code, Body: io.NopCloser(strings.NewReader(body)), Header: http.Header{}}, nil
	})}
}
func TestPaymentVerification(t *testing.T) {
	for _, tc := range []struct {
		code int
		body string
		kind booking.Kind
	}{
		{200, `{"status":"CAPTURED","amount":40}`, ""}, {200, `{"status":"CAPTURED","amount":39}`, booking.PaymentInvalid}, {200, `{"status":"REFUNDED","amount":40}`, booking.PaymentInvalid}, {200, `{`, booking.PaymentInvalid}, {503, `{}`, booking.Upstream},
	} {
		err := NewPayments("http://pg", responseClient(tc.code, tc.body)).Verify(context.Background(), "payment", 40)
		if tc.kind == "" {
			if err != nil {
				t.Fatal(err)
			}
			continue
		}
		var f *booking.Error
		if !errors.As(err, &f) || f.Kind != tc.kind {
			t.Fatal(tc, err)
		}
	}
	for _, code := range []int{200, 503} {
		err := NewPayments("http://pg", responseClient(code, `{}`)).Refund(context.Background(), "payment")
		if (err != nil) != (code != 200) {
			t.Fatal(code, err)
		}
	}
}
func TestScheduleOutcomeContract(t *testing.T) {
	for _, tc := range []struct {
		code    int
		body    string
		kind    booking.Kind
		outcome string
	}{
		{201, `{"id":"remote"}`, "", ""}, {409, `{}`, booking.Conflict, "rejected"}, {503, `{}`, booking.Upstream, "unknown"}, {201, `{"id":"../bad"}`, booking.Upstream, "unknown"},
	} {
		id, err := NewScheduler("http://schedule-api", responseClient(tc.code, tc.body)).Create(context.Background(), booking.Booking{ID: "booking", ResourceID: 1})
		if tc.kind == "" {
			if err != nil || id != "remote" {
				t.Fatal(id, err)
			}
			continue
		}
		var f *booking.Error
		if !errors.As(err, &f) || f.Kind != tc.kind || f.RemoteOutcome != tc.outcome {
			t.Fatal(tc, err)
		}
	}
	c := &http.Client{Transport: roundTrip(func(*http.Request) (*http.Response, error) { return nil, errors.New("response lost") })}
	_, err := NewScheduler("http://schedule-api", c).Create(context.Background(), booking.Booking{})
	var f *booking.Error
	if !errors.As(err, &f) || f.RemoteOutcome != "unknown" {
		t.Fatal(err)
	}
}
