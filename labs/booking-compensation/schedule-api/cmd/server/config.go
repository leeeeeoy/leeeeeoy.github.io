package main

import (
	"errors"
	"net"
	"net/url"
	"os"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
)

type config struct {
	address     string
	database    *pgxpool.Config
	peer, slack string
}

func loadConfig() (config, error) {
	var c config
	raw := os.Getenv("DATABASE_URL")
	if raw == "" {
		return c, errors.New("DATABASE_URL is required")
	}
	cfg, err := pgxpool.ParseConfig(raw)
	if err != nil {
		return c, errors.New("invalid DATABASE_URL")
	}
	if cfg.ConnConfig.Database != "schedules" || (cfg.ConnConfig.Host != "schedule-db" && cfg.ConnConfig.Host != "127.0.0.1" && cfg.ConnConfig.Host != "localhost") {
		return c, errors.New("not a local lab database")
	}
	max := 20
	if value := os.Getenv("DB_POOL_SIZE"); value != "" {
		max, err = strconv.Atoi(value)
		if err != nil || max < 1 || max > 100 {
			return c, errors.New("invalid DB_POOL_SIZE")
		}
	}
	cfg.MaxConns = int32(max)
	cfg.ConnConfig.RuntimeParams["application_name"] = "schedule-api"
	cfg.ConnConfig.RuntimeParams["statement_timeout"] = "8000"
	cfg.ConnConfig.RuntimeParams["lock_timeout"] = "4000"
	c.database = cfg
	c.address = os.Getenv("LISTEN_ADDR")
	if c.address == "" {
		c.address = "127.0.0.1:8080"
	}
	host, port, err := net.SplitHostPort(c.address)
	ip := net.ParseIP(host)
	number, portErr := strconv.Atoi(port)
	// Containers explicitly opt in to IPv4 wildcard; standalone defaults to loopback.
	if err != nil || portErr != nil || number < 1 || number > 65535 || ip == nil || (!ip.IsLoopback() && host != "0.0.0.0") {
		return c, errors.New("numeric loopback or explicit container wildcard listen address required")
	}
	if c.peer, err = localURL(os.Getenv("BOOKING_URL")); err != nil {
		return c, err
	}

	if c.slack, err = localURL(os.Getenv("SLACK_URL")); err != nil {
		return c, err
	}
	return c, nil
}
func localURL(value string) (string, error) {
	u, err := url.Parse(value)
	if err != nil || u.Scheme != "http" || u.User != nil || u.RawQuery != "" || u.Fragment != "" {
		return "", errors.New("local HTTP dependency required")
	}
	switch u.Hostname() {
	case "127.0.0.1", "localhost", "booking-api", "schedule-api", "pg", "slack":
	default:
		return "", errors.New("external dependency refused")
	}
	return strings.TrimRight(value, "/"), nil
}
