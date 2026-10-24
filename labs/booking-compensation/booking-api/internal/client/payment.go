package client

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"example.com/booking-api/internal/booking"
)

type Payments struct {
	url    string
	client *http.Client
}

func NewPayments(url string, client *http.Client) *Payments {
	return &Payments{url: url, client: client}
}
func (c *Payments) Verify(ctx context.Context, id string, amount int) error {
	code, data, err := call(ctx, c.client, "GET", c.url+"/payments/"+id, nil)
	if err != nil || code != 200 {
		return booking.Fail(booking.Upstream, "payment_lookup_failed")
	}
	var payment struct {
		Status string `json:"status"`
		Amount int    `json:"amount"`
	}
	if json.Unmarshal(data, &payment) != nil || payment.Status != "CAPTURED" || payment.Amount != amount {
		return booking.Fail(booking.PaymentInvalid, "payment_invalid")
	}
	return nil
}
func (c *Payments) Refund(ctx context.Context, id string) error {
	code, _, err := call(ctx, c.client, "POST", c.url+"/payments/"+id+"/refund", nil)
	if err != nil || code != 200 {
		return errors.New("refund_failed_or_unknown")
	}
	return nil
}
