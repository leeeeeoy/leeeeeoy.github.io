package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"time"

	"example.com/schedule-api/internal/client"
	"example.com/schedule-api/internal/httpapi"
	"example.com/schedule-api/internal/schedule"
	"github.com/jackc/pgx/v5/pgxpool"
)

func run(ctx context.Context) error {
	cfg, err := loadConfig()
	if err != nil {
		return err
	}
	db, err := pgxpool.NewWithConfig(ctx, cfg.database)
	if err != nil {
		return err
	}
	defer db.Close()
	ping, cancel := context.WithTimeout(ctx, 5*time.Second)
	err = db.Ping(ping)
	cancel()
	if err != nil {
		return errors.New("DB unavailable")
	}
	httpClient := &http.Client{Timeout: 3 * time.Second, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	service := schedule.NewService(
		db,
		client.NewCallbacks(cfg.peer, httpClient),
		client.NewNotifier(cfg.slack, httpClient),
	)
	server := &http.Server{Addr: cfg.address, Handler: httpapi.NewHandler(service), ReadHeaderTimeout: 2 * time.Second, ReadTimeout: 5 * time.Second, WriteTimeout: 40 * time.Second, IdleTimeout: 30 * time.Second, MaxHeaderBytes: 8192}
	done := make(chan error, 1)
	go func() { done <- server.ListenAndServe() }()
	slog.Info("listening", "service", "schedule-api", "address", cfg.address)
	select {
	case err := <-done:
		if err != http.ErrServerClosed {
			return err
		}
		return nil
	case <-ctx.Done():
		ending, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		err := server.Shutdown(ending)
		if err != nil {
			_ = server.Close()
		}
		return err
	}
}
