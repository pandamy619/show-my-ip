#!/usr/bin/env python3
"""Checks that the project version matches the release tag and prints its CHANGELOG section."""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "ShowMyIP.xcodeproj" / "project.pbxproj"
CHANGELOG = ROOT / "CHANGELOG.md"
VERSION_PATTERN = re.compile(r"^\d+\.\d+\.\d+$")


def project_versions():
    return set(re.findall(r"MARKETING_VERSION = ([^;]+);", PROJECT.read_text(encoding="utf-8")))


def release_notes(version):
    lines = CHANGELOG.read_text(encoding="utf-8").splitlines()
    heading = re.compile(rf"^## \[{re.escape(version)}\]")
    start = next((index for index, line in enumerate(lines) if heading.match(line)), None)
    if start is None:
        return None
    end = next((index for index in range(start + 1, len(lines)) if lines[index].startswith("## ")), len(lines))
    return "\n".join(lines[start + 1 : end]).strip()


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: prepare_release.py <tag>")
    version = sys.argv[1].removeprefix("v")
    if not VERSION_PATTERN.match(version):
        sys.exit(f"tag {sys.argv[1]!r} is not vX.Y.Z")
    versions = project_versions()
    if versions != {version}:
        sys.exit(f"project version {sorted(versions)} does not match tag {version}")
    notes = release_notes(version)
    if not notes:
        sys.exit(f"CHANGELOG.md has no section for {version}")
    print(notes)


if __name__ == "__main__":
    main()
