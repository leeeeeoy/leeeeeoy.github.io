package client

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"

	"example.com/schedule-api/internal/schedule"
)

func TestCallbackContract(t *testing.T) {
	for _, action := range []string{"cancel", "complete", "reschedule"} {
		for _, code := range []int{200, 503} {
			interval := schedule.Interval{Start: time.Date(2030, 1, 1, 12, 0, 0, 0, time.UTC), End: time.Date(2030, 1, 1, 13, 0, 0, 0, time.UTC)}
			c := &http.Client{Transport: roundTrip(func(r *http.Request) (*http.Response, error) {
				if r.Method != "POST" || r.URL.Path != "/internal/appointments/id/"+action {
					t.Fatal(r.Method, r.URL)
				}
				if action == "reschedule" {
					var got schedule.Interval
					if err := json.NewDecoder(r.Body).Decode(&got); err != nil || got != interval {
						t.Fatal(got, err)
					}
				} else if r.Body != nil {
					data, _ := io.ReadAll(r.Body)
					if len(data) != 0 {
						t.Fatal(string(data))
					}
				}
				return &http.Response{StatusCode: code, Body: io.NopCloser(strings.NewReader(`{}`)), Header: http.Header{}}, nil
			})}
			err := NewCallbacks("http://booking-api", c).Send(context.Background(), "id", action, interval)
			if (err != nil) != (code != 200) {
				t.Fatal(code, err)
			}
		}
	}
}
