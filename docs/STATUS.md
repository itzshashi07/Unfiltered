# Implementation status

Last updated 2026-11-14. Use this to pick up the work without re-reading the whole brief.

## Definition of done (from the brief)

| # | Requirement | Status |
|---|---|---|
| 1 | App starts | ✔ Verified on an API 34 emulator (release build) |
| 2 | Major navigation works | ✔ Widget + integration tests |
| 3 | Core curriculum offline | ✔ All content bundled; no network permission |
| 4 | All 18 domains have substantive coverage | ✔ 5–6 lessons, 12 FAQs, 7+ myth cards each |
| 5 | Age tracks function | ✔ Five tracks, gated in one place, tested |
| 6 | Hindi, Hinglish, English | ✔ UI and all content; enforced by tests |
| 7 | Lessons, quizzes, myth cards, interactive activities | ✔ |
| 8 | Progress persists after restart | ✔ Unit, widget and integration tests |
| 9 | Offline search returns only curated answers | ✔ Rule-based retrieval, no-match state |
| 10 | References attached | ✔ Every lesson, FAQ, myth card, scenario |
| 11 | Safety resources accessible | ✔ Home shortcut, Me tab, urgent banner in Ask |
| 12 | Privacy and deletion controls | ✔ Export, delete all, delete notes |
| 13 | Checks reported accurately | ✔ `docs/QA_RESULTS.md` |
| 14 | APK generated and verified | ✔ `dist/UNFILTERED-1.0.0-release.apk` (debug-signed) |
| 15 | Review requirements documented | ✔ `docs/REVIEW_FLAGS.md`, school and Play packs |

**Not done and cannot be done by software: medical, legal and safeguarding review.** The app is not
medically approved and not ready for school deployment.

## Screens (brief section 7)

| | Screen | Status | Notes |
|---|---|---|---|
| A | Splash | ✔ | Animated mascot and wordmark; tap to skip |
| B | Onboarding | ✔ | Purpose, privacy, track, language, accessibility, interests, school lock |
| C | Home | ✔ | Greeting, continue, daily fact, path, topics, myth, featured lab, safety |
| D | Explore | ✔ | 18 domains; filters for difficulty and lesson type. Age filter lives in Teacher Mode, because a learner-side age filter would bypass gating |
| E | Lesson | ✔ | Hook, objectives, sections, lab link, myth/fact, takeaways, activity, quiz, sources, completion |
| F | Body Lab | ✔ | Four code-drawn diagrams by track, hotspots, tilt, reproductive/urinary focus, find-the-part game |
| G | Puberty Lab | ✔ | Hormone cascade animation, age-range timeline |
| H | Period Lab | ✔ | Cycle wheel, hormone curves, lining, cycle-length variation, not-contraception warning |
| I | Myth Buster | ✔ | Flip cards with verdict, science, why, source, learn more |
| J | Consent Simulator | ✔ | 8 branching scenarios (d05, d14) |
| K | Relationship Radar | ✔ | 5 scenarios + Relationship Signals sorting game |
| L | Protection Lab | ✔ | Method comparison (typical/perfect use, 100-dot grid), STI, vaccines, testing, care |
| M | Digital Safety Lab | ✔ | 7 scenarios + Safe or Unsafe challenge |
| N | Ask Unfiltered | ✔ | Offline search in three languages, urgent help, no-match state |
| O | Quizzes | ✔ | MCQ, true/false, scenario; matching = STI Challenge; diagram identification = Body Lab game |
| P | Glossary | ✔ | Searchable, 216 terms |
| Q | Achievements | ✔ | 12 private milestones, no leaderboards |
| R | Private notes | ✔ | Add, delete, delete all |
| S | Safety Center | ✔ | Six helplines, eight guidance flows, confidentiality note |
| T | Teacher Mode | ✔ | Curriculum, lesson plans, present, group quiz, rules, safeguarding, coverage, copy summary |
| U | Parent Guide | ✔ | Seven sections |
| V | References Center | ✔ | 40 sources by category, link-check status, review status |
| W | Settings | ✔ | Language, track, educator lock, accessibility, theme, export, delete, legal, version |

Interactive experiences 1–10 from brief section 8: all present (1 Myth Buster, 2 Body Lab, 3 scenarios,
4 Period Lab, 5 Relationship Signals, 6 Safe or Unsafe, 7 STI Challenge, 8 Support Circle,
9 Communication Practice, 10 Final Challenge).

## Decisions that differ from the brief (and why)

| Brief | Built | Reason |
|---|---|---|
| Drift/SQLite | `shared_preferences` with two versioned JSON documents | Data is small and key-value shaped; fewer dependencies and no code generation. The brief allowed "a similarly reliable local persistence solution". Swap in Drift if reports or large histories are ever needed |
| Flutter localization (ARB) | A typed string table with three columns | Hinglish is not a locale Flutter's `intl` tooling knows; one table keeps all three languages side by side and is test-enforced |
| Secure storage for sensitive data | App-private storage, not separately encrypted | Stated plainly in the privacy text and notes screen. Add `flutter_secure_storage` or SQLCipher if notes must be encrypted at rest |
| Rotatable 3D anatomy models | Flat layered diagrams with a drag-to-tilt effect | Real 3D models would need licensed or hand-built assets and hurt low-end performance; the brief allowed "convincing pseudo-3D" |
| Lottie/Rive | Not used | All motion is Flutter-native; no remote or third-party animation files |
| Hard-locked prerequisites | Prerequisites are a suggested order | A hard lock could strand a learner whose track cannot see the prerequisite |
| "Last verification date" on legal lessons | "Last updated" + "not reviewed by a lawyer" | Nothing was verified against official texts, so the word "verified" would be false |
| School-managed configuration | Educator PIN lock + `EDITION=school` build | The PIN is a convenience lock; the separate edition is the stronger control |

## Suggested next steps

1. Expert review, starting from `docs/REVIEW_FLAGS.md`; record sign-offs per lesson
2. Add official references for the statutes listed there
3. Test on real low-end phones and with TalkBack; measure start-up and scrolling
4. Decide school/adult distribution and set distinct application IDs
5. Production signing key; lawyer-reviewed privacy policy with publisher details
6. Optional: encrypt notes at rest; add `flutter_localizations` for Hindi system tooltips; tablet layouts
