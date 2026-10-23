package integrity

import (
	"context"
	"errors"
	"net/url"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// TargetConfig accepts only this disposable lab's explicit loopback URL.
func TargetConfig(raw string) (*pgxpool.Config, error) {
	u, err := url.Parse(raw)
	if err != nil {
		return nil, errors.New("invalid lab database URL")
	}
	query, queryErr := url.ParseQuery(u.RawQuery)
	port, portErr := strconv.Atoi(u.Port())
	_, password := u.User.Password()
	if u.Scheme != "postgres" || u.Hostname() != "127.0.0.1" || portErr != nil || port < 1 || port > 65535 ||
		u.User.Username() != "lab_p0" || password || u.Path != "/concurrency_integrity_p0" ||
		u.Fragment != "" || queryErr != nil || len(query) != 1 || len(query["sslmode"]) != 1 || query.Get("sslmode") != "disable" {
		return nil, errors.New("target must be the dedicated loopback P0 database")
	}
	cfg, err := pgxpool.ParseConfig(raw)
	if err != nil {
		return nil, errors.New("invalid lab connection configuration")
	}
	cfg.MaxConns = 3
	cfg.MinConns = 0
	cfg.ConnConfig.ConnectTimeout = 5 * time.Second
	cfg.ConnConfig.RuntimeParams["application_name"] = "concurrency-integrity-p0-test"
	cfg.ConnConfig.RuntimeParams["default_transaction_isolation"] = "read committed"
	cfg.ConnConfig.RuntimeParams["statement_timeout"] = "5000"
	cfg.ConnConfig.RuntimeParams["lock_timeout"] = "5000"
	return cfg, nil
}

func Open(ctx context.Context, raw string) (*pgxpool.Pool, error) {
	cfg, err := TargetConfig(raw)
	if err != nil {
		return nil, err
	}
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, err
	}
	var database, user, token string
	err = pool.QueryRow(ctx, `SELECT current_database(), current_user,
		(SELECT token FROM lab_identity WHERE singleton)`).Scan(&database, &user, &token)
	if err != nil || database != "concurrency_integrity_p0" || user != "lab_p0" || token != "concurrency-integrity-p0-v1" {
		pool.Close()
		return nil, errors.New("dedicated P0 database identity not verified")
	}
	return pool, nil
}

type Slot struct {
	ID       int64
	Resource string
	Start    time.Time
	End      time.Time
	Active   bool
}

type State struct {
	Slots         []Slot
	ConflictPairs int64
}

// Inspect reads a consistent final state; call only after participants finish.
func Inspect(ctx context.Context, conn *pgx.Conn, resources []string) (State, error) {
	state := State{Slots: []Slot{}}
	tx, err := conn.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly})
	if err != nil {
		return state, err
	}
	defer func() {
		cleanup, stop := context.WithTimeout(context.Background(), 5*time.Second)
		defer stop()
		_ = tx.Rollback(cleanup)
	}()
	rows, err := tx.Query(ctx, `SELECT id, resource_id, starts_at, ends_at, active
		FROM slots WHERE resource_id = ANY($1) ORDER BY id`, resources)
	if err != nil {
		return state, err
	}
	for rows.Next() {
		var slot Slot
		if err := rows.Scan(&slot.ID, &slot.Resource, &slot.Start, &slot.End, &slot.Active); err != nil {
			rows.Close()
			return state, err
		}
		state.Slots = append(state.Slots, slot)
	}
	if err := rows.Err(); err != nil {
		return state, err
	}
	err = tx.QueryRow(ctx, `SELECT count(*) FROM slots a JOIN slots b
		ON a.id < b.id AND a.resource_id = b.resource_id
		AND a.active AND b.active AND a.starts_at < b.ends_at AND b.starts_at < a.ends_at
		WHERE a.resource_id = ANY($1)`, resources).Scan(&state.ConflictPairs)
	if err != nil {
		return state, err
	}
	return state, tx.Commit(ctx)
}
