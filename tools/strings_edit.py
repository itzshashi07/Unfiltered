#!/usr/bin/env python3
"""Adds or replaces UI strings in lib/core/strings.dart without hand-editing.

  python3 tools/strings_edit.py strings.json

strings.json: {"key": ["English", "हिन्दी", "Hinglish"], ...}. Existing keys are replaced in place;
new keys are appended at the end of the table. Run `dart format lib/core/strings.dart` afterwards.
"""
import json, re, sys

PATH = __import__("os").path.join(__import__("os").path.dirname(__import__("os").path.abspath(__file__)), "..", "lib", "core", "strings.dart")


def dart(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def main():
    data = json.load(open(sys.argv[1], encoding="utf-8"))
    src = open(PATH, encoding="utf-8").read()
    added = replaced = 0
    for key, vals in data.items():
        assert isinstance(vals, list) and len(vals) == 3 and all(isinstance(v, str) and v.strip() for v in vals), key
        entry = f"    '{key}': [{', '.join(dart(v) for v in vals)}],\n"
        pat = re.compile(r"^    '" + re.escape(key) + r"': \[.*?\],\n", re.S | re.M)
        if pat.search(src):
            src = pat.sub(lambda m: entry, src, count=1)
            replaced += 1
        else:
            end = src.rindex("  };")
            src = src[:end] + entry + src[end:]
            added += 1
    open(PATH, "w", encoding="utf-8").write(src)
    print(f"strings: {added} added, {replaced} replaced")


if __name__ == "__main__":
    main()
