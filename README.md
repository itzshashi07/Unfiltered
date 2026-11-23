# UNFILTERED

**Real Talk. Real Science. Zero Shame.**

An offline-first Flutter Android app for comprehensive sexuality, relationship and life-skills education
for Indian learners, in Hinglish, Hindi and English, with five age tracks (5–8, 9–12, 13–15, 16–17, 18+).

> **Not reviewed, not endorsed.** The curriculum was drafted with AI assistance against public-health and
> legal sources. No medical, legal or child-safeguarding professional has reviewed it, and no organisation
> (UNESCO, WHO, NCERT, any government or board) has certified or endorsed it. Do not deploy it to learners
> until that review has happened. See `docs/REVIEW_FLAGS.md`.

## What is in the box

| | |
|---|---|
| App | Flutter 3.44 / Dart 3.12, Android only, Material 3 with a custom design system |
| Curriculum | 18 domains · 98 lessons · 216 FAQs · 131 myth cards · 304 quiz questions · 26 branching scenarios · 36 glossary sets, all trilingual (`docs/COVERAGE.md`) |
| Labs | Body Lab, Puberty Lab, Period Lab, Myth Buster, Consent Simulator, Relationship Radar, Protection Lab, Digital Safety Lab, STI Challenge, Support Circle, Communication Practice, quizzes, Final Challenge |
| Test Your Knowledge | 1,227 everyday questions in 12 topics (exported from the website's bank by `tools/export_web_content.py`): daily challenge, mega test, topic tests, and a score poster with name and age shared through the Android share sheet. Scores stay on the device |
| Other screens | Onboarding, Home, Explore, Ask Unfiltered (offline search), Safety Center, Teacher Mode, Parent Guide, References Center, Milestones, Bookmarks, Private notes, Settings |
| Privacy | No account, no network permission, no analytics, no ads. Everything is stored on the device and can be exported or deleted |

## Requirements

- Flutter stable 3.44.x (Dart 3.12), Android SDK with platform 36 and build-tools 36, a JDK that Gradle 9.1 supports (built here with Temurin 24)
- Python 3 for the content tools (Pillow only for regenerating the icon)

## Run, test, build

```bash
flutter pub get
flutter run                                   # debug on a connected device or emulator

dart format lib test integration_test
flutter analyze
python3 tools/validate_content.py             # content schema, age tracks, references
flutter test                                  # unit + widget tests (includes content validation)
flutter test integration_test -d <device-id>  # end-to-end test on a device or emulator

flutter build apk --release                   # build/app/outputs/flutter-apk/app-release.apk
flutter build apk --debug                     # build/app/outputs/flutter-apk/app-debug.apk
flutter build appbundle --release             # build/app/outputs/bundle/release/app-release.aab
```

The release build is signed with the **local debug key** so it can be installed for evaluation. It is not
a production signature. See `docs/PLAY_STORE_PACK.md` for configuring a real upload key.

### Editions

One codebase, three build-time editions (needed if a single Play listing cannot cover children and adults):

```bash
flutter build apk --release                                # full: all five tracks
flutter build apk --release --dart-define=EDITION=school   # tracks 5–8 … 16–17 only
flutter build apk --release --dart-define=EDITION=adult    # 18+ track only
```

Give each edition its own `applicationId` (in `android/app/build.gradle.kts`) before publishing them side
by side.

### Install the APK on a phone

1. Copy `app-release.apk` to the phone (or `adb install -r build/app/outputs/flutter-apk/app-release.apk`).
2. Open it and allow "install unknown apps" for the app you opened it from.
3. Minimum Android version: 7.0 (API 24). No permissions are requested.

## Project layout

```
lib/
  main.dart, app.dart          entry point, router, MaterialApp
  core/                        l10n.dart (languages, tracks), strings.dart (UI text), theme.dart (design tokens)
  data/                        models.dart, content.dart (repository + age gating), store.dart (persistence,
                               settings, progress, educator lock), search.dart (offline FAQ search), achievements.dart
  ui/widgets.dart              shared components, mascot, artwork, confetti
  features/
    onboarding/ home/ lessons/ quiz/ labs/ library/ safety/ teacher/ settings/
assets/content/                the curriculum (JSON), see docs/CONTENT_SCHEMA.md
assets/fonts/                  Plus Jakarta Sans, Mukta (SIL OFL 1.1, licence texts included)
tools/                         validate_content.py, coverage_report.py, make_icon.py
test/, integration_test/       automated tests
docs/                          schema, coverage, QA results, review flags, school pack, Play Store pack
```

State: Riverpod (`settingsProvider`, `progressProvider`, `contentProvider`). Navigation: go_router.
Persistence: `shared_preferences` holding two versioned JSON documents (`uf.settings`, `uf.progress`) with
a migration hook in `AppStore.migrate`. All drawings are `CustomPainter` code; there are no image assets
apart from the launcher icon.

## Age tracks and gating

Every content item lists the tracks that may see it. `ContentRepository` is the single place that filters
by track (`lessonsFor`, `faqsFor`, `canOpenLesson`, `labsFor`, …) and every screen goes through it; a lesson
route for the wrong track renders a "not part of this track" page. Track choice is an age band, never a birth
date. An optional **educator lock** (Settings) restricts which tracks a device may use behind a PIN, and the
`school` edition removes the adult track at build time. The PIN is a convenience lock, not strong security.

## Localisation

- Interface text: `lib/core/strings.dart`, one row per key as `[English, Hindi, Hinglish]`. Use
  `context.t('key')`; never hard-code text in widgets. Tests fail if a key is missing or a language is empty.
- Curriculum text: every field in the JSON packs is `{ "en", "hi", "hg" }`.
- Hinglish is the default language and is written in Roman script; Hindi uses Devanagari (Mukta font).

## Maintaining content

1. Read `docs/CONTENT_SCHEMA.md` (voice, age rules, fact sheet, schemas).
2. Edit the JSON under `assets/content/` (one file per domain per type; lab and support data in `extras/`).
3. Cite only IDs from `assets/content/references.json`; add new sources there first.
4. Run `python3 tools/validate_content.py`, then `flutter test`, then `python3 tools/coverage_report.py`.
5. Record expert sign-off as described at the end of `docs/REVIEW_FLAGS.md`.

## Known limitations

- Content has had no expert review (see above). Legal content has not been checked against official texts.
- Local data sits in the app's private storage and is not separately encrypted.
- Material tooltips ("Back") and the system text-selection menu are not translated into Hindi.
- Diagrams are flat schematic drawings with a tilt effect, not true 3D models.
- Four reference URLs (India Code ×2, WCD child helpline page, NACO) did not resolve from the build
  machine on 2026-11-14 and are flagged as such in the References Center.
- The integration test covers the main journey; it does not exercise every lab on a device.

See `docs/STATUS.md` for the full implementation checklist and `docs/QA_RESULTS.md` for what was actually run.
