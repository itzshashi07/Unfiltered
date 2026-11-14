# UNFILTERED — Content Authoring Guide & Schema

UNFILTERED is an offline Flutter app for comprehensive sexuality, relationship and life-skills
education for Indian learners. Tagline: **Real Talk. Real Science. Zero Shame.**
All curriculum content lives in JSON files under `assets/content/`. This guide is the contract
between content files and the app. The validator `tools/validate_content.py` enforces it.

## 1. Voice

"Unfiltered" = candid, direct, medically correct, stigma-free. Say the real thing plainly; do not
sugar-coat risks, laws or consequences, and do not moralise. It does **not** mean erotic.

- Never erotic, never arousing, no sexual storytelling, no slang for body parts except when naming
  a slang term in order to replace it with the correct one.
- Correct medical terms (penis, vulva, vagina, clitoris, semen, menstruation...). No euphemisms.
- Non-judgemental, no shaming of people, bodies, communities, religions or cultures.
- Never joke about sexual violence, abuse, trauma, unwanted pregnancy, infertility or identity.
- Never blame survivors. Never diagnose. Never give personalised medical/legal advice or drug doses.
- Never claim expert review, endorsement or certification. Never invent statistics, studies or sources.
  If you are not sure a number is right, describe it qualitatively instead.
- Encourage seeing a doctor / trusted adult / helpline where relevant.
- Gender-inclusive where anatomy is discussed ("people who menstruate", "people with a penis") while
  still being readable; do not assume the reader's gender or orientation.
- Indian context: examples, names, school/college/family situations, Indian helplines and laws.

### Three languages — every text field is an object `{ "en": "...", "hi": "...", "hg": "..." }`

- `en` — plain, clear English. This is the canonical version.
- `hi` — natural spoken Hindi in **Devanagari**. Common medical terms may stay in English inside
  brackets or be transliterated (e.g. "योनि (vagina)", "कंडोम"). Must contain Devanagari.
- `hg` — **Hinglish**: Hindi-English mix in **Roman script only** (no Devanagari), the way Indian
  Gen Z texts: "Periods biology hain, sharam ki cheez nahi." Friendly, smart, occasionally witty,
  never cringe, never vulgar. This is the app's default language, so make it the best one.
- All three must carry the same facts. Do not leave any of them shorter in substance.

## 2. Age tracks (strict — wrong-age exposure is a release blocker)

| Track | Ages | Name | What is allowed |
|---|---|---|---|
| A | 5–8 | My Body, My Boundaries | Correct body-part names, body autonomy, privacy, safe/unsafe touch and situations, trusted adults, asking for help, bullying, families, respecting differences, feelings, online safety basics. Very short simple sentences. **No sex, no reproduction mechanics, no puberty detail, no sexual behaviour of any kind.** |
| B | 9–12 | Growing Up | Early puberty, body changes, periods basics, wet dreams and erections as normal body events, hygiene, body image, crushes, simple reproductive anatomy, boundaries, grooming awareness, media literacy, friendships, bullying. No contraception detail, no sexual acts, no pornography discussion beyond "some online content is made for adults and is not real life; tell a trusted adult". |
| C | 13–15 | Decode Yourself | Hormones, reproductive biology, sexual feelings and attraction, masturbation myths, consent and coercion, gender and identity, pregnancy biology, contraception/STI **awareness**, online exploitation, pornography as unrealistic media, peer pressure, POCSO, how to get help. |
| D | 16–17 | Reality Check | More detailed and legally contextualised: contraception methods, STI testing, pregnancy consequences, healthcare access, relationship abuse, gender-based violence, law, confidentiality limits. Still content for minors: never encourage sexual activity or unlawful activity. |
| E | 18+ | Real Talk Advanced | Full adult education: sexual response, pleasure and wellbeing discussed **clinically**, dysfunction, intimacy and communication, all contraception, fertility, pregnancy options, marriage and reproductive rights. Educational and non-erotic. |

- Every item has `"tracks": [...]` listing exactly the tracks that may see it. An item is shown only
  to learners on a listed track. Write the text for the **youngest** track listed.
- Spiral curriculum: the same idea returns at later tracks with more depth, as a *different* item.
- For minors (A–D): under Indian law (POCSO) a person under 18 cannot legally consent to sexual
  activity. Never imply a minor's agreement overrides that. Never frame sexual activity between or
  with minors as expected. Always present delaying as a fully valid choice.
- Allowed tracks per domain (validator enforces): d01 A–E · d02 B–E · d03 B–E · d04 B–E · d05 A–E ·
  d06 A–E · d07 C–E · d08 C–E · d09 C–E · d10 B–E · d11 A–E · d12 B–E · d13 A–E · d14 A–E ·
  d15 B–E · d16 B–E · d17 A–E · d18 A–E.
- Track-E-only topics: orgasm/sexual response detail, sexual pleasure, libido, painful intercourse,
  erectile dysfunction, premature ejaculation, sexual technique-adjacent communication, fertility
  treatment. Track D may *name* these as things adults can get medical help for, nothing more.

## 3. Facts to keep consistent (use these; do not contradict them)

Medical
- Emergency contraception (EC): works by delaying ovulation; can be used up to 5 days (120 h) after
  unprotected sex, the sooner the better; copper IUD is the most effective EC; EC does **not** end an
  established pregnancy and is not abortion; it is not for regular use and gives no STI protection.
- HIV PEP: needs urgent clinical assessment; start as soon as possible and no later than 72 hours
  after exposure; taken for 28 days. PrEP: medicine taken by HIV-negative people to prevent HIV,
  prescribed by a clinician. HIV treatment (ART) lets people live long healthy lives; a person with
  an undetectable viral load does not transmit HIV sexually (U=U). HIV is not spread by hugging,
  sharing food, toilets, mosquitoes or casual contact.
- Many STIs have no symptoms; only testing tells. Condoms greatly reduce but do not eliminate risk.
  Bacterial STIs (chlamydia, gonorrhoea, syphilis) and trichomoniasis are curable; viral ones (HIV,
  herpes, hepatitis B, HPV) are manageable/preventable; vaccines exist for HPV and hepatitis B.
- HPV vaccination plus cervical screening greatly reduce cervical-cancer risk. WHO's primary target
  group for vaccination is girls aged 9–14, before sexual activity begins.
- Typical-use vs perfect-use pregnancy rates per 100 users in the first year (approximate, from WHO
  family-planning material): implant <1 / <1; hormonal or copper IUD <1 / <1; injectable about 4 / <1;
  combined pill about 7 / <1; external condom about 13 / 2; internal condom about 21 / 5;
  withdrawal about 20 / 4; fertility-awareness (calendar) methods vary widely, roughly 2–23;
  no method about 85. Only condoms (external/internal) also reduce STI risk.
- Calendar / "safe days" calculations are **not** reliable contraception. Pregnancy can happen the
  first time someone has sex. Pre-ejaculate can contain sperm.
- Home pregnancy tests detect hCG in urine; most reliable from the first day of a missed period;
  a negative test taken too early can be wrong. Ectopic pregnancy warning signs (one-sided lower
  abdominal pain, vaginal bleeding, shoulder-tip pain, fainting) = urgent hospital care.
- Puberty usually begins between 8–13 in girls and 9–14 in boys; timing varies widely and is normal.
  See a doctor if there are signs before 8 (girls) / 9 (boys), or no signs by 13 (girls) / 14 (boys),
  or no period by 15. Typical cycle length is 21–35 days in adults and can be 21–45 days in the
  first years after the first period; bleeding usually lasts 2–7 days.
- See a doctor for periods: soaking a pad/tampon every 1–2 hours, bleeding longer than 7 days, pain
  that stops normal activity, periods that stop for 3+ months, bleeding between periods.
- Toxic shock syndrome is rare but serious: change tampons every 4–8 hours, wash hands, follow cup
  instructions; sudden high fever, rash, vomiting, dizziness while using one = remove it and get
  urgent care.
- Masturbation: common, not physically harmful; does not cause weakness, infertility, blindness, acne,
  hair loss or "loss of manhood". Not doing it is also completely normal. It is a private activity.
  It becomes a concern only if it causes distress, injury, or interferes with daily life. Semen is
  continuously produced; "semen loss" does not drain strength ("dhat" anxiety is a recognised
  culture-linked worry, treatable by talking to a doctor).
- The hymen is a thin stretchy tissue that varies naturally, may or may not tear or bleed, and can
  **never** show whether someone has had sex. "Virginity tests" (incl. the "two-finger test") are
  unscientific and have been condemned by WHO and prohibited by the Supreme Court of India.
- Periods are not impure; exercise, bathing, cooking, school and worship-related restrictions have
  no medical basis. Menstrual blood is ordinary blood and tissue.
- Being lesbian, gay, bisexual, transgender, asexual or intersex is not an illness. "Conversion
  therapy" is harmful, has no scientific basis, and is treated as professional misconduct for
  doctors in India. Intersex variations are natural variations in sex characteristics.

Indian law (plain language; always tell the learner laws can change and this is not legal advice)
- POCSO Act, 2012: a "child" is anyone under 18. Any sexual act with a person under 18 is an offence
  whether or not the child "agreed". Covers penetrative and non-penetrative assault, sexual
  harassment, and using a child for pornography. Anyone who knows of an offence must report it to
  the police or Special Juvenile Police Unit (mandatory reporting, s.19); the child's identity must
  not be disclosed by media (s.23); procedures are meant to be child-friendly.
- Because of mandatory reporting, doctors, teachers and counsellors **cannot promise total secrecy**
  to someone under 18 about sexual abuse or sexual activity. Say so honestly; never promise absolute
  confidentiality.
- Bharatiya Nyaya Sanhita, 2023 (in force from 1 July 2024, replaced the IPC): defines rape and
  sexual offences against women (ss.63–70), sexual harassment (s.75), voyeurism (s.77), stalking
  incl. online (s.78), and more. Consent must be an unequivocal voluntary agreement. The BNS keeps an
  exception: intercourse by a man with his own wife who is not under 18 is not "rape" under s.63 —
  this exception is contested and under legal challenge; other remedies exist (e.g. the Protection
  of Women from Domestic Violence Act, 2005). Ethically and medically, **marriage is not consent**.
  Mention section numbers sparingly and never as the main point.
- Information Technology Act, 2000: capturing/sharing private images without consent, publishing
  sexually explicit material, and any child sexual abuse material (creating, viewing, storing,
  sharing — s.67B) are offences. Never tell a learner to save, download or forward abuse material of
  a minor, even "as evidence": tell them to not delete the chat/account details, not forward the
  image, and report to cybercrime.gov.in / 1930 / police / 1098 with a trusted adult.
- Medical Termination of Pregnancy Act, 1971 (amended 2021): abortion is legal in India under
  conditions — up to 20 weeks on the opinion of one registered doctor; 20–24 weeks for specified
  categories (including survivors of sexual assault and minors) on the opinion of two doctors;
  beyond 24 weeks only for substantial foetal abnormalities via a Medical Board. Applies to married
  and unmarried women. A person under 18 needs a guardian's written consent, and POCSO reporting
  duties apply. Only qualified providers at approved facilities; never suggest self-medication.
- Legal marriage age: 18 for women, 21 for men. Consensual same-sex relations between adults are not
  a crime (Supreme Court, 2018). Transgender persons have legally recognised rights (NALSA 2014;
  Transgender Persons (Protection of Rights) Act, 2019).
- Helplines (India): Emergency **112** · Child Helpline **1098** · Women Helpline **181** ·
  Cybercrime helpline **1930** and https://cybercrime.gov.in · Tele-MANAS mental health **14416** ·
  NACO HIV/AIDS helpline **1097**. Adolescent Friendly Health Clinics (AFHC) exist under RKSK in
  government health facilities.

## 4. References

Use only IDs from `assets/content/references.json` in every `refs` array (at least one per item).
Do not invent IDs, URLs or titles. Pick the closest genuine source for the claim:

`unesco-itgse` `who-cse` `who-cse-qa` `who-sexual-health` `who-sti` `who-hiv` `who-pep` `who-hepb`
`who-herpes` `who-syphilis` `who-chlamydia` `who-ec` `who-fp` `who-cervical` `who-hpv` `who-abortion`
`who-infertility` `who-pcos` `who-endometriosis` `who-adolescent-mh` `who-vaw` `nhs-periods` `nhs-tss`
`nhs-ectopic` `nhs-ed` `nhm-rksk` `nhm-afhc` `nhm-cac` `naco` `tele-manas` `pocso-2012` `bns-2023`
`wcd-childline` `wcd-mission-shakti` `mha-erss` `cybercrime-portal`

General CSE / relationships / consent / gender / life-skills content → `unesco-itgse` or `who-cse`.
Puberty and general body content → `unesco-itgse`, `who-sexual-health`, `nhm-rksk`.

## 5. Files and schemas

`L` below means a localized object `{ "en": "", "hi": "", "hg": "" }` with all three non-empty.
IDs are lowercase. `dNN` is the two-digit domain id (`d01`…`d18`). All files are UTF-8 JSON arrays.

### 5.1 Lessons — `assets/content/lessons/dNN.json`

```json
{
  "id": "d03-l01",
  "domain": "d03",
  "tracks": ["B"],
  "difficulty": 1,
  "minutes": 5,
  "unesco": [6],
  "title": L,
  "subtitle": L,
  "hook": L,
  "objectives": [L, L],
  "prereqs": [],
  "sections": [ { "h": L, "body": L }, { "h": L, "body": L }, { "h": L, "body": L } ],
  "myth": { "claim": L, "fact": L },
  "takeaways": [L, L, L],
  "activity": L,
  "interactive": null,
  "quiz": [
    { "id": "d03-l01-q1", "type": "mcq", "q": L, "options": [L, L, L, L], "answer": 1, "explain": L },
    { "id": "d03-l01-q2", "type": "tf",  "q": L, "options": [L, L], "answer": 0, "explain": L }
  ],
  "refs": ["nhs-periods", "unesco-itgse"],
  "warning": null,
  "sensitive": false,
  "review": "pending_expert_review",
  "revised": "2026-11-14"
}
```

- `id`: `dNN-lNN`, numbered in the order of the lesson slots in section 6.
- `difficulty`: 1 (starter) · 2 (core) · 3 (deep dive). `minutes`: 3–9.
- `unesco`: one or more of 1–8 (1 Relationships · 2 Values, Rights, Culture and Sexuality ·
  3 Understanding Gender · 4 Violence and Staying Safe · 5 Skills for Health and Well-being ·
  6 The Human Body and Development · 7 Sexuality and Sexual Behaviour · 8 Sexual and Reproductive Health).
- `hook`: 1–2 punchy sentences that open the lesson.
- `objectives`: 2–3. `takeaways`: exactly 3, one sentence each.
- `prereqs`: ids of earlier lessons **in the same file** that share at least one track, or `[]`.
- `sections`: 3 or 4. Each `body.en` is 55–110 words (track A: 25–60 words, very simple). Real
  information, concrete and specific. Plain text only — no markdown, no bullet characters, no
  newlines inside strings. Do not repeat the same sentences across lessons.
- `myth`: one misconception this lesson corrects, and the fact.
- `activity`: a private reflection or practical activity (never asks for intimate disclosures).
- `interactive`: `null` or one of `body_lab` `puberty_lab` `period_lab` `myth_buster` `consent_sim`
  `relationship_radar` `protection_lab` `digital_safety` `sti_match` `support_circle`
  `communication` `ask` — the in-app lab that best extends this lesson.
- `quiz`: exactly 2 questions. `type`: `mcq` (3–4 options), `tf` (exactly 2 options: True/False,
  localized "True"/"सही"/"Sahi" and "False"/"ग़लत"/"Galat"), or `scenario` (3–4 options, a short
  situation). `answer` is the 0-based index. `explain` says why, in 1–2 sentences. Vary the position
  of the right answer. Wrong options must be plausible, never silly.
- `warning`: `null`, or an `L` safety/clinical note (e.g. when to seek urgent care).
- `sensitive`: `true` when the lesson is about abuse, violence, assault, exploitation, pregnancy
  loss or similar — the app then skips playful celebration.
- `review` is always `"pending_expert_review"`; `revised` is always `"2026-11-14"`.

### 5.2 FAQs — `assets/content/faqs/dNN.json` (the offline "Ask Unfiltered" knowledge base)

```json
{ "id": "d03-f01", "domain": "d03", "tracks": ["B","C"], "q": L, "a": L,
  "keywords": ["period late", "late period", "mahina late", "पीरियड लेट", "missed period"],
  "refs": ["nhs-periods"], "urgent": false, "lesson": "d03-l01" }
```

- `q`: the question the way a real learner would type it. `a.en`: 45–110 words, a direct answer
  first, then the nuance, then when to get help if relevant.
- `keywords`: 6–12 lowercase search phrases mixing English, Hinglish (Roman) and Hindi (Devanagari),
  including everyday/slang words learners actually search with.
- `urgent`: `true` if the question suggests possible harm, abuse or a medical emergency (the app
  then shows help resources with the answer).
- `lesson`: id of a related lesson in the same domain whose tracks overlap, or `null`.
- Questions must be distinct from each other and from lesson titles; cover the awkward questions
  people are too embarrassed to ask.

### 5.3 Myth cards — `assets/content/myths/dNN.json`

```json
{ "id": "d03-m01", "domain": "d03", "tracks": ["B","C","D","E"], "claim": L,
  "verdict": "myth", "fact": L, "why": L, "refs": ["nhs-periods"], "lesson": "d03-l01" }
```

- `claim`: the statement as people say it. `verdict`: `myth`, `fact` or `partly`.
  Per domain, 5 should be `myth` and 2 should be `fact` or `partly` (surprising true statements),
  so the "Myth or Science" game is not always "myth".
- `fact`: the verdict explained with the science, 35–80 words (en).
- `why`: why people believe it, respectfully, 20–50 words (en). Never mock a community.

### 5.4 Quiz bank — `assets/content/quiz/dNN.json`

Same question object as lesson quizzes, plus `"domain"` and `"tracks"`:
`{ "id": "d03-q01", "domain": "d03", "tracks": ["C","D"], "type": "mcq", "q": L, "options": [...], "answer": 2, "explain": L }`
These must test different facts from the lesson quizzes.

### 5.5 Glossary — `assets/content/glossary/dNN.json`

```json
{ "id": "d03-g1", "domain": "d03", "tracks": ["B","C","D","E"], "title": L,
  "terms": [ { "term": L, "def": L } ] }
```

Two themed sets per domain, 6 terms each. `def.en` 12–35 words, respectful and precise.
`term.hi` gives the Hindi word (with the English term in brackets if that is what people use).

### 5.6 Scenarios — `assets/content/scenarios/dNN.json` (only for domains assigned scenarios)

```json
{ "id": "d05-s1", "domain": "d05", "module": "consent", "tracks": ["C"], "title": L, "intro": L,
  "sensitive": true, "start": "n1",
  "nodes": {
    "n1": { "text": L, "choices": [
      { "label": L, "tone": "good",  "feedback": L, "next": "n2" },
      { "label": L, "tone": "okay",  "feedback": L, "next": "n2" },
      { "label": L, "tone": "risky", "feedback": L, "next": "n2" } ] },
    "n2": { "text": L, "choices": [ ... ] },
    "n3": { "text": L, "choices": [ { "label": L, "tone": "good", "feedback": L, "next": null } ] }
  },
  "debrief": L, "refs": ["unesco-itgse"] }
```

- `module`: `consent` · `relationship` · `digital` · `communication`.
- Fictional, realistic Indian situations with fictional first names. 3 or 4 nodes; each node has
  2–3 choices; `next` is another node id or `null` (ends the scenario). Every node must be reachable
  and every path must end. `tone`: `good` (safe/respectful), `okay` (understandable but not ideal),
  `risky` (unsafe or disrespectful). `feedback` explains the consequence kindly, 20–50 words (en) —
  never shame the learner for a risky pick; explain the safer response.
- `debrief`: the key lesson, 30–70 words (en). Never graphic. Track A/B scenarios are about
  personal space, secrets, trusted adults, online strangers — nothing sexual.

### 5.7 Topic tags — `audience` and `body` (on every lesson, FAQ, myth card and quiz-bank question)

The app has optional filters called "Topics I want to explore". They only organise content; they never
restrict access and never unlock another age track. Tags are **editorial**: read the item and decide.
Never tag by keyword matching.

```json
"audience": ["men"],            // one or more of: men, women, trans_nb, intersex, everyone
"body": ["penis_testicular"]    // zero or more of: penis_testicular, vulva_vaginal, menstrual,
                                //                  pregnancy_repro, hormones_changes
```

`audience` — who the item is mainly about or written for:

- `everyone` — applies whatever your gender: consent, boundaries, safety, communication, relationships,
  most STI, contraception, law, digital-safety and mental-health items. **When in doubt, use `everyone`.**
- `men` — experiences, health needs or social pressures that mainly concern boys and men (for example
  erections and wet dreams, testicular checks, masculinity pressure, boys and men as survivors).
- `women` — the same for girls and women (for example periods, breast and cervical health, dowry and
  son-preference pressure, pregnancy care).
- `trans_nb` — items that specifically address transgender or non-binary people (identity, rights,
  discrimination, healthcare). Do **not** add it to anatomy items just because such bodies exist.
- `intersex` — items that specifically discuss intersex variations.
- An item may carry several values (a puberty lesson that covers periods and wet dreams is
  `["men", "women"]`; an item for everyone that speaks especially to men is `["everyone", "men"]`).
- Never assume anatomy, orientation or health needs from gender. Anatomy is tagged with `body`.

`body` — tag only when the item substantially teaches that body topic:

- `penis_testicular` — penis, foreskin, testes, scrotum, erections, ejaculation, semen, prostate.
- `vulva_vaginal` — vulva, vagina, clitoris, hymen, discharge, vaginal infections, cervical checks.
- `menstrual` — periods, the cycle, products, PMS, period pain, PCOS and endometriosis as period
  conditions, menopause.
- `pregnancy_repro` — conception, contraception, pregnancy, abortion, fertility, birth, the postpartum
  period, reproductive rights.
- `hormones_changes` — puberty, hormones, growth, skin, hair, voice, breast or chest development,
  age-related hormonal change.
- Leave `body` as `[]` for items that are not about a body topic (most consent, relationship, law, digital
  and mental-health items).

Items shown to track A must be `"audience": ["everyone"], "body": []`. Quiz questions inside a lesson
inherit the lesson's tags; do not tag them separately. Check with
`python3 tools/validate_content.py --domain dNN --require-topics`.

The tags of the first 631 items were decided by hand and are recorded in `tools/topic_tags.py`
(`--check` reports any drift between that table and the files). New items carry their tags in the
content files; the script leaves them alone.

Domain titles: `domains.json` may give a domain an optional `title_young` (same L shape as `title`).
Tracks A and B see it instead of `title`; Teacher Mode always shows `title`. d12 uses it so that 9 to 12
year olds see "Screens, Media & Internet Reality" rather than a title naming pornography.

### 5.8 Law names — `laws` (lessons that explain a law)

```json
"laws": [ { "en": "POCSO Act, 2012", "hi": "पॉक्सो अधिनियम, 2012", "hg": "POCSO Act, 2012" } ]
```

One entry per law the lesson actually explains (1–8), short official name with the year. The app shows
them in a legal-information box with the jurisdiction (India), the official sources from `refs`, the date
of the last automated check and the review status ("not reviewed by a lawyer"). Every lesson in d16 and
any other lesson whose main subject is a law must have `laws`.

### 5.9 At-a-glance visuals — `assets/content/visuals/dNN.json`

One small infographic per lesson. It may only restate facts that are in that lesson, at the reading level
of the lesson's youngest track. No new claims.

```json
{ "lesson": "d03-l01", "type": "steps", "title": L,
  "items": [ { "icon": "drop", "label": L, "text": L }, ... ] }

{ "lesson": "d05-l03", "type": "compare", "title": L,
  "left":  { "title": L, "tone": "good", "icon": "check", "points": [L, L, L] },
  "right": { "title": L, "tone": "bad",  "icon": "cross", "points": [L, L, L] } }
```

- `type`: `steps` (3–5 ordered steps: a process, a sequence, what to do), `grid` (4–6 key facts of equal
  weight) or `compare` (two sides: myth and fact, safe and unsafe, healthy and harmful, do and avoid).
  Pick the type that fits the lesson's main idea, and vary the types within a domain.
- `title` 2–10 words. `label` 1–6 words. `text` 4–24 words. Compare `title` 1–5 words; each side has
  2–4 `points` of 3–18 words; `tone` is `good`, `bad` or `neutral`.
- `icon` must be a key from `assets/content/extras/visual_icons.json` ("icons" are symbols, "objects" are
  small drawings of real things such as `pad`, `cup`, `condom`, `pill`, `iud`, `implant`, `injection`).
  Choose icons that mean something for the line they sit next to.
- If a `visuals/dNN.json` file exists it must cover every lesson of that domain, once each.

### 5.10 Pictures — `assets/content/extras/images.json`

```json
{ "id": "clinic-teen", "file": "clinic-teen.jpg", "tracks": ["C", "D", "E"],
  "caption": L, "alt": L, "generated": true,
  "lessons": ["d10-l03"], "domains": ["d10"], "labs": [], "screens": [] }
```

Files live in `assets/images/` (JPEG, at most 450 KB). `caption` (6–32 words) explains what the learner
is looking at and why it matters; `alt` (5–40 words) describes the picture for screen readers. `tracks`
lists every track allowed to see it. A lesson shows the first picture that lists it in `lessons`, else the
first that lists its domain. `labs` uses lab keys; `screens` is `safety`, `parents` or `teacher`.
`generated: true` marks AI-generated illustrations, which the app labels as such. Pictures are always fully
clothed, non-explicit scenes or objects; anatomy is shown only by the app's own labelled diagrams.

## 6. Required items per domain

Lesson slots (one lesson per slot, in this order; the bracket is the `tracks` value):

- d01: [A] [B] [C] [C,D] [D,E] [C,D,E]
- d02: [B] [B] [B] [C] [C] [C,D,E]
- d03: [B] [B] [C] [C,D] [D,E] [C,D,E]
- d04: [B] [B] [C] [C] [D] [E]
- d05: [A] [B] [C] [D] [E] [C,D,E]
- d06: [A] [B] [C] [D] [E] [C,D,E]
- d07: [C] [D] [D] [E] [E]
- d08: [C] [D] [D] [E] [E]
- d09: [C] [D] [D] [E] [D,E]
- d10: [B] [C] [D] [E] [E]
- d11: [A] [B] [C] [D,E] [C,D,E]
- d12: [B] [C] [D] [E] [C,D,E]
- d13: [A] [B] [C] [D] [D,E] [C,D,E]
- d14: [A] [A] [B] [C] [D,E] [C,D,E]
- d15: [B] [C] [C,D] [D,E] [E]
- d16: [B] [C] [D] [E] [C,D,E]
- d17: [A] [B] [C] [D] [E]
- d18: [A] [B] [C] [D,E] [C,D,E]

Per domain also: **12 FAQs**, **7 myth cards**, **6 quiz-bank questions**, **2 glossary sets**.
Spread the `tracks` of FAQs/myths/quiz/glossary across every track the domain allows, so each track
has something (track A items must be genuinely for 5–8 year olds: short, simple, reassuring).

Scenarios (domain: module → one scenario per bracket):
- d05: consent → [A] [B] [C] [D] [E]
- d06: relationship → [B] [C] [D] [E] [C,D,E]
- d12: digital → [C] [D,E]
- d13: digital → [A] [B] [C] [D] [C,D,E]
- d14: consent → [A] [B] [C,D,E]
- d17: communication → [C] [D,E]
- d18: communication → [A] [B] [C] [D,E]

Choose lesson topics so that, together with FAQs and myths, the domain's topic list in
`docs/DOMAIN_TOPICS.md` is covered. A topic is not covered by a heading alone.

## 7. Workflow for authors

1. Read this file and your domains in `docs/DOMAIN_TOPICS.md`.
2. Write each file with the Write tool (one file per domain per content type). Write real JSON —
   escape double quotes inside strings, no trailing commas, no comments.
3. Run `python3 tools/validate_content.py --domain dNN` for each of your domains and fix every
   error it prints. Repeat until it prints `OK`.
4. Do not edit any file outside your assigned domain files.
