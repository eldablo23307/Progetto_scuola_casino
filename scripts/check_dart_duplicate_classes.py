#!/usr/bin/env python3
"""Fail when a Dart file declares the same class name more than once.

This lightweight regression check catches accidental copy/paste duplication in
large Flutter files, such as declaring `GamePlayPage` or companion widgets twice
inside `lib/main.dart`.
"""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path

CLASS_PATTERN = re.compile(r"^\s*class\s+([A-Za-z_]\w*)\b")


def find_duplicate_classes(path: Path) -> dict[str, list[int]]:
    declarations: dict[str, list[int]] = defaultdict(list)
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        match = CLASS_PATTERN.match(line)
        if match:
            declarations[match.group(1)].append(line_number)
    return {class_name: lines for class_name, lines in declarations.items() if len(lines) > 1}


def main() -> int:
    dart_files = [Path(argument) for argument in sys.argv[1:]] or sorted(Path("frontend/lib").rglob("*.dart"))
    failures: list[str] = []

    for dart_file in dart_files:
        duplicates = find_duplicate_classes(dart_file)
        for class_name, lines in duplicates.items():
            failures.append(f"{dart_file}: duplicate class {class_name} at lines {', '.join(map(str, lines))}")

    if failures:
        print("Duplicate Dart class declarations found:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print(f"Checked {len(dart_files)} Dart file(s): no duplicate class declarations found.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
