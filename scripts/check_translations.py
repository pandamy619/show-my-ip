#!/usr/bin/env python3
"""Fails when a string in the catalog lacks a Russian translation or loses a placeholder."""

import json
import re
import sys
from pathlib import Path

CATALOG = Path(__file__).resolve().parent.parent / "ShowMyIP" / "Localizable.xcstrings"
PLACEHOLDER = re.compile(r"%(?:\d+\$)?(?:@|lld|ld|d|f)")


def problems(catalog):
    for key, entry in sorted(catalog["strings"].items()):
        if entry.get("shouldTranslate") is False:
            continue
        unit = entry.get("localizations", {}).get("ru", {}).get("stringUnit", {})
        value = unit.get("value", "")
        if unit.get("state") != "translated" or not value:
            yield f"missing Russian translation: {key!r}"
        elif len(PLACEHOLDER.findall(key)) != len(PLACEHOLDER.findall(value)):
            yield f"placeholder mismatch: {key!r}"


def main():
    found = list(problems(json.loads(CATALOG.read_text(encoding="utf-8"))))
    for problem in found:
        print(problem, file=sys.stderr)
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main())
