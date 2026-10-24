package httpapi

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"time"

	"example.com/booking-api/internal/booking"
)

func jsonReply(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}
func readJSON(w http.ResponseWriter, r *http.Request, value any) bool {
	d := json.NewDecoder(http.MaxBytesReader(w, r.Body, 8192))
	d.DisallowUnknownFields()
	if err := d.Decode(value); err != nil {
		jsonReply(w, 400, map[string]string{"error": "invalid_json"})
		return false
	}
	if d.Decode(new(any)) != io.EOF {
		jsonReply(w, 400, map[string]string{"error": "extra_json"})
		return false
	}
	return true
}
func requestContext(r *http.Request) (context.Context, context.CancelFunc) {
	return context.WithTimeout(r.Context(), 30*time.Second)
}

func writeError(w http.ResponseWriter, err error) {
	var failure *booking.Error
	if !errors.As(err, &failure) {
		jsonReply(w, 500, map[string]string{"error": "internal_error"})
		return
	}
	status := 500
	switch failure.Kind {
	case booking.Invalid:
		status = 400
	case booking.Conflict:
		status = 409
	case booking.NotFound:
		status = 404
	case booking.Unavailable:
		status = 503
	case booking.Upstream:
		status = 502
	case booking.PaymentInvalid:
		status = 422
	}
	body := map[string]any{"error": failure.Code}
	if failure.RemoteOutcome != "" {
		body["remote_outcome"] = failure.RemoteOutcome
	}
	if failure.ScheduleCompensated != nil {
		body["schedule_compensated"] = *failure.ScheduleCompensated
	}
	if failure.ScheduleRestored != nil {
		body["schedule_restored"] = *failure.ScheduleRestored
	}
	jsonReply(w, status, body)
}
