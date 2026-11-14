#!/usr/bin/env python3
"""Prints curriculum items as readable text with field paths, for reviewers.

  python3 tools/show_content.py d10                      # everything in a domain, English
  python3 tools/show_content.py d10 --lang all           # en / hi / hg side by side
  python3 tools/show_content.py d10 --kind lessons,faqs  # only some kinds
  python3 tools/show_content.py d10 --ids d10-l06,d10-f13
  python3 tools/show_content.py extras --lang en         # labs.json and social.json

Field paths printed here (e.g. `sections[2].body`) are the paths tools/patch_content.py accepts.
"""
import argparse, json, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "content")
KINDS = ["lessons", "faqs", "myths", "quiz", "glossary", "scenarios", "visuals"]


def is_l(v):
    return isinstance(v, dict) and set(v.keys()) >= {"en", "hi", "hg"} and all(isinstance(v[k], str) for k in ("en", "hi", "hg"))


def emit(path, v, lang, out):
    if is_l(v):
        if lang == "all":
            out.append(f"{path}:")
            for k in ("en", "hi", "hg"):
                out.append(f"    [{k}] {v[k]}")
        else:
            out.append(f"{path}: {v[lang]}")
    elif isinstance(v, dict):
        for k, x in v.items():
            emit(f"{path}.{k}" if path else k, x, lang, out)
    elif isinstance(v, list):
        if all(not isinstance(x, (dict, list)) for x in v):
            out.append(f"{path}: {json.dumps(v, ensure_ascii=False)}")
        else:
            for i, x in enumerate(v):
                emit(f"{path}[{i}]", x, lang, out)
    else:
        out.append(f"{path}: {json.dumps(v, ensure_ascii=False)}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("domain")
    ap.add_argument("--kind", default=",".join(KINDS))
    ap.add_argument("--lang", default="en", choices=["en", "hi", "hg", "all"])
    ap.add_argument("--ids", default="")
    a = ap.parse_args()
    ids = {i for i in a.ids.split(",") if i}
    out = []
    if a.domain == "extras":
        for name in ("labs", "social"):
            data = json.load(open(os.path.join(ROOT, "extras", f"{name}.json"), encoding="utf-8"))
            out.append(f"\n######## extras/{name}.json")
            emit("", data, a.lang, out)
        print("\n".join(out))
        return
    for kind in a.kind.split(","):
        p = os.path.join(ROOT, kind, f"{a.domain}.json")
        if not os.path.exists(p):
            continue
        for item in json.load(open(p, encoding="utf-8")):
            iid = item.get("id") or item.get("lesson")
            if ids and iid not in ids:
                continue
            out.append(f"\n######## {kind}/{a.domain}.json  id={iid}")
            emit("", {k: v for k, v in item.items() if k != "id"}, a.lang, out)
    print("\n".join(out))


if __name__ == "__main__":
    main()
