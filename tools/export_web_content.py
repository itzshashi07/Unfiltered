#!/usr/bin/env python3
"""Copy the website's published content into the app as offline content packs.

    python3 tools/export_web_content.py [--website ../website] [--no-photos]

Reads the website (sibling folder `website/`): only stories listed in website/research/published.json
(the ones that passed the fact-check stage) are exported, in English and Hinglish.

Writes:
  assets/content/magazine/sections.json        13 sections
  assets/content/magazine/index.json           one entry per story (title, dek, cover, key numbers, ...)
  assets/content/magazine/stories/<sec>.json   {slug: {"en": markdown, "hg": markdown}} per section
  assets/content/magazine/sources.json         {id: {title, publisher, year, url}} for every cited source
  assets/content/magazine/photos.json          photo credits and alt text
  assets/content/magazine/datadesk.json        the verified facts bank, grouped by area
  assets/content/magazine/stats.json           headline numbers and the ticker
  assets/images/photos/<id>.webp               documentary photos, resized for phones
"""
import glob, json, os, re, shutil, subprocess, sys

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = sys.argv[1:]
WEB = os.path.abspath(args[args.index("--website") + 1]) if "--website" in args else os.path.join(APP, "website")
OUT = os.path.join(APP, "assets", "content", "magazine")
IMG = os.path.join(APP, "assets", "images", "photos")
DEVA = re.compile(r"[ऀ-ॿ]")


def lj(*p):
    with open(os.path.join(WEB, *p), encoding="utf-8") as f:
        return json.load(f)


def l2(o):
    """English + Hinglish only."""
    if isinstance(o, dict):
        return {"en": o.get("en", ""), "hg": o.get("hg") or o.get("en", "")}
    return {"en": o or "", "hg": o or ""}


_FM = {}


def load_front_matter(paths):
    """Parse YAML front matter with the website's own js-yaml (no Python YAML dependency)."""
    js = ("const y=require(process.argv[1]);const fs=require('fs');const out={};"
          "for(const p of JSON.parse(fs.readFileSync(0,'utf8'))){const r=fs.readFileSync(p,'utf8');"
          "const m=r.match(/^---\\n([\\s\\S]*?)\\n---\\n?([\\s\\S]*)$/);"
          "if(!m)throw new Error('no front matter: '+p);"
          "out[p]=[y.load(m[1],{schema:y.JSON_SCHEMA})||{},m[2].trim()];}"
          "process.stdout.write(JSON.stringify(out));")
    res = subprocess.run(["node", "-e", js, os.path.join(WEB, "node_modules", "js-yaml")],
                         input=json.dumps(paths), capture_output=True, text=True, check=True)
    _FM.update(json.loads(res.stdout))


def front_matter(path):
    return _FM[path]


def write(name, data):
    p = os.path.join(OUT, name)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    return p


def main():
    published = lj("research", "published.json")
    sections = lj("src", "data", "sections.json")
    sec_keys = [s["key"] for s in sections]
    shutil.rmtree(OUT, ignore_errors=True)
    os.makedirs(OUT)

    write("sections.json", [
        {"key": s["key"], "accent": s["accent"], "motif": s.get("motif", ""), "title": l2(s["title"]),
         "tagline": l2(s.get("tagline", {}))}
        for s in sections
    ])

    index, bodies, cited, used_photos = [], {k: {} for k in sec_keys}, set(), set()
    load_front_matter([os.path.join(WEB, "src", "content", "magazine", l, f"{s}.md") for s in published for l in ("en", "hg")])
    for slug in published:
        en, en_body = front_matter(os.path.join(WEB, "src", "content", "magazine", "en", f"{slug}.md"))
        hg, hg_body = front_matter(os.path.join(WEB, "src", "content", "magazine", "hg", f"{slug}.md"))
        sec = en["section"]
        cover = en.get("cover") or {}
        hcover = hg.get("cover") or {}
        photo = cover.get("photo") or ""
        if photo:
            used_photos.add(photo)
        key_numbers = []
        for i, k in enumerate(en.get("keyNumbers") or []):
            hk = (hg.get("keyNumbers") or [])[i] if i < len(hg.get("keyNumbers") or []) else {}
            key_numbers.append({"value": str(k["value"]), "label": {"en": k["label"], "hg": hk.get("label", k["label"])},
                                "source": k.get("source", "")})
        myth = None
        if en.get("myth"):
            hm = hg.get("myth") or {}
            myth = {"claim": {"en": en["myth"]["claim"], "hg": hm.get("claim", en["myth"]["claim"])},
                    "truth": {"en": en["myth"]["truth"], "hg": hm.get("truth", en["myth"]["truth"])}}
        actions_en, actions_hg = en.get("actions") or [], hg.get("actions") or []
        entry = {
            "slug": slug, "section": sec, "format": en["format"], "date": str(en["date"]),
            "minutes": en.get("minutes", 5), "minAge": en.get("minAge", 16),
            "title": {"en": en["title"], "hg": hg["title"]},
            "dek": {"en": en["dek"], "hg": hg["dek"]},
            "cw": en.get("cw") or [], "tags": en.get("tags") or [],
            "cover": {"motif": cover.get("motif", ""), "photo": photo,
                      "stat": str(cover.get("stat", "") or ""),
                      "statLabel": {"en": cover.get("statLabel", "") or "",
                                    "hg": hcover.get("statLabel", "") or cover.get("statLabel", "") or ""}},
            "keyNumbers": key_numbers,
            "myth": myth,
            "actions": [{"en": a, "hg": actions_hg[i] if i < len(actions_hg) else a} for i, a in enumerate(actions_en)],
            "sources": en.get("sources") or [],
            "related": en.get("related") or [],
            "featured": bool(en.get("featured")),
        }
        if en.get("year"):
            entry["year"] = en["year"]
        index.append(entry)
        bodies[sec][slug] = {"en": en_body, "hg": hg_body}
        cited.update(entry["sources"])
        cited.update(re.findall(r"\[\[([a-z0-9][a-z0-9-]*)\]\]", en_body + hg_body))
        for k in key_numbers:
            if k["source"]:
                cited.add(k["source"])

    order = {k: i for i, k in enumerate(sec_keys)}
    index.sort(key=lambda e: (order.get(e["section"], 99), not e["featured"], e["slug"]))
    write("index.json", index)
    for k, v in bodies.items():
        write(f"stories/{k}.json", v)

    # sources: the website registry plus the app's own reference list
    reg = {s["id"]: s for s in lj("src", "data", "sources.json")}
    try:
        for r in lj("src", "data", "app", "references.json"):
            reg.setdefault(r["id"], {"id": r["id"], "title": r.get("title") or r.get("name") or r["id"],
                                     "publisher": r.get("publisher", ""), "year": r.get("year"), "url": r.get("url", "")})
    except FileNotFoundError:
        pass
    sources = {}
    missing = sorted(i for i in cited if i not in reg)
    for i in sorted(cited):
        if i in reg:
            s = reg[i]
            sources[i] = {"title": s.get("title", i), "publisher": s.get("publisher", ""),
                          "year": s.get("year"), "url": s.get("url", "")}
    write("sources.json", sources)

    # Data Desk: verified and corrected facts, English + Hinglish
    titles = {
        'ncrb-sexual-violence': ('Rape and sexual violence: national data', 'Rape aur sexual violence: national data'),
        'ncrb-states-cities': ('States and cities', 'States aur cities'),
        'law-framework': ('The law', 'Law'),
        'landmark-cases': ('Landmark cases and judgments', 'Landmark cases aur judgments'),
        'abortion-repro': ('Abortion and reproductive rights', 'Abortion aur reproductive rights'),
        'child-protection': ('Children, POCSO and child marriage', 'Bachche, POCSO aur child marriage'),
        'domestic-dowry': ('Domestic violence and dowry', 'Domestic violence aur dowry'),
        'digital-crimes': ('Online sexual crimes', 'Online sexual crimes'),
        'sexual-health': ('Sexual and reproductive health', 'Sexual aur reproductive health'),
        'gender-lgbtq-mental': ('Gender, LGBTQ+ rights and mental health', 'Gender, LGBTQ+ rights aur mental health'),
        'workplace-public': ('Harassment at work and in public', 'Workplace aur public mein harassment'),
        'society-education': ('Sex education and society', 'Sex education aur society'),
        'global-context': ('India in the world', 'Duniya mein India'),
    }
    tr = {}
    for p in glob.glob(os.path.join(WEB, "research", "facts_i18n", "*.json")):
        tr.update(json.load(open(p, encoding="utf-8")))
    norm = lambda s: re.sub(r"\s+", " ", s or "").strip()
    areas, seen, fact_sources = [], set(), set()
    for key in titles:
        p = os.path.join(WEB, "research", "facts", f"{key}.json")
        if not os.path.exists(p):
            continue
        facts = []
        for f in json.load(open(p, encoding="utf-8")).get("facts", []):
            if f.get("status") not in ("verified", "corrected") or f["id"] in seen:
                continue
            seen.add(f["id"])
            t = tr.get(f["id"]) or {}
            hg = t.get("hg") if t.get("hg") and (not t.get("en") or norm(t["en"]) == norm(f["statement"])) else ""
            facts.append({"id": f["id"], "text": {"en": f["statement"], "hg": hg or f["statement"]},
                          "value": str(f.get("value") or ""), "year": f.get("year"),
                          "source": f.get("source", ""), "caveat": f.get("caveat") or ""})
            fact_sources.add(f.get("source", ""))
        if facts:
            areas.append({"key": key, "title": {"en": titles[key][0], "hg": titles[key][1]}, "facts": facts})
    write("datadesk.json", areas)
    for i in sorted(fact_sources - set(sources)):
        if i in reg:
            s = reg[i]
            sources[i] = {"title": s.get("title", i), "publisher": s.get("publisher", ""),
                          "year": s.get("year"), "url": s.get("url", "")}
    write("sources.json", sources)

    st = lj("src", "data", "stats.json")
    write("stats.json", {
        "stats": [{"value": s["value"], "label": l2(s["label"]), "source": s.get("source", "")} for s in st.get("stats", [])],
        "ticker": [{"text": l2(t["text"]), "source": t.get("source", "")} for t in st.get("ticker", [])],
    })

    # photos: credits + resized webp
    photos = {p["id"]: p for p in lj("src", "data", "photos.json")}
    meta = {}
    for pid in sorted(used_photos):
        p = photos.get(pid)
        if not p:
            continue
        meta[pid] = {"author": p.get("author", ""), "license": p.get("license", ""), "sourceUrl": p.get("sourceUrl", ""),
                     "alt": l2(p.get("alt", {}))}
    write("photos.json", meta)
    if "--no-photos" not in args:
        os.makedirs(IMG, exist_ok=True)
        for f in glob.glob(os.path.join(IMG, "*.webp")):
            if os.path.basename(f)[:-5] not in meta:
                os.remove(f)
        for pid in meta:
            src = os.path.join(WEB, "src", "assets", "photos", photos[pid]["file"])
            dst = os.path.join(IMG, f"{pid}.webp")
            if os.path.exists(dst) and os.path.getmtime(dst) > os.path.getmtime(src):
                continue
            subprocess.run(["cwebp", "-quiet", "-q", "62", "-resize", "900", "0", "-metadata", "none", src, "-o", dst],
                           check=True)

    # Test Your Knowledge: the website's question bank (src/data/knowledge/<topic>.json), one file in the app
    kdir = os.path.join(WEB, "src", "data", "knowledge")
    kout = os.path.join(APP, "assets", "content", "knowledge")
    bank = []
    if os.path.isdir(kdir):
        for f in sorted(glob.glob(os.path.join(kdir, "*.json"))):
            if not re.fullmatch(r"[a-z]+(-\d+)?\.json", os.path.basename(f)):
                continue  # drafts and scratch files
            for q in json.load(open(f, encoding="utf-8")):
                bank.append({"id": q["id"], "cat": q["cat"], "tracks": q["tracks"], "level": q["level"],
                             "q": l2(q["q"]), "options": [l2(o) for o in q["options"]], "answer": q["answer"],
                             "explain": l2(q["explain"])})
        os.makedirs(kout, exist_ok=True)
        with open(os.path.join(kout, "bank.json"), "w", encoding="utf-8") as fh:
            json.dump(bank, fh, ensure_ascii=False, separators=(",", ":"))
        if DEVA.search(json.dumps(bank, ensure_ascii=False)):
            sys.exit("Devanagari found in the knowledge bank")
    print(f"knowledge questions {len(bank)}")

    # nothing in Hindi ships with the app
    # (photo credits keep each photographer's name as published: the licence requires it)
    for p in glob.glob(os.path.join(OUT, "**", "*.json"), recursive=True):
        data = json.load(open(p, encoding="utf-8"))
        if p.endswith("photos.json"):
            data = {k: v["alt"] for k, v in data.items()}
        if DEVA.search(json.dumps(data, ensure_ascii=False)):
            sys.exit(f"Devanagari found in {p}")
    size = sum(os.path.getsize(p) for p in glob.glob(os.path.join(OUT, "**", "*.json"), recursive=True))
    img = sum(os.path.getsize(p) for p in glob.glob(os.path.join(IMG, "*.webp")))
    print(f"stories {len(index)}; sources {len(sources)} (missing {len(missing)}: {missing[:5]}); "
          f"data desk {sum(len(a['facts']) for a in areas)} facts in {len(areas)} areas; photos {len(meta)}; "
          f"json {size / 1e6:.1f} MB, photos {img / 1e6:.1f} MB")


if __name__ == "__main__":
    main()
