package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"github.com/leeeeeoy/leeeeeoy.github.io/labs/go-load-test/internal/lab"
	"net"
	"net/http"
	"os"
	"os/signal"
	"runtime/pprof"
	"syscall"
	"time"
)

func main() {
	address := flag.String("addr", "127.0.0.1:8087", "numeric loopback listen address")
	profile := flag.String("cpu-profile", "", "optional local CPU profile file")
	flag.Parse()
	host, _, err := net.SplitHostPort(*address)
	if err != nil || net.ParseIP(host) == nil || !net.ParseIP(host).IsLoopback() {
		fmt.Fprintln(os.Stderr, "server must bind a numeric loopback address")
		os.Exit(1)
	}
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
	server := &http.Server{Addr: *address, Handler: lab.Handler(), ReadHeaderTimeout: 2 * time.Second, IdleTimeout: 30 * time.Second}
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	shutdownDone := make(chan struct{})
	go func() {
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), 3*time.Second)
		defer cancel()
		_ = server.Shutdown(shutdown)
		close(shutdownDone)
	}()
	fmt.Fprintln(os.Stderr, "listening", *address)
	if err = server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	<-shutdownDone
}
