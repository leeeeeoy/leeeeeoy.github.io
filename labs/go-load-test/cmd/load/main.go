package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/leeeeeoy/personal-space/labs/go-load-test/internal/lab"
	"os"
	"os/signal"
	"runtime/pprof"
	"syscall"
	"time"
)

func main() {
	target := flag.String("url", "http://127.0.0.1:8087/fast", "numeric loopback HTTP target")
	workers := flag.Int("workers", 1, "concurrent workers")
	duration := flag.Duration("duration", 10*time.Second, "request admission duration")
	timeout := flag.Duration("timeout", 2*time.Second, "per-request timeout including body")
	keep := flag.Bool("keep-alive", true, "reuse HTTP/1.1 connections")
	profile := flag.String("cpu-profile", "", "optional local CPU profile file")
	flag.Parse()
	if *profile != "" {
		f, err := os.Create(*profile)
		if err != nil {
			panic(err)
		}
		if err = pprof.StartCPUProfile(f); err != nil {
			panic(err)
		}
		defer f.Close()
		defer pprof.StopCPUProfile()
	}
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	result, err := lab.Run(ctx, lab.Options{URL: *target, Workers: *workers, Duration: *duration, Timeout: *timeout, KeepAlive: *keep})
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	if err = encoder.Encode(result); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
