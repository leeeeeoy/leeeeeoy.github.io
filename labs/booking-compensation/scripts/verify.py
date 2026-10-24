#!/usr/bin/env python3
"""Real HTTP + independent psql checks. No test-only routes in either Go API."""
import argparse
import collections
from concurrent.futures import ThreadPoolExecutor
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import threading
import time
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
URLS = {"booking": "http://127.0.0.1:18090", "schedule": "http://127.0.0.1:18091", "pg": "http://127.0.0.1:18092", "slack": "http://127.0.0.1:18093"}


def command(*args):
    return subprocess.check_output(args, cwd=ROOT, text=True, stderr=subprocess.STDOUT, timeout=30).strip()


def save(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w") as f:
        json.dump(value, f, ensure_ascii=False, indent=2)
        f.write("\n")
        f.flush()
        os.fsync(f.fileno())
    json.loads(temporary.read_text())
    temporary.replace(path)


def quote(value):
    return "'" + str(value).replace("'", "''") + "'"


def source_file(path):
    rel = path.relative_to(ROOT)
    return not {"bin", "results", "__pycache__"}.intersection(rel.parts) and path.name != ".env" and (not path.name.startswith(".env.") or path.name == ".env.example")


class Checks:
    def __init__(self, output):
        self.output = output
        self.lock = threading.Lock()
        self.observations = []
        self.rows = []
        self.deadline = time.monotonic() + 300

    def http(self, role, method, path, body=None, want=None):
        assert time.monotonic() < self.deadline, "overall budget"
        req = urllib.request.Request(URLS[role] + path, data=None if body is None else json.dumps(body).encode(), method=method, headers={"Content-Type": "application/json"})
        start = time.monotonic()
        try:
            res = urllib.request.urlopen(req, timeout=35)
        except urllib.error.HTTPError as error:
            res = error
        with res:
            raw = res.read().decode()
            try:
                result = json.loads(raw)
            except ValueError:
                result = raw
            observation = {"role": role, "method": method, "path": path, "input": body, "status": res.status, "elapsed_ms": round((time.monotonic() - start) * 1000, 3), "retry_after": res.headers.get("Retry-After"), "response": result}
        with self.lock:
            self.observations.append(observation)
            with (self.output / "http.jsonl").open("a") as f:
                f.write(json.dumps(observation, ensure_ascii=False) + "\n")
        if want is not None:
            assert res.status == want, observation
        return observation

    def query(self, database, sql):
        value = command("docker", "compose", "exec", "-T", database + "-db", "psql", "-U", "lab", "-d", "bookings" if database == "booking" else "schedules", "-v", "ON_ERROR_STOP=1", "-Atq", "-c", "SELECT COALESCE(json_agg(q),'[]') FROM (" + sql + ") q")
        result = json.loads(value)
        self.observations.append({"database": database, "query": sql, "rows": result})
        return result

    def case(self, name, action):
        self.observations = []
        started = time.monotonic()
        row = {"case": name, "passed": False}
        try:
            action()
            row["passed"] = True
        except Exception as error:
            row["error"] = str(error)
            raise
        finally:
            row.update(elapsed_ms=round((time.monotonic() - started) * 1000, 3), evidence=self.observations)
            self.rows.append(row)
            with (self.output / "run.jsonl").open("a") as f:
                f.write(json.dumps(row, ensure_ascii=False) + "\n")
                f.flush()
                os.fsync(f.fileno())
            save(self.output / "progress.json", {"last_case": name, "cases": len(self.rows), "passed": sum(x["passed"] for x in self.rows), "state": "running" if row["passed"] else "failed"})
            print(name, "PASS" if row["passed"] else "FAIL", flush=True)

    def parallel(self, requests):
        start = threading.Barrier(len(requests))
        def send(args):
            start.wait(timeout=10)
            return self.http(*args)
        with ThreadPoolExecutor(max_workers=len(requests)) as pool:
            return list(pool.map(send, requests))

    def wait(self, condition, limit=4):
        end = time.monotonic() + limit
        while not condition():
            assert time.monotonic() < end, "condition not reached before deadline"
            time.sleep(.03)

    def hold(self, database, sql):
        process = subprocess.Popen(["docker", "compose", "exec", "-T", database + "-db", "psql", "-U", "lab", "-d", "bookings" if database == "booking" else "schedules", "-v", "ON_ERROR_STOP=1", "-Atq"], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        process.stdin.write("BEGIN; SET LOCAL idle_in_transaction_session_timeout='15000'; " + sql + "; SELECT 'ready';\n")
        process.stdin.flush()
        # psql signals after the lock was acquired, not after a guessed sleep.
        assert process.stdout.readline().strip() == "ready", "lock session failed"
        return process

    @staticmethod
    def release(process):
        try:
            process.stdin.write("ROLLBACK;\n\\q\n")
            process.stdin.flush()
            process.communicate(timeout=5)
        except (BrokenPipeError, subprocess.TimeoutExpired):
            process.kill()
            process.communicate()

    def booking(self, name, user, resource, points=100, amount=100):
        return {"id": name, "user_id": user, "resource_id": resource, "start": "2030-01-01T12:00:00Z", "end": "2030-01-01T12:30:00Z", "amount": amount, "points": points, **({"payment_id": "p-" + name} if amount > points else {})}

    def capture(self, b, amount=None, refund="success"):
        return self.http("pg", "POST", "/payments/" + b["payment_id"] + "/success", {"amount": b["amount"] - b["points"] if amount is None else amount, "refund_outcome": refund}, 201)

    def local(self, name):
        return self.query("booking", "SELECT * FROM bookings WHERE id=" + quote(name))

    def remote(self, name):
        return self.query("schedule", "SELECT * FROM appointments WHERE booking_id=" + quote(name))

    def points(self, user, balance, debits, credits):
        assert self.query("booking", f"SELECT points FROM users WHERE id={user}")[0]["points"] == balance
        counts = self.query("booking", f"SELECT kind,count(*) AS n FROM point_entries WHERE user_id={user} GROUP BY kind")
        assert {r["kind"]: r["n"] for r in counts} == {k: v for k, v in (("DEBIT", debits), ("CREDIT", credits)) if v}

    def mixed_create(self, name, user, resource, refund="success"):
        b = self.booking(name, user, resource, 40)
        self.capture(b, refund=refund)
        return self.http("booking", "POST", "/bookings", b, 201)["response"]

    def run(self):
        self.case("S0-independent-projects-and-schemas", self.fresh)
        self.case("PG-one-second-success-and-decline", self.pg_contract)
        self.case("A1-two-users-one-slot", self.two_users)
        self.case("A2-same-user-doubletap", self.doubletap)
        self.case("A3-two-slots-one-budget", self.funds)
        self.case("A4-partial-overlap", self.overlap)
        self.case("A5-concurrent-and-sequential-cancel", self.cancel_doubletap)
        self.case("A6-cancel-and-reuse", self.reuse)
        self.case("A7-competing-reschedules", self.reschedules)
        self.case("A8-reschedule-versus-cancel", self.reschedule_cancel)
        self.case("A12-complete-versus-cancel", self.complete_cancel)
        self.case("B-cross-entry", self.cross_entry)
        self.case("C-payment-validation-and-local-rollback", self.payment_invalid)
        self.case("C-refund-failure-and-inverse-compensation", self.refund_failure)
        self.case("C-compensation-blocked-in-DB", self.compensation_blocked)
        self.case("C-inverse-compensation-blocked-in-DB", self.restore_blocked)
        self.case("C-postcommit-callback-loss", self.callback_loss)
        self.case("D-pool-held-during-real-HTTP", self.pool)
        self.case("Slack-100-simultaneous-webhooks", self.slack_burst)
        self.case("D-100-booking-failures-and-alert-loss", self.failure_burst)
        self.case("S-final-independent-state", self.final)

    def fresh(self):
        for role in URLS:
            self.http(role, "GET", "/health", want=200)
        for role in ("booking", "schedule"):
            self.http(role, "POST", "/lab/faults", {}, 404)
        assert not self.query("booking", "SELECT id FROM bookings")
        assert not self.query("schedule", "SELECT id FROM appointments")
        assert not self.http("pg", "GET", "/payments", want=200)["response"]
        assert {r["tablename"] for r in self.query("booking", "SELECT tablename FROM pg_tables WHERE schemaname='public'")} == {"users", "bookings", "point_entries", "payments"}
        assert {r["tablename"] for r in self.query("schedule", "SELECT tablename FROM pg_tables WHERE schemaname='public'")} == {"resources", "appointments", "appointment_events"}

    def pg_contract(self):
        for outcome, status in (("success", 201), ("failure", 402)):
            result = self.http("pg", "POST", "/payments/contract-" + outcome + "/" + outcome, {"amount": 10}, status)
            assert result["elapsed_ms"] >= 950

    def two_users(self):
        bs = [self.booking("a1-a", 1, 1), self.booking("a1-b", 2, 1)]
        result = self.parallel([("booking", "POST", "/bookings", b) for b in bs])
        assert sorted(x["status"] for x in result) == [201, 409]
        winner = next(x["response"] for x in result if x["status"] == 201)
        self.a1 = winner
        assert len(self.query("schedule", "SELECT id FROM appointments WHERE resource_id=1 AND status<>'CANCELLED'")) == 1
        self.points(winner["user_id"], 0, 1, 0)

    def doubletap(self):
        b = self.booking("a2", 3, 2, 60)
        self.capture(b)
        result = self.parallel([("booking", "POST", "/bookings", b)] * 2)
        assert sorted(x["status"] for x in result) == [201, 409]
        assert len(self.local("a2")) == len(self.remote("a2")) == 1
        self.points(3, 40, 1, 0)

    def funds(self):
        bs = [self.booking("a3-a", 4, 3, 80), self.booking("a3-b", 4, 4, 80)]
        bs[1].update(start="2030-01-01T13:00:00Z", end="2030-01-01T13:30:00Z")
        self.parallel([("pg", "POST", "/payments/" + b["payment_id"] + "/success", {"amount": 20}, 201) for b in bs])
        result = self.parallel([("booking", "POST", "/bookings", b) for b in bs])
        assert sorted(x["status"] for x in result) == [201, 400]
        loser = next(x["input"] for x in result if x["status"] == 400)
        assert not self.local(loser["id"]) and self.remote(loser["id"])[0]["status"] == "CANCELLED"
        assert self.http("pg", "GET", "/payments/" + loser["payment_id"], want=200)["response"]["status"] == "CAPTURED"
        self.points(4, 20, 1, 0)

    def overlap(self):
        bs = [self.booking("a4-a", 5, 5), self.booking("a4-b", 6, 5)]
        bs[1].update(start="2030-01-01T12:15:00Z", end="2030-01-01T12:45:00Z")
        assert sorted(x["status"] for x in self.parallel([("booking", "POST", "/bookings", b) for b in bs])) == [201, 409]

    def cancel_doubletap(self):
        result = self.parallel([("booking", "POST", "/bookings/a2/cancel")] * 2)
        assert [x["status"] for x in result] == [200, 200]
        self.http("booking", "POST", "/bookings/a2/cancel", want=200)
        self.points(3, 100, 1, 1)
        payment = self.http("pg", "GET", "/payments/p-a2", want=200)["response"]
        assert (payment["refund_requests"], payment["refund_effects"]) == (1, 1)
        assert self.local("a2")[0]["status"] == self.remote("a2")[0]["status"] == "CANCELLED"
        assert self.query("schedule", "SELECT count(*) AS n FROM appointment_events WHERE appointment_id=" + quote(self.remote("a2")[0]["id"]) + " AND kind='CANCEL'")[0]["n"] == 1

    def reuse(self):
        b = self.booking("a6", 7, 1)
        result = self.parallel([("booking", "POST", "/bookings/" + self.a1["id"] + "/cancel"), ("booking", "POST", "/bookings", b)])
        assert result[0]["status"] == 200 and result[1]["status"] in (201, 409)
        if result[1]["status"] == 409:
            self.http("booking", "POST", "/bookings", b, 201)
        assert len(self.query("schedule", "SELECT id FROM appointments WHERE resource_id=1 AND status<>'CANCELLED'")) == 1

    def reschedules(self):
        a = self.http("schedule", "POST", "/appointments", {"resource_id": 6, "start": "2030-01-01T10:00:00Z", "end": "2030-01-01T10:30:00Z"}, 201)["response"]
        b = self.http("schedule", "POST", "/appointments", {"resource_id": 6, "start": "2030-01-01T11:00:00Z", "end": "2030-01-01T11:30:00Z"}, 201)["response"]
        target = {"start": "2030-01-01T15:00:00Z", "end": "2030-01-01T15:30:00Z"}
        result = self.parallel([("schedule", "PATCH", "/appointments/" + v["id"], target) for v in (a, b)])
        assert sorted(x["status"] for x in result) == [200, 409]
        assert len(self.query("schedule", "SELECT id FROM appointments WHERE resource_id=6 AND starts_at='2030-01-01T15:00Z'")) == 1

    def reschedule_cancel(self):
        b = self.http("booking", "POST", "/bookings", self.booking("a8", 8, 7), 201)["response"]
        interval = {"start": "2030-01-01T15:00:00Z", "end": "2030-01-01T15:30:00Z"}
        result = self.parallel([("booking", "POST", "/bookings/a8/cancel"), ("schedule", "PATCH", "/appointments/" + b["appointment_id"], interval)])
        assert result[0]["status"] == 200 and result[1]["status"] in (200, 409)
        self.http("booking", "POST", "/internal/appointments/" + b["appointment_id"] + "/reschedule", interval, 200)
        assert self.local("a8")[0]["status"] == self.remote("a8")[0]["status"] == "CANCELLED"
        self.points(8, 100, 1, 1)

    def complete_cancel(self):
        b = self.http("booking", "POST", "/bookings", self.booking("a12", 9, 8), 201)["response"]
        result = self.parallel([("booking", "POST", "/bookings/a12/cancel"), ("schedule", "POST", "/appointments/" + b["appointment_id"] + "/complete")])
        assert result[0]["status"] == 200 and result[1]["status"] in (200, 409)
        self.http("booking", "POST", "/internal/appointments/" + b["appointment_id"] + "/complete", want=200)
        assert self.local("a12")[0]["status"] == self.remote("a12")[0]["status"] == "CANCELLED"
        assert self.query("schedule", "SELECT completed_count FROM resources WHERE id=8")[0]["completed_count"] == 0
        self.points(9, 100, 1, 1)

    def cross_entry(self):
        b = self.booking("cross", 10, 9)
        other = {"resource_id": 9, "start": b["start"], "end": b["end"]}
        result = self.parallel([("booking", "POST", "/bookings", b), ("schedule", "POST", "/appointments", other)])
        assert sorted(x["status"] for x in result) == [201, 409]

    def payment_invalid(self):
        b = self.booking("invalid", 11, 10, 20)
        self.capture(b, 79)
        self.http("booking", "POST", "/bookings", b, 422)
        assert not self.local("invalid") and self.remote("invalid")[0]["status"] == "CANCELLED"
        self.points(11, 100, 0, 0)

    def refund_failure(self):
        self.refund_booking = self.mixed_create("refund-failure", 12, 11, refund="failure")
        response = self.http("booking", "POST", "/bookings/refund-failure/cancel", want=502)["response"]
        assert response["schedule_restored"] is True
        assert self.local("refund-failure")[0]["status"] == self.remote("refund-failure")[0]["status"] == "PENDING"
        self.points(12, 60, 1, 0)

    def compensation_blocked(self):
        b = self.booking("compensation-blocked", 13, 12, 20)
        self.capture(b, 79)
        with ThreadPoolExecutor(1) as pool:
            pending = pool.submit(self.http, "booking", "POST", "/bookings", b, 422)
            self.wait(lambda: bool(self.remote(b["id"])))
            remote = self.remote(b["id"])[0]
            hold = self.hold("schedule", "SELECT 'ready' FROM appointments WHERE id=" + quote(remote["id"]) + " FOR UPDATE")
            try:
                assert pending.result(timeout=10)["response"]["schedule_compensated"] is False
            finally:
                self.release(hold)
        assert not self.local(b["id"]) and self.remote(b["id"])[0]["status"] == "PENDING"
        self.points(13, 100, 0, 0)

    def restore_blocked(self):
        with ThreadPoolExecutor(1) as pool:
            pending = pool.submit(self.http, "booking", "POST", "/bookings/refund-failure/cancel", None, 502)
            self.wait(lambda: self.remote("refund-failure")[0]["status"] == "CANCELLED")
            hold = self.hold("schedule", "SELECT 'ready' FROM appointments WHERE id=" + quote(self.refund_booking["appointment_id"]) + " FOR UPDATE")
            try:
                assert pending.result(timeout=10)["response"]["schedule_restored"] is False
            finally:
                self.release(hold)
        assert self.local("refund-failure")[0]["status"] == "PENDING" and self.remote("refund-failure")[0]["status"] == "CANCELLED"
        self.points(12, 60, 1, 0)

    def callback_loss(self):
        b = self.http("booking", "POST", "/bookings", self.booking("callback-loss", 14, 14), 201)["response"]
        command("docker", "compose", "stop", "booking-api")
        try:
            self.http("schedule", "POST", "/appointments/" + b["appointment_id"] + "/cancel", want=200)
            self.wait(lambda: any(b["appointment_id"] in event["text"] for event in self.http("slack", "GET", "/stats", want=200)["response"]["events"]))
        finally:
            command("docker", "compose", "start", "booking-api")
        def ready():
            try:
                return self.http("booking", "GET", "/health")["status"] == 200
            except urllib.error.URLError:
                return False
        self.wait(ready)
        assert self.local("callback-loss")[0]["status"] == "PENDING" and self.remote("callback-loss")[0]["status"] == "CANCELLED"

    def pool(self):
        day = self.query("schedule", "SELECT ('2030-01-01'::date - '1970-01-01'::date) AS day")[0]["day"]
        hold = self.hold("schedule", f"SELECT 'ready' FROM (SELECT pg_advisory_xact_lock(99,{day})) lock")
        requests = [("booking", "POST", "/bookings", self.booking("pool-" + str(i), 41 + i, 99)) for i in range(20)]
        try:
            with ThreadPoolExecutor(1) as pool:
                pending = pool.submit(self.parallel, requests)
                self.wait(lambda: self.query("schedule", "SELECT count(*) AS n FROM pg_stat_activity WHERE application_name='schedule-api' AND wait_event='advisory'")[0]["n"] == 20, limit=2)
                assert self.query("booking", "SELECT count(*) AS n FROM pg_stat_activity WHERE application_name='booking-api' AND state='idle in transaction'")[0]["n"] == 20
                self.http("booking", "GET", "/health", want=503)
                self.release(hold)
                hold = None
                result = pending.result(timeout=15)
                assert collections.Counter(x["status"] for x in result) == {201: 1, 409: 19}
        finally:
            if hold:
                self.release(hold)
        self.http("booking", "GET", "/health", want=200)

    def slack_burst(self):
        results = self.parallel([("slack", "POST", "/hooks/burst", {"text": "message-" + str(i)}) for i in range(100)])
        counts = collections.Counter(x["status"] for x in results)
        assert sum(counts.values()) == 100 and counts[200] >= 1 and counts[429] >= 1 and set(counts) == {200, 429}
        assert all(x["retry_after"] == "1" for x in results if x["status"] == 429)
        assert all(x["elapsed_ms"] >= 950 for x in results if x["status"] == 200)
        self.http("slack", "GET", "/stats", want=200)

    def failure_burst(self):
        bs = [self.booking("burst-" + str(i), 100 + i, 100 + i, 20) for i in range(100)]
        self.parallel([("pg", "POST", "/payments/" + b["payment_id"] + "/success", {"amount": 79}, 201) for b in bs])
        result = self.parallel([("booking", "POST", "/bookings", b) for b in bs])
        assert all(x["status"] == 422 and x["response"]["schedule_compensated"] for x in result)
        assert not self.query("booking", "SELECT id FROM bookings WHERE id LIKE 'burst-%'")
        assert self.query("booking", "SELECT count(*) AS n FROM users WHERE id BETWEEN 100 AND 199 AND points=100")[0]["n"] == 100
        assert self.query("schedule", "SELECT count(*) AS n FROM appointments WHERE booking_id LIKE 'burst-%' AND status='CANCELLED'")[0]["n"] == 100
        stats = self.http("slack", "GET", "/stats", want=200)["response"]
        events = [e for e in stats["events"] if e["text"].startswith("booking_failed:burst-")]
        assert len(events) == 100 and any(not e["accepted"] for e in events)
        self.http("pg", "GET", "/payments", want=200)

    def final(self):
        assert not self.query("schedule", "SELECT a.id,b.id AS other FROM appointments a JOIN appointments b ON a.id<b.id AND a.resource_id=b.resource_id AND a.status<>'CANCELLED' AND b.status<>'CANCELLED' AND a.starts_at<b.ends_at AND b.starts_at<a.ends_at")
        assert not self.query("booking", "SELECT id FROM users WHERE points<0")
        assert not self.query("schedule", "SELECT r.id FROM resources r WHERE completed_count<>(SELECT count(*) FROM appointments a WHERE a.resource_id=r.id AND a.status='COMPLETED')")
        for db, tables in (("booking", ("bookings", "payments", "point_entries")), ("schedule", ("appointments", "appointment_events"))):
            for table in tables:
                self.query(db, "SELECT * FROM " + table + " ORDER BY 1")
        self.query("booking", "SELECT * FROM users WHERE points<>100 ORDER BY id")
        self.http("pg", "GET", "/payments", want=200)
        self.http("slack", "GET", "/stats", want=200)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--session", required=True)
    name = parser.parse_args().session
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,64}", name):
        raise SystemExit("invalid session")
    output = ROOT / "results" / name
    output.mkdir(parents=True, exist_ok=False)
    config = json.loads(command("docker", "compose", "config", "--format", "json"))
    assert config["networks"]["default"].get("driver") == "bridge"
    for service in config["services"].values():
        for port in service.get("ports", []):
            assert port.get("host_ip") == "127.0.0.1", "non-loopback port"
    source_paths = []
    for path in ROOT.rglob("*"):
        rel = path.relative_to(ROOT)
        if path.is_file() and source_file(path):
            source_paths.append(path)
    sources = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(source_paths)}
    environment = {"started_at": dt.datetime.now(dt.timezone.utc).isoformat(), "command": ["python3", "scripts/verify.py", "--session", name], "git_head": command("git", "rev-parse", "HEAD"), "go": command("go", "version"), "docker": command("docker", "version", "--format", "{{.Client.Version}} / {{.Server.Version}}"), "source_sha256": sources, "images": {image: command("docker", "image", "inspect", image, "--format", "{{.Id}}") for image in ("booking-compensation-booking:local", "booking-compensation-schedule:local")}, "binaries": {p: hashlib.sha256((ROOT / p / "bin/server").read_bytes()).hexdigest() for p in ("booking-api", "schedule-api")}, "conditions": {"db_pool_each": 20, "pg_response_seconds": 1, "slack_accept_interval_seconds": 1, "slack_accepted_response_seconds": 1, "network_internal": False, "outbound_url_allowlist": True, "published_host": "127.0.0.1", "go_http_timeout_seconds": 3, "overall_test_seconds": 300}, "services": {name: {key: value for key, value in service.items() if key in ("image", "cpus", "mem_limit")} for name, service in config["services"].items()}}
    save(output / "environment.json", environment)
    for source in source_paths:
        target = output / "source" / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        assert hashlib.sha256(target.read_bytes()).hexdigest() == sources[str(source.relative_to(ROOT))]
    checks = Checks(output)
    state = {"state": "running"}
    save(output / "status.json", state)
    try:
        checks.run()
        assert len(checks.rows) == 21 and all(x["passed"] for x in checks.rows)
        state["state"] = "collecting"
    except Exception as error:
        state.update(state="failed", error=str(error))
        raise
    finally:
        state.update(cases=len(checks.rows), passed=sum(x["passed"] for x in checks.rows))
        for service in ("booking-api", "schedule-api", "booking-db", "schedule-db", "pg", "slack"):
            try:
                (output / (service + ".log")).write_text(command("docker", "compose", "logs", "--no-color", "--no-log-prefix", "--tail", "500", service) + "\n")
            except Exception as error:
                state.setdefault("collection_errors", []).append(str(error))
        state["finished_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
        if state["state"] == "collecting" and not state.get("collection_errors"):
            state["state"] = "valid"
        state["artifact_sha256"] = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in output.iterdir() if p.is_file() and p.name != "status.json"}
        save(output / "status.json", state)
    print(json.dumps({k: v for k, v in state.items() if k != "artifact_sha256"}, ensure_ascii=False))
    if state["state"] != "valid":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
