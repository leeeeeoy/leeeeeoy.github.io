#!/usr/bin/env python3
"""Derive the small v3 summary from immutable run.jsonl, without changing raw data."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("session")
name = parser.parse_args().session
if not re.fullmatch(r"[A-Za-z0-9_-]{1,64}", name):
    raise SystemExit("invalid session")
folder = root / "results" / name
raw = (folder / "run.jsonl").read_bytes()
rows = [json.loads(line) for line in raw.splitlines()]
assert len(rows) == 21 and all(row["passed"] for row in rows)
cases = {row["case"]: row for row in rows}
webhooks = cases["Slack-100-simultaneous-webhooks"]["evidence"]
burst = cases["D-100-booking-failures-and-alert-loss"]["evidence"]
alerts = next(e["response"]["events"] for e in burst if e.get("path") == "/stats")
alerts = [e for e in alerts if e["text"].startswith("booking_failed:burst-")]
final = cases["S-final-independent-state"]["evidence"]

def table(database, name):
    return next(e["rows"] for e in final if e.get("database") == database and e.get("query") == "SELECT * FROM " + name + " ORDER BY 1")

bookings = table("booking", "bookings")
appointments = table("schedule", "appointments")
remote = {v["id"]: v for v in appointments}
local = {v["id"] for v in bookings}
pg = next(e["response"] for e in final if e.get("role") == "pg")
summary = {
    "input_sha256": hashlib.sha256(raw).hexdigest(),
    "method_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    "valid_cases": len(rows),
    "webhook_100_http": dict(Counter(e["status"] for e in webhooks if e.get("method") == "POST")),
    "booking_failure_100_http": dict(Counter(e["status"] for e in burst if e.get("role") == "booking" and e.get("method") == "POST")),
    "booking_failure_alerts": {"attempts": len(alerts), "accepted": sum(e["accepted"] for e in alerts), "rejected": sum(not e["accepted"] for e in alerts)},
    "final_counts": {"bookings": len(bookings), "appointments": len(appointments), "pg_statuses": dict(Counter(p["status"] for p in pg.values()))},
    "linked_status_mismatches": [{"booking": b["id"], "local": b["status"], "remote": remote[b["appointment_id"]]["status"]} for b in bookings if b["status"] != remote[b["appointment_id"]]["status"]],
    "active_remote_only": [a["booking_id"] for a in appointments if a["booking_id"] and a["booking_id"] not in local and a["status"] != "CANCELLED"],
    "interpretation_limit": "One bounded local execution, includes expected failure reproduction. Not an automatic-recovery or operating-capacity claim."
}
with (folder / "summary.json").open("x") as output:
    json.dump(summary, output, ensure_ascii=False, indent=2)
    output.write("\n")
print(json.dumps(summary, ensure_ascii=False, indent=2))
