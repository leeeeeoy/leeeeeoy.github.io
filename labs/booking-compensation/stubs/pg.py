"""One-second PG double; no real provider, credentials or automatic recovery."""
import copy
import re
import threading
from http_server import serve


class Payments:
    def __init__(self):
        self.lock = threading.Lock()
        self.payments = {}

    def request(self, method, path, body):
        with self.lock:
            if method == "GET" and path == "/health":
                return 200, {"service": "pg"}, 0, {}
            if method == "GET" and path == "/payments":
                return 200, copy.deepcopy(self.payments), 0, {}
            match = re.fullmatch(r"/payments/([a-zA-Z0-9_-]{1,48})(?:/(success|failure|refund))?", path)
            if not match:
                return 404, {"error": "not_found"}, 0, {}
            key, action = match.groups()
            old = self.payments.get(key)
            if method == "GET" and action is None:
                return (200, dict(old), 1, {}) if old else (404, {"error": "not_found"}, 1, {})
            if method != "POST":
                return 404, {"error": "not_found"}, 0, {}
            if action in ("success", "failure"):
                if not isinstance(body, dict) or body.keys() - {"amount", "refund_outcome"} or type(body.get("amount")) is not int or not 0 < body["amount"] <= 1000000 or body.get("refund_outcome", "success") not in ("success", "failure"):
                    return 400, {"error": "invalid_payment"}, 1, {}
                state = "CAPTURED" if action == "success" else "DECLINED"
                if old:
                    if old["amount"] != body["amount"] or (old["status"] != state and old["status"] != "REFUNDED"):
                        return 409, {"error": "payment_conflict"}, 1, {}
                    return (200 if action == "success" else 402), dict(old), 1, {}
                if len(self.payments) >= 2000:
                    return 503, {"error": "storage_budget"}, 1, {}
                payment = {"id": key, "amount": body["amount"], "status": state, "refund_outcome": body.get("refund_outcome", "success"), "refund_requests": 0, "refund_effects": 0}
                self.payments[key] = payment
                return (201 if action == "success" else 402), dict(payment), 1, {}
            if action != "refund" or not old:
                return 404, {"error": "not_found"}, 1, {}
            old["refund_requests"] += 1
            if old["status"] == "DECLINED":
                return 409, {"error": "not_captured"}, 1, {}
            if old["refund_outcome"] == "failure":
                return 503, {"error": "refund_rejected"}, 1, {}
            if old["status"] != "REFUNDED":
                old["status"] = "REFUNDED"
                old["refund_effects"] += 1
            return 200, dict(old), 1, {}


if __name__ == "__main__":
    serve(Payments())
