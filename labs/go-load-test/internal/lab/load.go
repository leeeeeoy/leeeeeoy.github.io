package lab

import (
	"context"
	"errors"
	"io"
	"math"
	"net"
	"net/http"
	"net/http/httptrace"
	"net/url"
	"runtime"
	"sync"
	"syscall"
	"time"
)

const bucketCount = 2048
const bucketRatio = 1.02

// shortcut: quantiles are bucket upper bounds, use a higher precision histogram if <2% error matters.
type histogram struct {
	bins  [bucketCount]uint64
	count uint64
	sum   time.Duration
}

func (h *histogram) add(d time.Duration) {
	i := 0
	if d > time.Microsecond {
		i = int(math.Ceil(math.Log(float64(d)/float64(time.Microsecond)) / math.Log(bucketRatio)))
	}
	if i >= bucketCount {
		i = bucketCount - 1
	}
	h.bins[i]++
	h.count++
	h.sum += d
}
func (h *histogram) quantile(q float64) float64 {
	if h.count == 0 {
		return 0
	}
	rank := uint64(math.Ceil(float64(h.count) * q))
	var count uint64
	for i, n := range h.bins {
		count += n
		if count >= rank {
			return math.Pow(bucketRatio, float64(i)) / 1000
		}
	}
	return 0
}

type Options struct {
	URL               string
	Workers           int
	Duration, Timeout time.Duration
	KeepAlive         bool
}
type Result struct {
	URL               string              `json:"url"`
	Workers           int                 `json:"workers"`
	KeepAlive         bool                `json:"keep_alive"`
	StartedUTC        string              `json:"started_utc"`
	RequestedSeconds  float64             `json:"requested_seconds"`
	ElapsedSeconds    float64             `json:"elapsed_seconds"`
	TimeoutSeconds    float64             `json:"timeout_seconds"`
	Total             uint64              `json:"total"`
	Success           uint64              `json:"success"`
	HTTPFailures      uint64              `json:"http_failures"`
	TransportFailures uint64              `json:"transport_failures"`
	Timeouts          uint64              `json:"timeouts_subset"`
	NewConnections    uint64              `json:"new_connections"`
	ReusedConnections uint64              `json:"reused_connections"`
	RPS               float64             `json:"rps"`
	SuccessRPS        float64             `json:"success_rps"`
	MeanMS            float64             `json:"mean_ms"`
	P50MS             float64             `json:"p50_ms_upper_bound"`
	P95MS             float64             `json:"p95_ms_upper_bound"`
	P99MS             float64             `json:"p99_ms_upper_bound"`
	CPUSeconds        float64             `json:"client_cpu_seconds"`
	PeakRSSKiB        int64               `json:"client_peak_rss_kib"`
	HeapEndBytes      uint64              `json:"client_heap_end_bytes"`
	AllocatedBytes    uint64              `json:"client_allocated_bytes"`
	GOMAXPROCS        int                 `json:"gomaxprocs"`
	Interrupted       bool                `json:"interrupted"`
	LatencyBins       [bucketCount]uint64 `json:"latency_bins"`
}

type workerStats struct {
	latency                                                                               histogram
	success, httpFailures, transportFailures, timeouts, newConnections, reusedConnections uint64
}

func Validate(o Options) error {
	u, err := url.Parse(o.URL)
	if err != nil || u.Scheme != "http" || u.User != nil || u.Fragment != "" || net.ParseIP(u.Hostname()) == nil || !net.ParseIP(u.Hostname()).IsLoopback() {
		return errors.New("target must be an http URL with a numeric loopback IP (e.g. http://127.0.0.1:8087/fast)")
	}
	if o.Workers < 1 || o.Workers > 2048 || o.Duration <= 0 || o.Duration > 24*time.Hour || o.Timeout <= 0 || o.Timeout > time.Minute {
		return errors.New("workers must be 1..2048, duration (0,24h], timeout (0,1m]")
	}
	return nil
}
func cpuSeconds(r syscall.Rusage) float64 {
	return float64(r.Utime.Sec+r.Stime.Sec) + float64(r.Utime.Usec+r.Stime.Usec)/1e6
}

func Run(ctx context.Context, o Options) (Result, error) {
	if err := Validate(o); err != nil {
		return Result{}, err
	}
	transport := http.DefaultTransport.(*http.Transport).Clone()
	transport.Proxy = nil
	transport.DisableKeepAlives = !o.KeepAlive
	transport.MaxIdleConns = o.Workers
	transport.MaxIdleConnsPerHost = o.Workers
	transport.MaxConnsPerHost = o.Workers
	defer transport.CloseIdleConnections()
	client := &http.Client{Transport: transport, Timeout: o.Timeout, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	stats := make([]workerStats, o.Workers)
	var ready, done sync.WaitGroup
	ready.Add(o.Workers)
	done.Add(o.Workers)
	gate := make(chan struct{})
	var deadline time.Time
	for i := range stats {
		go func(i int) {
			defer done.Done()
			s := &stats[i]
			trace := &httptrace.ClientTrace{GotConn: func(info httptrace.GotConnInfo) {
				if info.Reused {
					s.reusedConnections++
				} else {
					s.newConnections++
				}
			}}
			workerCtx := httptrace.WithClientTrace(ctx, trace)
			ready.Done()
			<-gate
			for time.Now().Before(deadline) && ctx.Err() == nil {
				start := time.Now()
				req, _ := http.NewRequestWithContext(workerCtx, http.MethodGet, o.URL, nil)
				response, err := client.Do(req)
				if err == nil {
					_, err = io.Copy(io.Discard, response.Body)
					closeErr := response.Body.Close()
					if err == nil {
						err = closeErr
					}
				}
				s.latency.add(time.Since(start))
				if err != nil {
					s.transportFailures++
					var netErr net.Error
					if errors.Is(err, context.DeadlineExceeded) || (errors.As(err, &netErr) && netErr.Timeout()) {
						s.timeouts++
					}
				} else if response.StatusCode >= 200 && response.StatusCode < 300 {
					s.success++
				} else {
					s.httpFailures++
				}
			}
		}(i)
	}
	ready.Wait()
	var before, after syscall.Rusage
	if err := syscall.Getrusage(syscall.RUSAGE_SELF, &before); err != nil {
		close(gate)
		done.Wait()
		return Result{}, err
	}
	var memBefore, memAfter runtime.MemStats
	runtime.ReadMemStats(&memBefore)
	start := time.Now()
	deadline = start.Add(o.Duration)
	close(gate)
	done.Wait()
	elapsed := time.Since(start)
	if err := syscall.Getrusage(syscall.RUSAGE_SELF, &after); err != nil {
		return Result{}, err
	}
	runtime.ReadMemStats(&memAfter)
	total := workerStats{}
	for _, s := range stats {
		total.success += s.success
		total.httpFailures += s.httpFailures
		total.transportFailures += s.transportFailures
		total.timeouts += s.timeouts
		total.newConnections += s.newConnections
		total.reusedConnections += s.reusedConnections
		total.latency.count += s.latency.count
		total.latency.sum += s.latency.sum
		for i, n := range s.latency.bins {
			total.latency.bins[i] += n
		}
	}
	peak := after.Maxrss
	if runtime.GOOS == "darwin" {
		peak /= 1024
	}
	result := Result{URL: o.URL, Workers: o.Workers, KeepAlive: o.KeepAlive, StartedUTC: start.UTC().Format(time.RFC3339Nano), RequestedSeconds: o.Duration.Seconds(), ElapsedSeconds: elapsed.Seconds(), TimeoutSeconds: o.Timeout.Seconds(), Total: total.latency.count, Success: total.success, HTTPFailures: total.httpFailures, TransportFailures: total.transportFailures, Timeouts: total.timeouts, NewConnections: total.newConnections, ReusedConnections: total.reusedConnections, CPUSeconds: cpuSeconds(after) - cpuSeconds(before), PeakRSSKiB: peak, HeapEndBytes: memAfter.HeapAlloc, AllocatedBytes: memAfter.TotalAlloc - memBefore.TotalAlloc, GOMAXPROCS: runtime.GOMAXPROCS(0), Interrupted: ctx.Err() != nil, LatencyBins: total.latency.bins}
	result.RPS = float64(result.Total) / elapsed.Seconds()
	result.SuccessRPS = float64(result.Success) / elapsed.Seconds()
	if result.Total > 0 {
		result.MeanMS = float64(total.latency.sum) / float64(result.Total) / float64(time.Millisecond)
	}
	result.P50MS = total.latency.quantile(.5)
	result.P95MS = total.latency.quantile(.95)
	result.P99MS = total.latency.quantile(.99)
	return result, nil
}
