import tempfile
import unittest
from pathlib import Path

from check_docs import check_document, local_links


class DocumentationLinks(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name).resolve()
        self.document = self.root / "guide.md"

    def check(self, text):
        self.document.write_text(text, encoding="utf-8")
        return check_document(self.root, self.document)

    def test_existing_encoded_file_and_anchor(self):
        (self.root / "target file.md").write_text("# Target")
        self.assertEqual(self.check("[target](target%20file.md#target)"), [])

    def test_missing_link_fails(self):
        self.assertEqual(len(self.check("[target](missing.md)")), 1)

    def test_external_urls_and_local_anchors_do_not_require_network(self):
        self.assertEqual(self.check("[web](https://example.invalid/a) [anchor](#x)"), [])

    def test_code_fences_are_not_document_links(self):
        text = "```markdown\n[example](missing.md)\n```\n[real](guide.md)"
        self.assertEqual(list(local_links(text)), ["guide.md"])
        self.assertEqual(self.check(text), [])

    def test_inline_code_examples_are_not_document_links(self):
        text = "Example: `![alt](/images/name.webp)` and ``[example](missing.md)``."
        self.assertEqual(self.check(text), [])

    def test_parent_and_symlink_escape_fail(self):
        self.assertEqual(len(self.check("[escape](../outside.md)")), 1)
        (self.root / "outside").symlink_to(self.root.parent, target_is_directory=True)
        self.assertEqual(len(self.check("[escape](outside/file.md)")), 1)


if __name__ == "__main__":
    unittest.main()
