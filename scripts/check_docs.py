"""Check local links in maintained entry and guide documents, without network access."""

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit

ENTRY_FILES = ("AGENTS.md", "CLAUDE.md", "README.md", "ARCHITECTURE.md", "docs/README.md")
# shortcut: inline links only; use a Markdown parser if maintained docs adopt reference links.
LINK = re.compile(r'!?\[[^\]\n]*\]\((<[^>\n]+>|[^\s)]+)(?:\s+"[^"]*")?\)')
FENCE = re.compile(r"^(`{3,}|~{3,}).*$", re.MULTILINE)
INLINE_CODE = re.compile(r"(`+).*?\1")


def local_links(text):
    fence = None
    for line in text.splitlines():
        marker = FENCE.match(line)
        if marker:
            token = marker.group(1)
            if fence is None:
                fence = token
            elif token[0] == fence[0] and len(token) >= len(fence):
                fence = None
            continue
        if fence is None:
            line = INLINE_CODE.sub("", line)
            yield from (match.group(1).strip("<>") for match in LINK.finditer(line))


def check_document(root, document):
    errors = []
    for link in local_links(document.read_text(encoding="utf-8")):
        url = urlsplit(link)
        if url.scheme or url.netloc or not url.path:
            continue
        target = (document.parent / unquote(url.path)).resolve()
        if not target.is_relative_to(root):
            errors.append(f"{document.relative_to(root)}: outside repository: {link}")
        elif not target.exists():
            errors.append(f"{document.relative_to(root)}: missing target: {link}")
    return errors


def main():
    root = Path(__file__).resolve().parent.parent
    documents = [root / name for name in ENTRY_FILES]
    documents.extend(sorted((root / "docs/guides").glob("*.md")))
    errors = []
    for document in documents:
        if not document.is_file():
            errors.append(f"missing entry document: {document.relative_to(root)}")
        else:
            errors.extend(check_document(root, document))
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"PASS: local file links in {len(documents)} maintained documents")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
