# UNFILTERED — School and college review pack

For school leaders, teachers, counsellors and review committees deciding whether to evaluate this app.

## 1. Read this first

- **The curriculum has not been reviewed by any expert.** It was drafted with AI assistance against the
  sources listed in the app's References Center. It is ready *for* medical, legal and safeguarding review;
  it has not *passed* one. Please do not use it with students until your own reviewers have signed it off.
- **It is not certified or endorsed** by UNESCO, WHO, NCERT, CBSE, any state board or any government body.
  The mapping to UNESCO's key concepts is the project's own.
- Adoption by a school needs your institution's normal permissions, parent communication and approval
  processes. This pack does not replace them.

## 2. What the app is

An offline Android app for comprehensive sexuality, relationship and life-skills education in Hinglish,
Hindi and English. It is educational: not a dating app, not a clinic, not entertainment. It contains no
explicit imagery; diagrams are flat, labelled teaching drawings.

## 3. Age bands (learning tracks)

| Track | Ages | Name | Scope |
|---|---|---|---|
| A | 5–8 | My Body, My Boundaries | Correct body-part names, body ownership, privacy, safe and unsafe touch, safe and unsafe secrets, trusted adults, feelings, kindness, families, online basics. Nothing about sex or reproduction. |
| B | 9–12 | Growing Up | Early puberty, periods, erections and wet dreams as normal body events, hygiene, body image, crushes, boundaries, grooming awareness, media literacy, simple child-protection law. |
| C | 13–15 | Decode Yourself | Hormones, reproductive biology, attraction, masturbation facts versus myths, consent and coercion, gender and identity, pregnancy biology, contraception and STI awareness, online exploitation, pornography as unrealistic media, POCSO. |
| D | 16–17 | Reality Check | Contraception methods, STI testing, pregnancy and options, healthcare access, relationship abuse, gender-based violence, law and confidentiality limits. Written for minors: never encourages sexual activity. |
| E | 18+ | Real Talk Advanced | Adult sexual health, sexual response and common concerns (clinical), fertility, pregnancy choices, marriage and reproductive rights. |

Lessons per domain and age band: `docs/COVERAGE.md`. Machine-readable matrix: `docs/curriculum_matrix.json`.

**How age gating works.** A learner sees only items tagged for their track. The app asks for an age band,
never a date of birth, so it cannot verify age. For school devices use both of these:

1. **Educator lock** (Settings → Educator lock): choose the allowed tracks and set a PIN. Changing the
   track, opening Teacher Mode and deleting data then need the PIN. This is a convenience lock.
2. **School edition** build, which contains no adult (18+) track at all (see `README.md`).

## 4. Curriculum scope

18 domains: the human body; puberty; menstruation; sexual feelings and personal questions; consent and body
autonomy; relationships; contraception; pregnancy, fertility and choices; STIs; sexual health; gender,
identity and inclusion; pornography, media and internet reality; digital safety; violence and personal
safety; Indian myths; Indian laws and rights; mental health and body image; life skills and communication.

Each of the 98 lessons has: learning objectives, 3–4 explanatory sections, a myth-and-fact callout, key
takeaways, a reflection activity, a two-question check with explanations, sources, an estimated duration
(3–9 minutes of reading) and, where relevant, a health or safety warning and a linked interactive lab.

## 5. Teacher Mode (in the app: Me → Teacher Mode)

- **Curriculum browser** by age group, with facilitation notes, three discussion prompts and a safeguarding
  caution for every domain.
- **Lesson plan** for every lesson: objectives, outline, misconception to address, activity, check questions
  with answers, sources.
- **Present**: projector-safe slides (large type, dark background, one idea per slide).
- **Group quiz**: show, discuss, reveal. Nothing is recorded.
- **Copy summary**: a plain-text, non-identifiable lesson summary to paste into a document for printing.
- **Classroom rules**, an **anonymous question box** method, **safeguarding guidance** and a **coverage map**.

Teacher Mode reads only the bundled curriculum. It cannot see any learner's searches, notes, quiz scores,
bookmarks or lesson history, and the app produces no reports about individuals. Everything works offline,
so no separate "lesson pack" download is needed.

## 6. Safeguarding

- Language is calm and trauma-informed; survivors are never blamed; no lesson requires a disclosure.
- Lessons about abuse and violence end without celebration and offer the Safety Center.
- The Safety Center lists 112, 1098, 181, 1930 / cybercrime.gov.in, Tele-MANAS 14416 and NACO 1097, with
  step-by-step guidance. A call is placed only after the learner taps and confirms.
- The app is honest that adults cannot promise secrecy to under-18s: the POCSO Act requires reporting.
- Ask Unfiltered shows help resources when a question suggests someone may be unsafe.
- **Your school still needs** its own child-protection policy, a named safeguarding lead, a procedure for
  disclosures made during lessons, and staff training. The app's guidance is general, not legal advice.

## 7. Privacy

No account, name, phone number, email, school name or date of birth is collected. The app has no internet
permission, no analytics and no advertising. Progress, quiz scores, bookmarks and optional notes stay on
the device, in the app's private storage (not separately encrypted), and can be exported or deleted in
Settings. On shared devices, learners should know that the next user can open the app.

## 8. Content review checklist (for your reviewers)

- [ ] Medical accuracy of each lesson, FAQ and myth card (start with `docs/REVIEW_FLAGS.md`, section 2)
- [ ] Legal accuracy against current official texts (section 1 of the same file); add verification dates
- [ ] Age-appropriateness of every item per track, including quiz options and search keywords
- [ ] Hindi and Hinglish read naturally and carry the same facts as English
- [ ] Cultural sensitivity for your community; inclusion (disability, gender, family structures)
- [ ] Safeguarding wording and helpline details are current for your state
- [ ] Sources support the claims that cite them
- [ ] Sign-off recorded per lesson (reviewer, qualification, date) before changing its review status

## 9. Accessibility checklist (built in; please verify on your devices)

- [x] Text size 85–160% on top of the system setting; layouts tested at 160% on a 320-pt-wide screen
- [x] Light, dark and high-contrast themes
- [x] Reduce-motion setting (also follows the system setting); no information depends on animation
- [x] Quiz and game feedback uses icon + words + colour, never colour alone
- [x] Screen-reader labels on controls, diagrams (alt text) and progress indicators; tap-list alternative to diagram hotspots
- [x] No drag-only interactions: sliders and buttons accompany every drag
- [ ] Not yet tested with real TalkBack users, switch access or learners with dyslexia — please pilot

## 10. Suggested evaluation method

1. Two reviewers (one health, one safeguarding) read the lessons for one age band using Teacher Mode.
2. Pilot with one class and a trained facilitator; use the anonymous question box.
3. Collect feedback with a short, anonymous, non-identifying form: what was unclear, what was missing,
   what felt inappropriate, and whether students know where to get help.
4. Compare a short knowledge check before and after (the in-app group quiz stores nothing).
5. Log every correction, fix the JSON content, re-run the validator, and re-review changed lessons.
