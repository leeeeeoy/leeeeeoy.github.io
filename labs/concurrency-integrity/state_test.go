package integrity

import "testing"

func TestTargetConfig(t *testing.T) {
	valid := "postgres://lab_p0@127.0.0.1:54321/concurrency_integrity_p0?sslmode=disable"
	for _, tc := range []struct {
		name, target string
		valid        bool
	}{
		{"dedicated", valid, true},
		{"missing", "", false},
		{"remote", "postgres://lab_p0@192.0.2.1:54321/concurrency_integrity_p0?sslmode=disable", false},
		{"wrong_database", "postgres://lab_p0@127.0.0.1:54321/postgres?sslmode=disable", false},
		{"wrong_user", "postgres://postgres@127.0.0.1:54321/concurrency_integrity_p0?sslmode=disable", false},
		{"no_user", "postgres://127.0.0.1:54321/concurrency_integrity_p0?sslmode=disable", false},
		{"password", "postgres://lab_p0:synthetic@127.0.0.1:54321/concurrency_integrity_p0?sslmode=disable", false},
		{"missing_port", "postgres://lab_p0@127.0.0.1/concurrency_integrity_p0?sslmode=disable", false},
		{"out_of_range_port", "postgres://lab_p0@127.0.0.1:65536/concurrency_integrity_p0?sslmode=disable", false},
		{"query_override", valid + "&host=192.0.2.1", false},
		{"duplicate_query", valid + "&sslmode=disable", false},
		{"fragment", valid + "#fragment", false},
		{"malformed", "postgres://%", false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			cfg, err := TargetConfig(tc.target)
			if (err == nil) != tc.valid {
				t.Fatalf("valid=%v, error=%v", tc.valid, err)
			}
			if tc.valid && (cfg.MaxConns != 3 || cfg.ConnConfig.RuntimeParams["default_transaction_isolation"] != "read committed") {
				t.Fatal("unexpected pool or isolation settings")
			}
		})
	}
}
