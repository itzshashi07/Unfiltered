#!/usr/bin/env python3
"""Applies precise edits to content JSON without hand-editing the files.

  python3 tools/patch_content.py patches.json [--dry-run]

patches.json is a list of operations:
  {"kind": "lessons", "domain": "d10", "id": "d10-l06", "path": "sections[2].body.hg", "value": "new text"}
  {"kind": "faqs", "domain": "d10", "id": "d10-f13", "path": "tracks", "value": ["D", "E"]}
  {"kind": "myths", "domain": "d10", "op": "append", "item": {...full new item...}}
  {"kind": "faqs", "domain": "d10", "op": "delete", "id": "d10-f99"}

`kind` is lessons | faqs | myths | quiz | glossary | scenarios | visuals. `path` uses the field paths printed
by tools/show_content.py. A path must already exist (pass "create": true to add a new key).
For visuals files the item id is its "lesson" value. All operations are checked before anything is written.
"""
import copy, json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "content")
# --root DIR works on a copy of assets/content (for checking patches before they reach the project).
if "--root" in sys.argv:
    ROOT = sys.argv[sys.argv.index("--root") + 1]
TOKEN = re.compile(r"([^\.\[\]]+)|\[(\d+)\]")


def parse(path):
    out = []
    for name, idx in TOKEN.findall(path):
        out.append(name if name else int(idx))
    if not out:
        raise ValueError(f"empty path {path!r}")
    return out


def set_path(item, path, value, create):
    keys = parse(path)
    cur = item
    for k in keys[:-1]:
        if isinstance(k, int):
            if not isinstance(cur, list) or k >= len(cur):
                raise KeyError(f"index [{k}] not found in {path}")
            cur = cur[k]
        else:
            if not isinstance(cur, dict) or k not in cur:
                raise KeyError(f"key {k!r} not found in {path}")
            cur = cur[k]
    last = keys[-1]
    if isinstance(last, int):
        if not isinstance(cur, list) or last >= len(cur):
            raise KeyError(f"index [{last}] not found in {path}")
        cur[last] = value
    else:
        if not isinstance(cur, dict) or (last not in cur and not create):
            raise KeyError(f"key {last!r} not found in {path} (use create:true to add it)")
        cur[last] = value


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    dry = "--dry-run" in sys.argv
    patches = json.load(open(sys.argv[1], encoding="utf-8"))
    files, errors = {}, []
    for n, p in enumerate(patches):
        try:
            f = os.path.join(ROOT, p["kind"], f"{p['domain']}.json")
            if f not in files:
                files[f] = json.load(open(f, encoding="utf-8")) if os.path.exists(f) else []
            data = files[f]
            op = p.get("op", "set")
            key = (lambda it: it.get("id") or it.get("lesson"))
            if op == "append":
                iid = key(p["item"])
                if any(key(it) == iid for it in data):
                    raise KeyError(f"id {iid} already exists")
                data.append(copy.deepcopy(p["item"]))
            elif op == "delete":
                before = len(data)
                data[:] = [it for it in data if key(it) != p["id"]]
                if len(data) == before:
                    raise KeyError(f"id {p['id']} not found")
            else:
                hit = [it for it in data if key(it) == p["id"]]
                if len(hit) != 1:
                    raise KeyError(f"id {p['id']} matched {len(hit)} items")
                set_path(hit[0], p["path"], p["value"], p.get("create", False))
        except Exception as e:  # noqa: BLE001 - report every bad patch together
            errors.append(f"patch #{n}: {type(e).__name__}: {e}")
    if errors:
        print("NOTHING WRITTEN. Errors:")
        for e in errors:
            print("  -", e)
        return 1
    if not dry:
        for f, data in files.items():
            os.makedirs(os.path.dirname(f), exist_ok=True)
            with open(f, "w", encoding="utf-8") as fh:
                json.dump(data, fh, ensure_ascii=False, indent=1)
                fh.write("\n")
    print(f"{'would apply' if dry else 'applied'} {len(patches)} patch(es) to {len(files)} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
