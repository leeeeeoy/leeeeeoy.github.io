package client

import (
	"context"
	"errors"
	"io"
	"net/http"
	"strings"
	"testing"
)

type roundTrip func(*http.Request) (*http.Response, error)

func (f roundTrip) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

type trackedBody struct {
	io.Reader
	closed bool
}

func (b *trackedBody) Close() error { b.closed = true; return nil }
func TestHTTPBodyAndContext(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	cancelled := &http.Client{Transport: roundTrip(func(r *http.Request) (*http.Response, error) { return nil, r.Context().Err() })}
	if _, _, err := call(ctx, cancelled, "GET", "http://localhost/test", nil); !errors.Is(err, context.Canceled) {
		t.Fatal("request context was lost", err)
	}

	for _, size := range []int{2, 65537} {
		body := &trackedBody{Reader: strings.NewReader(strings.Repeat("x", size))}
		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()
		c := &http.Client{Transport: roundTrip(func(r *http.Request) (*http.Response, error) {
			if r.Header.Get("Content-Type") != "application/json" {
				t.Fatal("content type")
			}
			return &http.Response{StatusCode: 200, Body: body, Header: http.Header{}}, nil
		})}
		_, _, err := call(ctx, c, "POST", "http://localhost/test", map[string]string{"a": "b"})
		if (err != nil) != (size > 65536) || !body.closed {
			t.Fatal("body limit/close", size, err, body.closed)
		}
	}
	c := &http.Client{Transport: roundTrip(func(*http.Request) (*http.Response, error) { return nil, errors.New("connection lost") })}
	if _, _, err := call(context.Background(), c, "GET", "http://localhost/test", nil); err == nil {
		t.Fatal("transport error discarded")
	}
}
func TestWebhookStatus(t *testing.T) {
	for _, code := range []int{200, 429} {
		c := &http.Client{Transport: roundTrip(func(r *http.Request) (*http.Response, error) {
			data, _ := io.ReadAll(r.Body)
			if !strings.Contains(string(data), "event:id") {
				t.Fatal(string(data))
			}
			return &http.Response{StatusCode: code, Body: io.NopCloser(strings.NewReader("ok")), Header: http.Header{}}, nil
		})}
		if err := NewNotifier("http://slack/hooks/a", c).Send(context.Background(), "id", "event"); (err != nil) != (code != 200) {
			t.Fatal(code, err)
		}
	}
}
