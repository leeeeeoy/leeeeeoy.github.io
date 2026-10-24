package client

import (
	"context"
	"fmt"
	"net/http"
)

type Notifier struct {
	url    string
	client *http.Client
}

func NewNotifier(url string, client *http.Client) *Notifier {
	return &Notifier{url: url, client: client}
}
func (n *Notifier) Send(ctx context.Context, id, event string) error {
	code, _, err := call(ctx, n.client, "POST", n.url, map[string]string{"text": event + ":" + id})
	if err != nil {
		return err
	}
	if code != 200 {
		return fmt.Errorf("webhook status %d", code)
	}
	return nil
}
