import os
import unittest
from unittest.mock import patch
from http_server import listen_address
from pg import Payments
from slack import Webhooks


class Dependencies(unittest.TestCase):
    def test_loopback_default_and_explicit_container_bind(self):
        with patch.dict(os.environ, {}, clear=True):
            self.assertEqual(listen_address(), ("127.0.0.1", 8080))
        for value in ("127.0.0.1:18092", "0.0.0.0:8080"):
            with patch.dict(os.environ, {"LISTEN_ADDR": value}):
                self.assertEqual(listen_address(), (value.split(":")[0], int(value.split(":")[1])))
        for value in (":8080", "localhost:8080", "192.0.2.1:8080", "127.0.0.1:0", "127.0.0.1:65536", "127.0.0.1:no"):
            with patch.dict(os.environ, {"LISTEN_ADDR": value}):
                with self.assertRaises(ValueError):
                    listen_address()

    def test_payment_approval_failure_and_refund_once(self):
        pg = Payments()
        self.assertEqual(pg.request("POST", "/payments/a/success", {"amount": 60})[:3:2], (201, 1))
        self.assertEqual(pg.request("POST", "/payments/a/success", {"amount": 61})[0], 409)
        for _ in range(2):
            result = pg.request("POST", "/payments/a/refund", None)
        self.assertEqual(result[1]["refund_effects"], 1)
        self.assertEqual(result[1]["refund_requests"], 2)
        self.assertEqual(pg.request("POST", "/payments/b/failure", {"amount": 60})[0], 402)
        self.assertEqual(pg.request("POST", "/payments/b/refund", None)[0], 409)

    def test_refund_failure_and_boundary(self):
        pg = Payments()
        pg.request("POST", "/payments/a/success", {"amount": 60, "refund_outcome": "failure"})
        self.assertEqual(pg.request("POST", "/payments/a/refund", None)[0], 503)
        self.assertEqual(pg.request("GET", "/payments/a", None)[1]["status"], "CAPTURED")
        for body in ({"amount": -1}, {"amount": True}, {"amount": 1, "extra": 1}):
            self.assertEqual(pg.request("POST", "/payments/b/success", body)[0], 400)

    def test_webhook_limit_is_per_path_and_retry_after(self):
        slack = Webhooks()
        with patch("slack.time.monotonic", return_value=10):
            self.assertEqual(slack.request("POST", "/hooks/a", {"text": "one"})[:3:2], (200, 1))
            denied = slack.request("POST", "/hooks/a", {"text": "two"})
            self.assertEqual((denied[0], denied[3]["Retry-After"]), (429, 1))
            self.assertEqual(slack.request("POST", "/hooks/b", {"text": "other"})[0], 200)
        with patch("slack.time.monotonic", return_value=11):
            self.assertEqual(slack.request("POST", "/hooks/a", {"text": "again"})[0], 200)
        self.assertEqual(slack.request("GET", "/stats", None)[1]["rejected"], 1)

    def test_webhook_validation(self):
        slack = Webhooks()
        for body in ({}, {"text": 3}, {"text": "a", "extra": 1}):
            self.assertEqual(slack.request("POST", "/hooks/a", body)[0], 400)


if __name__ == "__main__":
    unittest.main()
