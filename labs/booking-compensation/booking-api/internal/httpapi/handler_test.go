package httpapi

import (
	"encoding/json"
	"errors"
	"example.com/booking-api/internal/booking"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestRequestValidationAndRoutes(t *testing.T) {
	mux := NewHandler(nil)
	for _, path := range []string{"/lab/faults", "/metrics"} {
		w := httptest.NewRecorder()
		mux.ServeHTTP(w, httptest.NewRequest("POST", path, strings.NewReader(`{}`)))
		if w.Code != 404 {
			t.Fatal("test route exposed", path, w.Code)
		}
	}
	for _, body := range []string{`{`, `{} {}`, `{"unknown":true}`} {
		w := httptest.NewRecorder()
		mux.ServeHTTP(w, httptest.NewRequest("POST", "/bookings", strings.NewReader(body)))
		if w.Code != 400 {
			t.Fatal(body, w.Code)
		}
	}
}

func TestErrorContract(t *testing.T) {
	for _, tc := range []struct {
		kind   booking.Kind
		status int
	}{{booking.Invalid, 400}, {booking.Conflict, 409}, {booking.NotFound, 404}, {booking.Unavailable, 503}, {booking.Upstream, 502}, {booking.Internal, 500}, {booking.PaymentInvalid, 422}} {
		w := httptest.NewRecorder()
		writeError(w, booking.Fail(tc.kind, "stable_code"))
		if w.Code != tc.status {
			t.Fatal(tc, w.Code)
		}
		var body map[string]any
		if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil || body["error"] != "stable_code" {
			t.Fatal(w.Body.String())
		}
	}
	w := httptest.NewRecorder()
	writeError(w, errors.New("private implementation detail"))
	if w.Code != 500 || strings.Contains(w.Body.String(), "private") {
		t.Fatal(w.Code, w.Body.String())
	}
	no := false
	w = httptest.NewRecorder()
	f := booking.Fail(booking.Upstream, "local_cancel_failed")
	f.ScheduleRestored = &no
	f.RemoteOutcome = "unknown"
	writeError(w, f)
	var detail map[string]any
	_ = json.Unmarshal(w.Body.Bytes(), &detail)
	if detail["schedule_restored"] != false || detail["remote_outcome"] != "unknown" {
		t.Fatal(detail)
	}
}
