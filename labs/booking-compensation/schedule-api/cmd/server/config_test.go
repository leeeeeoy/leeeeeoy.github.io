package main

import (
	"testing"
)

func TestLocalDependencies(t *testing.T) {
	for _, target := range []string{"https://slack.com/x", "http://remote.invalid", "http://user@localhost:8080", "http://localhost:8080?token=a"} {
		if _, err := localURL(target); err == nil {
			t.Fatal("external dependency accepted", target)
		}
	}
	for _, target := range []string{"http://127.0.0.1:18091", "http://schedule-api:8080"} {
		if _, err := localURL(target); err != nil {
			t.Fatal(err)
		}
	}
}

func TestStartupConfiguration(t *testing.T) {
	for key, value := range map[string]string{"DATABASE_URL": "postgres://lab@schedule-db:5432/schedules?sslmode=disable", "BOOKING_URL": "http://booking-api:8080", "SLACK_URL": "http://slack:8080/hooks/test", "DB_POOL_SIZE": "", "LISTEN_ADDR": ""} {
		t.Setenv(key, value)
	}
	c, err := loadConfig()
	if err != nil {
		t.Fatal(err)
	}
	if c.database.MaxConns != 20 || c.address != ":8080" || c.database.ConnConfig.RuntimeParams["lock_timeout"] != "4000" {
		t.Fatal("startup defaults changed")
	}
	for _, tc := range []struct{ key, value string }{{"DATABASE_URL", ""}, {"DATABASE_URL", "postgres://lab@remote.invalid:5432/schedules"}, {"DATABASE_URL", "postgres://lab@schedule-db:5432/other"}, {"DB_POOL_SIZE", "0"}, {"DB_POOL_SIZE", "101"}, {"DB_POOL_SIZE", "x"}, {"BOOKING_URL", "https://remote.invalid"}} {
		t.Run(tc.key+tc.value, func(t *testing.T) {
			t.Setenv(tc.key, tc.value)
			if _, err := loadConfig(); err == nil {
				t.Fatal("invalid startup configuration accepted")
			}
		})
	}
}
