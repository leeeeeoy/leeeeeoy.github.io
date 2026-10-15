package lab

import (
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"time"
)

const CPUIterations = 20000

func Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /fast", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"ok":true}`))
	})
	mux.HandleFunc("GET /slow", func(w http.ResponseWriter, r *http.Request) {
		timer := time.NewTimer(100 * time.Millisecond)
		defer timer.Stop()
		select {
		case <-timer.C:
		case <-r.Context().Done():
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"ok":true}`))
	})
	mux.HandleFunc("GET /cpu", func(w http.ResponseWriter, r *http.Request) {
		digest := sha256.Sum256([]byte("go-http-concurrency"))
		for i := 0; i < CPUIterations; i++ {
			if i%256 == 0 && r.Context().Err() != nil {
				return
			}
			digest = sha256.Sum256(digest[:])
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"sha256":"` + hex.EncodeToString(digest[:]) + `"}`))
	})
	return mux
}
