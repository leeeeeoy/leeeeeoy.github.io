"""Bounded local HTTP plumbing shared by the two external doubles."""
import ipaddress
import os
import json
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def listen_address():
    host, port = os.environ.get("LISTEN_ADDR", "127.0.0.1:8080").rsplit(":", 1)
    ip = ipaddress.IPv4Address(host)
    if not 1 <= int(port) <= 65535 or (not ip.is_loopback and host != "0.0.0.0"):
        raise ValueError("loopback or explicit container wildcard required")
    return host, int(port)


def serve(state):
    class Handler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.1"

        def dispatch(self):
            self.connection.settimeout(5)
            try:
                size = int(self.headers.get("Content-Length", "0"))
                if not 0 <= size <= 8192 or self.headers.get("Transfer-Encoding"):
                    raise ValueError("body budget")
                body = json.loads(self.rfile.read(size)) if size else None
                status, value, delay, headers = state.request(self.command, self.path, body)
            except (ValueError, TimeoutError):
                status, value, delay, headers = 400, {"error": "invalid_json"}, 0, {}
                self.close_connection = True
            time.sleep(delay)
            data = value.encode() if isinstance(value, str) else json.dumps(value).encode()
            try:
                self.send_response(status)
                self.send_header("Content-Type", "text/plain" if isinstance(value, str) else "application/json")
                self.send_header("Content-Length", str(len(data)))
                for key, val in headers.items():
                    self.send_header(key, str(val))
                self.end_headers()
                self.wfile.write(data)
            except (BrokenPipeError, ConnectionResetError):
                pass

        do_GET = do_POST = dispatch

    class Server(ThreadingHTTPServer):
        # The burst is the test subject; don't silently serialize it in a tiny accept backlog.
        request_queue_size = 256
        daemon_threads = True

    Server(listen_address(), Handler).serve_forever()
