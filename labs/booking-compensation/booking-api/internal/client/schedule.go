package client

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"example.com/booking-api/internal/booking"
)

type Scheduler struct {
	url    string
	client *http.Client
}

func NewScheduler(url string, client *http.Client) *Scheduler {
	return &Scheduler{url: url, client: client}
}
func (c *Scheduler) Create(ctx context.Context, b booking.Booking) (string, error) {
	code, data, err := call(ctx, c.client, "POST", c.url+"/internal/appointments", map[string]any{"resource_id": b.ResourceID, "booking_id": b.ID, "start": b.Start, "end": b.End})
	if err != nil || code != 201 {
		kind, outcome := booking.Upstream, "unknown"
		if err == nil && code == 409 {
			kind, outcome = booking.Conflict, "rejected"
		}
		failure := booking.Fail(kind, "schedule_create_failed")
		failure.RemoteOutcome = outcome
		return "", failure
	}
	var remote struct {
		ID string `json:"id"`
	}
	if json.Unmarshal(data, &remote) != nil || !booking.ValidID(remote.ID) {
		f := booking.Fail(booking.Upstream, "schedule_response_invalid")
		f.RemoteOutcome = "unknown"
		return "", f
	}
	return remote.ID, nil
}
func (c *Scheduler) Cancel(ctx context.Context, id string) error {
	return c.change(ctx, "POST", "/internal/appointments/"+id+"/cancel")
}
func (c *Scheduler) Compensate(ctx context.Context, id string) error {
	return c.change(ctx, "DELETE", "/internal/appointments/"+id)
}
func (c *Scheduler) Restore(ctx context.Context, id string) error {
	return c.change(ctx, "POST", "/internal/appointments/"+id+"/restore")
}
func (c *Scheduler) change(ctx context.Context, method, path string) error {
	code, _, err := call(ctx, c.client, method, c.url+path, nil)
	if err != nil {
		return err
	}
	if code != 200 {
		return errors.New("schedule request failed")
	}
	return nil
}
