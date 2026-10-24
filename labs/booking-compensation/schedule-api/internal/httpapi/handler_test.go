package httpapi

import (
	"encoding/json"
	"errors"
	"example.com/schedule-api/internal/schedule"
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
		mux.ServeHTTP(w, httptest.NewRequest("POST", "/appointments", strings.NewReader(body)))
		if w.Code != 400 {
			t.Fatal(body, w.Code)
		}
	}
}

func TestErrorContract(t *testing.T) {
	for _, tc := range []struct {
		kind   schedule.Kind
		status int
	}{{schedule.Invalid, 400}, {schedule.Conflict, 409}, {schedule.NotFound, 404}, {schedule.Unavailable, 503}} {
		w := httptest.NewRecorder()
		writeError(w, schedule.Fail(tc.kind, "stable_code"))
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

}
