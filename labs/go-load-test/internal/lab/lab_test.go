package lab

import (
	"context"
	"encoding/json"
	"io"
	"math"
	"net"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestEndpoints(t *testing.T) {
	server := httptest.NewServer(Handler())
	defer server.Close()
	for _, path := range []string{"/fast", "/slow", "/cpu"} {
		start := time.Now()
		response, err := http.Get(server.URL + path)
		if err != nil {
			t.Fatal(err)
		}
		body, err := io.ReadAll(response.Body)
		response.Body.Close()
		if err != nil {
			t.Fatal(err)
		}
		if response.StatusCode != 200 || response.Header.Get("Content-Type") != "application/json" || !json.Valid(body) {
			t.Fatalf("%s: %d %s", path, response.StatusCode, body)
		}
		if path == "/slow" && time.Since(start) < 95*time.Millisecond {
			t.Fatal("slow did not wait")
		}
		if path == "/cpu" && !strings.Contains(string(body), `"sha256":"`) {
			t.Fatal("CPU result unused")
		}
	}
}
func TestHistogramBoundsAndRank(t *testing.T) {
	h := histogram{}
	if h.quantile(.99) != 0 {
		t.Fatal("empty")
	}
	samples := []time.Duration{10 * time.Microsecond, 20 * time.Microsecond, 30 * time.Microsecond, 100 * time.Microsecond}
	for _, d := range samples {
		h.add(d)
	}
	for _, check := range []struct {
		q    float64
		want time.Duration
	}{{.5, 20 * time.Microsecond}, {.95, 100 * time.Microsecond}, {.99, 100 * time.Microsecond}} {
		got := h.quantile(check.q)
		want := float64(check.want) / float64(time.Millisecond)
		if got < want || got > want*bucketRatio+1e-12 {
			t.Fatalf("q=%v: %v wanted upper bound [%v,%v]", check.q, got, want, want*bucketRatio)
		}
	}
	if h.sum != 160*time.Microsecond {
		t.Fatal(h.sum)
	}
}
func TestRunDrainAccountingAndReuse(t *testing.T) {
	server := httptest.NewServer(Handler())
	defer server.Close()
	slow, err := Run(context.Background(), Options{URL: server.URL + "/slow", Workers: 2, Duration: 10 * time.Millisecond, Timeout: time.Second, KeepAlive: true})
	if err != nil {
		t.Fatal(err)
	}
	if slow.Total != 2 || slow.Success != 2 || slow.ElapsedSeconds < .095 {
		t.Fatalf("%+v", slow)
	}
	if math.Abs(slow.RPS-float64(slow.Total)/slow.ElapsedSeconds) > 1e-9 {
		t.Fatal("wrong RPS denominator")
	}
	for _, keep := range []bool{true, false} {
		result, err := Run(context.Background(), Options{URL: server.URL + "/fast", Workers: 2, Duration: 100 * time.Millisecond, Timeout: time.Second, KeepAlive: keep})
		if err != nil {
			t.Fatal(err)
		}
		if result.Total != result.Success+result.HTTPFailures+result.TransportFailures {
			t.Fatal("unbalanced accounting")
		}
		var bins uint64
		for _, n := range result.LatencyBins {
			bins += n
		}
		if bins != result.Total {
			t.Fatal("lost samples")
		}
		if keep && result.ReusedConnections == 0 {
			t.Fatal("no reuse")
		}
		if !keep && (result.ReusedConnections != 0 || result.NewConnections != result.Total) {
			t.Fatal("unexpected reuse")
		}
	}
}
func TestHTTPTimeoutReadAndNetworkFailures(t *testing.T) {
	bad := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { http.Error(w, "failure", 503) }))
	defer bad.Close()
	run := func(target string, timeout time.Duration) Result {
		t.Helper()
		result, err := Run(context.Background(), Options{URL: target, Workers: 1, Duration: 20 * time.Millisecond, Timeout: timeout, KeepAlive: true})
		if err != nil {
			t.Fatal(err)
		}
		return result
	}
	result := run(bad.URL, time.Second)
	if result.HTTPFailures == 0 || result.Success != 0 || result.TransportFailures != 0 {
		t.Fatal("HTTP classification")
	}
	slow := httptest.NewServer(Handler())
	defer slow.Close()
	result = run(slow.URL+"/slow", 5*time.Millisecond)
	if result.Timeouts == 0 || result.Timeouts != result.TransportFailures {
		t.Fatal("timeout classification")
	}
	broken := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", "100")
		_, _ = w.Write([]byte("short"))
	}))
	defer broken.Close()
	result = run(broken.URL, time.Second)
	if result.TransportFailures == 0 || result.Success != 0 {
		t.Fatal("body read classification")
	}
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	address := listener.Addr().String()
	listener.Close()
	result = run("http://"+address, time.Second)
	if result.TransportFailures == 0 || result.Timeouts != 0 {
		t.Fatal("network classification")
	}
}
func TestValidationCancellationAndNoRedirect(t *testing.T) {
	base := Options{URL: "http://127.0.0.1:8087/fast", Workers: 1, Duration: time.Second, Timeout: time.Second}
	for _, target := range []string{"https://example.com", "http://example.com", "http://localhost:8087", "http://0.0.0.0:8087", "http://127.0.0.1:8087/#x"} {
		o := base
		o.URL = target
		if Validate(o) == nil {
			t.Fatal(target)
		}
	}
	o := base
	o.Workers = 0
	if Validate(o) == nil {
		t.Fatal("workers")
	}
	o = base
	o.Timeout = 0
	if Validate(o) == nil {
		t.Fatal("timeout")
	}
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	result, err := Run(ctx, base)
	if err != nil || !result.Interrupted || result.Total != 0 {
		t.Fatal("cancelled context")
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { http.Redirect(w, r, "http://example.com", 302) }))
	defer server.Close()
	base.URL = server.URL
	base.Duration = 20 * time.Millisecond
	result, err = Run(context.Background(), base)
	if err != nil || result.HTTPFailures == 0 || result.Success != 0 {
		t.Fatal("redirect should not be followed")
	}
}
