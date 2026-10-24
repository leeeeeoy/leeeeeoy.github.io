"""Strict one-per-second webhook double, accepted response delayed one second."""
import math
import threading
import time
from http_server import serve


class Webhooks:
    def __init__(self):
        self.lock = threading.Lock()
        self.next_allowed = {}
        self.accepted = self.rejected = 0
        self.events = []

    def request(self, method, path, body):
        with self.lock:
            if method == "GET" and path == "/health":
                return 200, {"service": "slack"}, 0, {}
            if method == "GET" and path == "/stats":
                return 200, {"accepted": self.accepted, "rejected": self.rejected, "attempts": self.accepted + self.rejected, "events": list(self.events)}, 0, {}
            if method != "POST" or not path.startswith("/hooks/") or len(path) > 100 or "?" in path:
                return 404, {"error": "not_found"}, 0, {}
            if not isinstance(body, dict) or set(body) != {"text"} or not isinstance(body["text"], str) or not 0 < len(body["text"]) <= 1000:
                return 400, {"error": "invalid_message"}, 0, {}
            now = time.monotonic()
            remaining = self.next_allowed.get(path, 0) - now
            if remaining > 0:
                self.rejected += 1
                self.events = (self.events + [{"path": path, "accepted": False, "text": body["text"]}])[-2000:]
                return 429, {"error": "rate_limited"}, 0, {"Retry-After": max(1, math.ceil(remaining))}
            if path not in self.next_allowed and len(self.next_allowed) >= 100:
                return 503, {"error": "webhook_budget"}, 0, {}
            self.next_allowed[path] = now + 1
            self.accepted += 1
            self.events = (self.events + [{"path": path, "accepted": True, "text": body["text"]}])[-2000:]
            return 200, "ok", 1, {}


if __name__ == "__main__":
    serve(Webhooks())
