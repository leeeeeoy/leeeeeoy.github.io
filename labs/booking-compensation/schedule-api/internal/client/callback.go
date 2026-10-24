package client

import (
	"context"
	"errors"
	"net/http"

	"example.com/schedule-api/internal/schedule"
)

type Callbacks struct {
	url    string
	client *http.Client
}

func NewCallbacks(url string, client *http.Client) *Callbacks {
	return &Callbacks{url: url, client: client}
}
func (c *Callbacks) Send(ctx context.Context, id, action string, interval schedule.Interval) error {
	var body any
	if action == "reschedule" {
		body = interval
	}
	code, _, err := call(ctx, c.client, "POST", c.url+"/internal/appointments/"+id+"/"+action, body)
	if err != nil {
		return err
	}
	if code != 200 {
		return errors.New("callback request failed")
	}
	return nil
}
