#!/usr/bin/env python3
"""Validates UNFILTERED content packs against docs/CONTENT_SCHEMA.md.

Usage:
  python3 tools/validate_content.py              # validate everything, print coverage
  python3 tools/validate_content.py --domain d03 # validate one domain's files only
Exit code 0 = OK, 1 = errors.
"""
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "content")
# --root DIR works on a copy of assets/content (for checking patches before they reach the project).
if "--root" in sys.argv:
    ROOT = sys.argv[sys.argv.index("--root") + 1]
TRACKS = ["A", "B", "C", "D", "E"]
ALLOWED = {
    "d01": "ABCDE", "d02": "BCDE", "d03": "BCDE", "d04": "BCDE", "d05": "ABCDE", "d06": "ABCDE",
    "d07": "CDE", "d08": "CDE", "d09": "CDE", "d10": "BCDE", "d11": "ABCDE", "d12": "BCDE",
    "d13": "ABCDE", "d14": "ABCDE", "d15": "BCDE", "d16": "BCDE", "d17": "ABCDE", "d18": "ABCDE",
}
SLOTS = {
    "d01": ["A", "B", "C", "CD", "DE", "CDE"], "d02": ["B", "B", "B", "C", "C", "CDE"],
    "d03": ["B", "B", "C", "CD", "DE", "CDE"], "d04": ["B", "B", "C", "C", "D", "E", "E"],
    "d05": ["A", "B", "C", "D", "E", "CDE"], "d06": ["A", "B", "C", "D", "E", "CDE", "E"],
    "d07": ["C", "D", "D", "E", "E"], "d08": ["C", "D", "D", "E", "E", "DE"],
    "d09": ["C", "D", "D", "E", "DE"], "d10": ["B", "C", "D", "E", "E", "DE", "DE", "E"],
    "d11": ["A", "B", "C", "DE", "CDE", "DE"], "d12": ["B", "C", "D", "E", "CDE", "E"],
    "d13": ["A", "B", "C", "D", "DE", "CDE"], "d14": ["A", "A", "B", "C", "DE", "CDE", "DE", "DE", "E"],
    "d15": ["B", "C", "CD", "DE", "E"], "d16": ["B", "C", "D", "E", "CDE", "DE"],
    "d17": ["A", "B", "C", "D", "E", "DE"], "d18": ["A", "B", "C", "DE", "CDE"],
}
SCENARIOS = {
    "d05": ("consent", ["A", "B", "C", "D", "E"]),
    "d06": ("relationship", ["B", "C", "D", "E", "CDE"]),
    "d12": ("digital", ["C", "DE"]),
    "d13": ("digital", ["A", "B", "C", "D", "CDE"]),
    "d14": ("consent", ["A", "B", "CDE"]),
    "d17": ("communication", ["C", "DE"]),
    "d18": ("communication", ["A", "B", "C", "DE"]),
}
INTERACTIVE = {None, "body_lab", "puberty_lab", "period_lab", "myth_buster", "consent_sim",
               "relationship_radar", "protection_lab", "digital_safety", "sti_match",
               "support_circle", "communication", "ask"}
DEVA = re.compile(r"[ऀ-ॿ]")
AUDIENCE = {"men", "women", "trans_nb", "intersex", "everyone"}
BODY = {"penis_testicular", "vulva_vaginal", "menstrual", "pregnancy_repro", "hormones_changes"}
LABS = INTERACTIVE - {None, "ask"}
SCREENS = {"safety", "parents", "teacher"}
REQUIRE_TOPICS = "--require-topics" in sys.argv
REQUIRE_VISUALS = "--require-visuals" in sys.argv
ICONS = set()
errors = []
warnings = []


def err(where, msg):
    errors.append(f"{where}: {msg}")


def load(path):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return None
    except json.JSONDecodeError as e:
        err(os.path.relpath(path, ROOT), f"invalid JSON: {e}")
        return None


def words(s):
    return len(s.split())


def check_l(where, v, min_en_words=1, max_en_words=None):
    if not isinstance(v, dict):
        err(where, "expected localized object {en,hg}")
        return
    for k in ("en", "hg"):
        s = v.get(k)
        if not isinstance(s, str) or not s.strip():
            err(where, f"missing/empty '{k}'")
            return
        if "\n" in s:
            err(where, f"'{k}' contains a newline")
    extra = set(v.keys()) - {"en", "hg"}
    if extra:
        err(where, f"unexpected keys {sorted(extra)}")
    if DEVA.search(v["hg"]):
        err(where, "'hg' (Hinglish) must be Roman script, found Devanagari")
    if DEVA.search(v["en"]):
        err(where, "'en' contains Devanagari")
    n = words(v["en"])
    if n < min_en_words:
        err(where, f"'en' too short ({n} words, need >= {min_en_words})")
    if max_en_words and n > max_en_words:
        err(where, f"'en' too long ({n} words, max {max_en_words})")
    # Hinglish must not be drastically thinner than English
    if n >= 20:
        for k in ("hg",):
            if words(v[k]) < n * 0.55:
                err(where, f"'{k}' looks much shorter than 'en' ({words(v[k])} vs {n} words)")


def check_tracks(where, tracks, domain):
    if not isinstance(tracks, list) or not tracks:
        err(where, "tracks must be a non-empty list")
        return ""
    for t in tracks:
        if t not in TRACKS:
            err(where, f"bad track {t!r}")
        elif t not in ALLOWED.get(domain, ""):
            err(where, f"track {t} is not allowed for domain {domain}")
    if len(set(tracks)) != len(tracks):
        err(where, "duplicate tracks")
    return "".join(sorted(set(tracks)))


def check_topics(where, item, tr):
    """Explicit "Topics I want to explore" tags: who an item is about, and body topics."""
    if "audience" not in item and "body" not in item:
        if REQUIRE_TOPICS:
            err(where, "missing topic tags: audience and body")
        return
    a, b = item.get("audience"), item.get("body")
    if not isinstance(a, list) or not a or any(x not in AUDIENCE for x in a) or len(set(a)) != len(a):
        err(where, f"audience must be a non-empty list drawn from {sorted(AUDIENCE)}")
    if not isinstance(b, list) or any(x not in BODY for x in b) or len(set(b)) != len(b):
        err(where, f"body must be a list (possibly empty) drawn from {sorted(BODY)}")
    if "A" in tr and (a != ["everyone"] or b):
        err(where, "items shown to track A must be tagged audience ['everyone'] and body []")


def check_refs(where, refs, ref_ids):
    if not isinstance(refs, list) or not refs:
        err(where, "refs must list at least one reference id")
        return
    for r in refs:
        if r not in ref_ids:
            err(where, f"unknown reference id {r!r}")


def check_quiz_q(where, q, min_track_a=False):
    if q.get("type") not in ("mcq", "tf", "scenario"):
        err(where, f"bad quiz type {q.get('type')!r}")
    check_l(where + ".q", q.get("q"), 3)
    opts = q.get("options")
    if not isinstance(opts, list):
        err(where, "options must be a list")
        return
    n = len(opts)
    if q.get("type") == "tf" and n != 2:
        err(where, "tf questions need exactly 2 options")
    if q.get("type") in ("mcq", "scenario") and not 3 <= n <= 4:
        err(where, "mcq/scenario questions need 3-4 options")
    for i, o in enumerate(opts):
        check_l(f"{where}.options[{i}]", o)
    a = q.get("answer")
    if not isinstance(a, int) or isinstance(a, bool) or not 0 <= a < n:
        err(where, f"answer index {a!r} out of range")
    check_l(where + ".explain", q.get("explain"), 5)


def main():
    only = None
    if "--domain" in sys.argv:
        only = sys.argv[sys.argv.index("--domain") + 1]
    domains = load(os.path.join(ROOT, "domains.json")) or []
    refs = load(os.path.join(ROOT, "references.json")) or []
    ref_ids = {r["id"] for r in refs}
    dom_ids = [d["id"] for d in domains]
    if len(dom_ids) != 18:
        err("domains.json", f"expected 18 domains, found {len(dom_ids)}")
    for d in domains:
        check_l(f"domains.{d['id']}.title", d.get("title"))
        check_l(f"domains.{d['id']}.tagline", d.get("tagline"))
    for r in refs:
        for k in ("id", "title", "publisher", "category", "url"):
            if not r.get(k):
                err(f"references.{r.get('id')}", f"missing {k}")
        if not str(r.get("url", "")).startswith("https://"):
            err(f"references.{r.get('id')}", "url must be https")

    icon_file = load(os.path.join(ROOT, "extras", "visual_icons.json")) or {}
    ICONS.update(icon_file.get("icons", []))
    ICONS.update(icon_file.get("objects", []))

    seen = set()
    counts = {k: 0 for k in ("lessons", "faqs", "myths", "quiz_lesson", "quiz_bank", "glossary_sets",
                             "glossary_terms", "scenarios")}
    per_track = {t: 0 for t in TRACKS}
    coverage = {}
    used_refs = set()
    todo = [only] if only else dom_ids

    def uid(where, i):
        if not isinstance(i, str) or not i:
            err(where, "missing id")
            return
        if i in seen:
            err(where, f"duplicate id {i}")
        seen.add(i)

    for dom in todo:
        cov = coverage.setdefault(dom, {})
        # ---------------- lessons
        lessons = load(os.path.join(ROOT, "lessons", f"{dom}.json"))
        lesson_tracks = {}
        if lessons is None:
            err(f"lessons/{dom}.json", "file missing or unreadable")
            lessons = []
        slots = SLOTS[dom]
        if len(lessons) != len(slots):
            err(f"lessons/{dom}.json", f"expected {len(slots)} lessons, found {len(lessons)}")
        for idx, ls in enumerate(lessons):
            w = f"lessons/{dom}[{idx}]({ls.get('id')})"
            uid(w, ls.get("id"))
            if ls.get("id") != f"{dom}-l{idx + 1:02d}":
                err(w, f"id should be {dom}-l{idx + 1:02d}")
            if ls.get("domain") != dom:
                err(w, "wrong domain")
            tr = check_tracks(w, ls.get("tracks"), dom)
            if idx < len(slots) and tr != slots[idx]:
                err(w, f"tracks {tr} do not match required slot {slots[idx]}")
            lesson_tracks[ls.get("id")] = tr
            for t in tr:
                per_track[t] += 1
            is_a = tr == "A"
            if ls.get("difficulty") not in (1, 2, 3):
                err(w, "difficulty must be 1-3")
            if not isinstance(ls.get("minutes"), int) or not 3 <= ls["minutes"] <= 9:
                err(w, "minutes must be an int 3-9")
            un = ls.get("unesco")
            if not isinstance(un, list) or not un or any(u not in range(1, 9) for u in un):
                err(w, "unesco must list concepts 1-8")
            for k in ("title", "subtitle", "hook", "activity"):
                check_l(f"{w}.{k}", ls.get(k), 2 if k in ("title",) else 3)
            obj = ls.get("objectives")
            if not isinstance(obj, list) or not 2 <= len(obj) <= 3:
                err(w, "objectives: need 2-3")
            else:
                for i, o in enumerate(obj):
                    check_l(f"{w}.objectives[{i}]", o, 3)
            secs = ls.get("sections")
            if not isinstance(secs, list) or not 3 <= len(secs) <= 4:
                err(w, "sections: need 3-4")
            else:
                for i, s in enumerate(secs):
                    check_l(f"{w}.sections[{i}].h", s.get("h"))
                    check_l(f"{w}.sections[{i}].body", s.get("body"), 22 if is_a else 50, 130)
            m = ls.get("myth")
            if not isinstance(m, dict):
                err(w, "myth missing")
            else:
                check_l(f"{w}.myth.claim", m.get("claim"), 3)
                check_l(f"{w}.myth.fact", m.get("fact"), 6)
            tk = ls.get("takeaways")
            if not isinstance(tk, list) or len(tk) != 3:
                err(w, "takeaways: need exactly 3")
            else:
                for i, o in enumerate(tk):
                    check_l(f"{w}.takeaways[{i}]", o, 3)
            if ls.get("interactive") not in INTERACTIVE:
                err(w, f"bad interactive {ls.get('interactive')!r}")
            qs = ls.get("quiz")
            if not isinstance(qs, list) or len(qs) != 2:
                err(w, "quiz: need exactly 2 questions")
            else:
                for i, q in enumerate(qs):
                    uid(f"{w}.quiz[{i}]", q.get("id"))
                    check_quiz_q(f"{w}.quiz[{i}]", q)
                    counts["quiz_lesson"] += 1
            check_refs(w, ls.get("refs"), ref_ids)
            used_refs.update(ls.get("refs") or [])
            check_topics(w, ls, tr)
            if "laws" in ls:
                laws = ls["laws"]
                if not isinstance(laws, list) or not 1 <= len(laws) <= 8:
                    err(w, "laws: need 1-8 law names")
                else:
                    for i, x in enumerate(laws):
                        check_l(f"{w}.laws[{i}]", x, 2, 16)
            if ls.get("warning") is not None:
                check_l(f"{w}.warning", ls.get("warning"), 4)
            if not isinstance(ls.get("sensitive"), bool):
                err(w, "sensitive must be true/false")
            if ls.get("review") != "pending_expert_review":
                err(w, "review must be 'pending_expert_review'")
            if ls.get("revised") != "2026-11-14":
                err(w, "revised must be '2026-11-14'")
            counts["lessons"] += 1
        ids_here = {l.get("id") for l in lessons}
        for ls in lessons:
            for p in ls.get("prereqs") or []:
                if p not in ids_here:
                    err(f"lessons/{ls.get('id')}", f"prereq {p} does not exist in this domain")
                elif p == ls.get("id"):
                    err(f"lessons/{ls.get('id')}", "lesson lists itself as prereq")
                elif not set(lesson_tracks.get(p, "")) & set(lesson_tracks.get(ls.get("id"), "")):
                    err(f"lessons/{ls.get('id')}", f"prereq {p} shares no track with this lesson")
            if not isinstance(ls.get("prereqs"), list):
                err(f"lessons/{ls.get('id')}", "prereqs must be a list")
        cov["lessons"] = len(lessons)

        def lesson_link(w, item):
            l = item.get("lesson")
            if l is None:
                return
            if l not in ids_here:
                err(w, f"related lesson {l} not found in this domain")
            elif not set(lesson_tracks.get(l, "")) & set(item.get("tracks") or []):
                err(w, f"related lesson {l} shares no track with this item")

        # ---------------- faqs
        faqs = load(os.path.join(ROOT, "faqs", f"{dom}.json"))
        if faqs is None:
            err(f"faqs/{dom}.json", "file missing or unreadable")
            faqs = []
        if len(faqs) < 12:
            err(f"faqs/{dom}.json", f"need at least 12 FAQs, found {len(faqs)}")
        for idx, f in enumerate(faqs):
            w = f"faqs/{dom}[{idx}]({f.get('id')})"
            uid(w, f.get("id"))
            if f.get("domain") != dom:
                err(w, "wrong domain")
            tr = check_tracks(w, f.get("tracks"), dom)
            check_l(w + ".q", f.get("q"), 3)
            check_l(w + ".a", f.get("a"), 18 if tr == "A" else 40, 130)
            kw = f.get("keywords")
            if not isinstance(kw, list) or len(kw) < 6 or any(not isinstance(k, str) or not k.strip() for k in kw):
                err(w, "keywords: need >= 6 non-empty strings")
            check_refs(w, f.get("refs"), ref_ids)
            used_refs.update(f.get("refs") or [])
            if not isinstance(f.get("urgent"), bool):
                err(w, "urgent must be true/false")
            check_topics(w, f, tr)
            lesson_link(w, f)
            counts["faqs"] += 1
        cov["faqs"] = len(faqs)

        # ---------------- myths
        myths = load(os.path.join(ROOT, "myths", f"{dom}.json"))
        if myths is None:
            err(f"myths/{dom}.json", "file missing or unreadable")
            myths = []
        if len(myths) < 7:
            err(f"myths/{dom}.json", f"need at least 7 myth cards, found {len(myths)}")
        non_myth = 0
        for idx, m in enumerate(myths):
            w = f"myths/{dom}[{idx}]({m.get('id')})"
            uid(w, m.get("id"))
            if m.get("domain") != dom:
                err(w, "wrong domain")
            tr = check_tracks(w, m.get("tracks"), dom)
            check_l(w + ".claim", m.get("claim"), 3)
            if m.get("verdict") not in ("myth", "fact", "partly"):
                err(w, "verdict must be myth/fact/partly")
            if m.get("verdict") != "myth":
                non_myth += 1
            check_l(w + ".fact", m.get("fact"), 14 if tr == "A" else 30, 100)
            check_l(w + ".why", m.get("why"), 10, 70)
            check_refs(w, m.get("refs"), ref_ids)
            used_refs.update(m.get("refs") or [])
            check_topics(w, m, tr)
            lesson_link(w, m)
            counts["myths"] += 1
        if myths and non_myth < 1:
            err(f"myths/{dom}.json", "need at least 1 card with verdict fact/partly")
        cov["myths"] = len(myths)

        # ---------------- quiz bank
        bank = load(os.path.join(ROOT, "quiz", f"{dom}.json"))
        if bank is None:
            err(f"quiz/{dom}.json", "file missing or unreadable")
            bank = []
        if len(bank) < 6:
            err(f"quiz/{dom}.json", f"need at least 6 quiz-bank questions, found {len(bank)}")
        for idx, q in enumerate(bank):
            w = f"quiz/{dom}[{idx}]({q.get('id')})"
            uid(w, q.get("id"))
            if q.get("domain") != dom:
                err(w, "wrong domain")
            qtr = check_tracks(w, q.get("tracks"), dom)
            check_quiz_q(w, q)
            check_topics(w, q, qtr)
            counts["quiz_bank"] += 1
        cov["quiz"] = len(bank) + 2 * len(lessons)

        # ---------------- glossary
        gl = load(os.path.join(ROOT, "glossary", f"{dom}.json"))
        if gl is None:
            err(f"glossary/{dom}.json", "file missing or unreadable")
            gl = []
        if len(gl) < 2:
            err(f"glossary/{dom}.json", f"need at least 2 glossary sets, found {len(gl)}")
        for idx, g in enumerate(gl):
            w = f"glossary/{dom}[{idx}]({g.get('id')})"
            uid(w, g.get("id"))
            if g.get("domain") != dom:
                err(w, "wrong domain")
            check_tracks(w, g.get("tracks"), dom)
            check_l(w + ".title", g.get("title"))
            terms = g.get("terms")
            if not isinstance(terms, list) or len(terms) < 6:
                err(w, "need at least 6 terms")
                terms = []
            for i, t in enumerate(terms):
                check_l(f"{w}.terms[{i}].term", t.get("term"))
                check_l(f"{w}.terms[{i}].def", t.get("def"), 8, 50)
                counts["glossary_terms"] += 1
            counts["glossary_sets"] += 1
        cov["glossary"] = len(gl)

        # ---------------- at-a-glance visuals (one per lesson once a file exists)
        vis = load(os.path.join(ROOT, "visuals", f"{dom}.json"))
        if vis is None:
            if REQUIRE_VISUALS:
                err(f"visuals/{dom}.json", "file missing or unreadable")
        else:
            seen_v = set()
            for idx, v in enumerate(vis):
                lid = v.get("lesson")
                w = f"visuals/{dom}[{idx}]({lid})"
                if lid not in ids_here:
                    err(w, "lesson id not found in this domain")
                if lid in seen_v:
                    err(w, "more than one visual for this lesson")
                seen_v.add(lid)
                vt = v.get("type")
                check_l(w + ".title", v.get("title"), 2, 10)
                if vt in ("steps", "grid"):
                    items = v.get("items")
                    lo, hi = (3, 5) if vt == "steps" else (4, 6)
                    if not isinstance(items, list) or not lo <= len(items) <= hi:
                        err(w, f"{vt}: need {lo}-{hi} items")
                        items = []
                    for i, it in enumerate(items):
                        if it.get("icon") not in ICONS:
                            err(f"{w}.items[{i}]", f"unknown icon {it.get('icon')!r}")
                        check_l(f"{w}.items[{i}].label", it.get("label"), 1, 6)
                        check_l(f"{w}.items[{i}].text", it.get("text"), 4, 24)
                elif vt == "compare":
                    for side in ("left", "right"):
                        sd = v.get(side)
                        if not isinstance(sd, dict):
                            err(w, f"compare: missing {side}")
                            continue
                        check_l(f"{w}.{side}.title", sd.get("title"), 1, 5)
                        if sd.get("tone") not in ("good", "bad", "neutral"):
                            err(f"{w}.{side}", "tone must be good/bad/neutral")
                        if sd.get("icon") not in ICONS:
                            err(f"{w}.{side}", f"unknown icon {sd.get('icon')!r}")
                        pts = sd.get("points")
                        if not isinstance(pts, list) or not 2 <= len(pts) <= 4:
                            err(f"{w}.{side}", "need 2-4 points")
                            pts = []
                        for i, pt in enumerate(pts):
                            check_l(f"{w}.{side}.points[{i}]", pt, 3, 18)
                else:
                    err(w, f"type must be steps/grid/compare, got {vt!r}")
            for lid in sorted(ids_here - seen_v):
                err(f"visuals/{dom}.json", f"no visual for lesson {lid}")
            counts["visuals"] = counts.get("visuals", 0) + len(vis)

        # ---------------- scenarios
        sc = load(os.path.join(ROOT, "scenarios", f"{dom}.json"))
        if dom in SCENARIOS:
            module, sslots = SCENARIOS[dom]
            if sc is None:
                err(f"scenarios/{dom}.json", "file missing or unreadable")
                sc = []
            if len(sc) != len(sslots):
                err(f"scenarios/{dom}.json", f"expected {len(sslots)} scenarios, found {len(sc)}")
            for idx, s in enumerate(sc):
                w = f"scenarios/{dom}[{idx}]({s.get('id')})"
                uid(w, s.get("id"))
                if s.get("domain") != dom:
                    err(w, "wrong domain")
                if s.get("module") != module:
                    err(w, f"module must be {module!r}")
                tr = check_tracks(w, s.get("tracks"), dom)
                if idx < len(sslots) and tr != sslots[idx]:
                    err(w, f"tracks {tr} do not match required slot {sslots[idx]}")
                check_l(w + ".title", s.get("title"))
                check_l(w + ".intro", s.get("intro"), 6)
                check_l(w + ".debrief", s.get("debrief"), 14 if tr == "A" else 25, 90)
                if not isinstance(s.get("sensitive"), bool):
                    err(w, "sensitive must be true/false")
                check_refs(w, s.get("refs"), ref_ids)
                used_refs.update(s.get("refs") or [])
                nodes = s.get("nodes")
                if not isinstance(nodes, dict) or not 3 <= len(nodes) <= 5:
                    err(w, "nodes: need 3-5 nodes")
                    continue
                if s.get("start") not in nodes:
                    err(w, "start node missing")
                    continue
                for nid, n in nodes.items():
                    check_l(f"{w}.nodes.{nid}.text", n.get("text"), 6)
                    ch = n.get("choices")
                    if not isinstance(ch, list) or not 1 <= len(ch) <= 3:
                        err(f"{w}.nodes.{nid}", "need 1-3 choices")
                        continue
                    for ci, c in enumerate(ch):
                        cw = f"{w}.nodes.{nid}.choices[{ci}]"
                        check_l(cw + ".label", c.get("label"))
                        check_l(cw + ".feedback", c.get("feedback"), 10, 70)
                        if c.get("tone") not in ("good", "okay", "risky"):
                            err(cw, "tone must be good/okay/risky")
                        if c.get("next") is not None and c.get("next") not in nodes:
                            err(cw, f"next {c.get('next')!r} is not a node")
                    if not any(c.get("tone") == "good" for c in ch):
                        err(f"{w}.nodes.{nid}", "every node needs at least one 'good' choice")
                # reachability + termination (no cycles)
                reach, stack = set(), [s["start"]]
                while stack:
                    cur = stack.pop()
                    if cur in reach:
                        continue
                    reach.add(cur)
                    for c in nodes[cur].get("choices") or []:
                        if c.get("next") in nodes:
                            stack.append(c["next"])
                for nid in nodes:
                    if nid not in reach:
                        err(w, f"node {nid} unreachable")

                def cyclic(nid, path):
                    if nid in path:
                        return True
                    return any(cyclic(c["next"], path | {nid})
                               for c in nodes[nid].get("choices") or [] if c.get("next") in nodes)
                if cyclic(s["start"], frozenset()):
                    err(w, "scenario graph has a cycle")
                counts["scenarios"] += 1
            cov["scenarios"] = len(sc)
        elif sc:
            err(f"scenarios/{dom}.json", "this domain is not assigned scenarios")

        # each allowed track must have something in FAQs and myths
        for t in ALLOWED[dom]:
            if faqs and not any(t in (f.get("tracks") or []) for f in faqs):
                err(f"faqs/{dom}.json", f"no FAQ for track {t}")
            if myths and not any(t in (m.get("tracks") or []) for m in myths):
                err(f"myths/{dom}.json", f"no myth card for track {t}")

    # ---------------- pictures (whole-curriculum check)
    images = load(os.path.join(ROOT, "extras", "images.json"))
    if images is not None and not only:
        all_lessons = {}
        for d in dom_ids:
            for l in load(os.path.join(ROOT, "lessons", f"{d}.json")) or []:
                all_lessons[l.get("id")] = set(l.get("tracks") or [])
        img_ids = set()
        for idx, im in enumerate(images):
            w = f"images[{idx}]({im.get('id')})"
            if not im.get("id") or im["id"] in img_ids:
                err(w, "missing or duplicate id")
            img_ids.add(im.get("id"))
            path = os.path.join(ROOT, "..", "images", str(im.get("file")))
            if not os.path.isfile(path):
                err(w, f"file assets/images/{im.get('file')} not found")
            elif os.path.getsize(path) > 450_000:
                err(w, "image file is larger than 450 KB")
            check_l(w + ".caption", im.get("caption"), 6, 32)
            check_l(w + ".alt", im.get("alt"), 5, 40)
            tr = im.get("tracks")
            if not isinstance(tr, list) or not tr or any(t not in TRACKS for t in tr):
                err(w, "tracks must be a non-empty list of A-E")
                tr = []
            for lid in im.get("lessons") or []:
                if lid not in all_lessons:
                    err(w, f"lesson {lid} not found")
                elif not set(tr) & all_lessons[lid]:
                    err(w, f"lesson {lid} shares no track with this picture")
            for d in im.get("domains") or []:
                if d not in dom_ids:
                    err(w, f"unknown domain {d}")
            for lab in im.get("labs") or []:
                if lab not in LABS:
                    err(w, f"unknown lab {lab}")
            for sc_ in im.get("screens") or []:
                if sc_ not in SCREENS:
                    err(w, f"unknown screen {sc_}")
            if not (im.get("lessons") or im.get("domains") or im.get("labs") or im.get("screens")):
                err(w, "picture is not used anywhere")
        counts["images"] = len(images)

    if errors:
        print(f"FAILED with {len(errors)} error(s):")
        for e in errors[:200]:
            print("  -", e)
        if len(errors) > 200:
            print(f"  ... and {len(errors) - 200} more")
        return 1
    scope = only or "all domains"
    print(f"OK ({scope})")
    print("counts:", json.dumps(counts))
    if not only:
        print("lessons visible per track:", json.dumps(per_track))
        print("quiz questions total:", counts["quiz_lesson"] + counts["quiz_bank"])
        unused = sorted(ref_ids - used_refs)
        print("references never cited by curriculum items:", unused)
        print("per-domain coverage:")
        for d in dom_ids:
            print("  ", d, json.dumps(coverage.get(d, {})))
    return 0


if __name__ == "__main__":
    sys.exit(main())
