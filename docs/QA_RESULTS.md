# Quality assurance results

What was actually run on 2026-11-14, on the build machine (macOS, Apple silicon), and what was not.

## Environment

| | |
|---|---|
| Flutter / Dart | 3.44.8 stable / 3.12.2 |
| Android toolchain | SDK 36, build-tools 36.0.0, NDK 28.2, Gradle 9.1.0, AGP 9.0.1, Kotlin 2.3.20, JDK Temurin 24 |
| Test device | Android emulator, API 34, arm64-v8a, 1080×1920 @ 420 dpi |
| Physical devices | **None.** A phone was connected to the build machine but nothing was installed on it |

## Checks and results

| Check | Command | Result |
|---|---|---|
| Dependency resolution | `flutter pub get` | Pass |
| Formatting | `dart format lib test integration_test` | Pass (formatted) |
| Static analysis | `flutter analyze` | Pass — "No issues found" |
| Content validation | `python3 tools/validate_content.py` | Pass — `OK (all domains)` |
| Unit + widget tests | `flutter test` | Pass — **58 of 58** |
| Integration test (on emulator) | `flutter test integration_test -d emulator-5554` | Pass — **1 of 1** |
| Release APK | `flutter build apk --release` | Built, 57.0 MB |
| Release app bundle | `flutter build appbundle --release` | Built, 55.5 MB |
| Debug APK | `flutter build apk --debug` | Built once on the unmodified template as a toolchain check; not rebuilt for the final code, except implicitly by the integration test run |
| Install + launch | `adb install` on the emulator | Installed and launched; onboarding, Home, Explore, Labs, Ask, lessons, Body/Puberty/Period Labs, Safety Center viewed in Hinglish and Hindi |

### APK facts (verified with `aapt2` and `apksigner`)

- Path: `build/app/outputs/flutter-apk/app-release.apk` (copy at `dist/UNFILTERED-1.0.0-release.apk`)
- Package `app.unfiltered.learn`, version 1.0.0 (1), minSdk 24, targetSdk 36, ABIs arm64-v8a, armeabi-v7a, x86_64
- Permissions requested: **none** (no `INTERNET`); `allowBackup=false`
- Signature: **Android debug certificate** (`CN=Android Debug`). Not a production signature
- SHA-256 of the dist copy: `241a61dd00a3408749bd35587a4cf17d51a19c03ead66ed3a87d6770908cd9a2`

## What the automated tests cover

**Unit (test/content_test.dart, test/logic_test.dart)**

- Content repository validation: every file loads; unique IDs; every lesson has a domain, valid tracks,
  3+ sections, three translations (Devanagari in Hindi, none in Hinglish); prerequisites exist; quiz answer
  keys valid; every cited source resolves; no empty lesson; all 18 domains have 5+ lessons, 12+ FAQs,
  7+ myth cards; every Body Lab hotspot has text and vice versa; the Python validator agrees
- Curriculum mapping: every UNESCO concept 1–8 has lessons; every track has a real curriculum
- Lesson eligibility by age: tracks see only items that list them; ages 5–12 never get contraception,
  pregnancy or STI domains; the 5–8 track is limited to eight body-safety domains; adult-only lessons
  cannot open on minor tracks; labs and diagrams are gated; recommendations respect prerequisites
- Quiz scoring and question evaluation, including locked answers and track-filtered quiz building
- Offline search: English, Hinglish and Hindi queries; no invented answers for nonsense queries; track
  filtering; urgent-phrase detection
- Progress persistence across a simulated restart; schema migration; corrupt data ignored
- Privacy: delete-all removes every app key and nothing else; notes deletion; export excludes the PIN;
  nothing is stored for searches
- Educator lock: allowed tracks, PIN required, disallowed saved track corrected on start
- Localisation: every UI string in three languages; every key used in code is defined
- Lab models: cycle phases for every cycle length 21–35; method rates

**Widget (test/widget_test.dart)** — full app pumped with the real curriculum and real fonts

- Onboarding first run; Home dashboard; topic navigation and filters; lesson completion saved and restored
  after restart; calm completion for sensitive lessons; restricted content never renders on a child track;
  myth card flip; quiz interaction, explanation, score and retry; language switching; delete all data;
  Safety Center (confirmation before dialling, child-appropriate helplines); Ask (answers, no-match state,
  urgent help); Body Lab, Period Lab, decision paths; Protection Lab; Teacher Mode
- Layout: the five tabs and 20 further screens at 160% text, Hindi, dark, high contrast on a 320×640 screen, plus landscape rotation,
  with no overflow or exception

**Integration (integration_test/app_test.dart)** — on the emulator, real storage and bundled assets

- First-run flow → finish a lesson → complete a quiz → restart and restore → switch tracks → restricted
  content hidden → delete local data

## Not tested, or tested only partly

- **No real phones.** Performance on low-end and mid-range devices, different Android versions (only API 34
  was run), OEM font scaling and battery use are unverified. No frame-timing measurements were taken
- **Offline** was verified by construction (no network permission, all content bundled, tests load from the
  bundle), not by switching a device to aeroplane mode
- **Accessibility services**: semantics labels are present and reduced motion is tested, but TalkBack and
  switch access were not exercised by a person
- **Helpline dialling and external links** go through `url_launcher`; only the confirmation dialog is tested
- **Reference links**: 36 of 40 resolved (HTTP 200) from the build machine. Four did not respond (India Code
  POCSO and BNS pages, the WCD child-helpline page, naco.gov.in), probably network-side; they are marked in
  the app. The *content* of no source was compared with the app text
- **Content accuracy**: not reviewed by any expert. Automated checks confirm structure, translation presence
  and age tagging, not correctness. See `docs/REVIEW_FLAGS.md`
- The integration test does not walk through every lab; those are covered by widget tests only
- Tablet layouts are constrained to a 640-pt column and were not visually reviewed

## Bugs found by testing and fixed

- Confetti widget created its animation controller during `dispose` when reduced motion was on (crash)
- Several fixed-height cards and the topic header overflowed with large text or Hindi; they now scale
- Home header row overflowed by 1.5 px on narrow screens
- Tab chip rows scrolled horizontally and hid later tabs; they now wrap
- Lessons with a prerequisite outside the learner's track were never recommended
- Recommended order started 13–15 learners on a contraception lesson; it now follows curriculum order
