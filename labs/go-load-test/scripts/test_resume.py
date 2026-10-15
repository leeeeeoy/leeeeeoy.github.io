import json
from pathlib import Path
import tempfile
import unittest
from resume import atomic_json, validate


class ResumeStorageTest(unittest.TestCase):
    def test_atomic_commit_and_failed_serialization_preserve_destination(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.json"
            atomic_json(path, {"complete": 1})
            self.assertEqual(json.loads(path.read_text()), {"complete": 1})
            self.assertFalse(path.with_name("result.json.tmp").exists())
            with self.assertRaises(TypeError):
                atomic_json(path, {"unsupported": object()})
            self.assertEqual(json.loads(path.read_text()), {"complete": 1})

    def test_reject_truncated_or_inconsistent_results(self):
        value = {"url": "http://127.0.0.1:8087/fast", "workers": 1, "requested_seconds": 10,
                 "elapsed_seconds": 10.1, "interrupted": False, "total": 100, "success": 100,
                 "http_failures": 0, "transport_failures": 0, "latency_bins": [100], "rps": 100 / 10.1}
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "result.partial"
            path.write_text("")
            with self.assertRaises(json.JSONDecodeError): validate(path, "fast", 1, 10)
            path.write_text(json.dumps(value))
            self.assertEqual(validate(path, "fast", 1, 10)["total"], 100)
            for field, wrong in [("rps", 10), ("success", 99), ("workers", 2), ("interrupted", True)]:
                path.write_text(json.dumps({**value, field: wrong}))
                with self.assertRaises(AssertionError): validate(path, "fast", 1, 10)


if __name__ == "__main__": unittest.main()
