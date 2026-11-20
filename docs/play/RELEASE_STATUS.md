# Google Play release status — UNFILTERED

Last updated 2026-11-15. Statuses below are what Play Console showed, not predictions.

| Item | Value |
|---|---|
| Play Console app | https://play.google.com/console/u/0/developers/7312544108262210836/app/4972370763243561891/app-dashboard |
| Developer account | Shashi Digital Labs (personal account) |
| Package name | `app.unfiltered.learn` |
| Edition | Adult, 18+ only (`--dart-define=EDITION=adult`) |
| Version | 1.0.0, version code 1 |
| Bundle | `dist/UNFILTERED-adult-1.0.0-1.aab` (57.6 MB) |
| Target / min SDK | 36 / 24; native libraries 16 KB aligned |
| Permissions | none needing user approval; no INTERNET permission |
| Privacy policy | https://itzshashi07.github.io/unfiltered-privacy/ (built by `tools/build_privacy_page.py`) |
| Store assets | `docs/play/store/` (icon, feature graphic, 5 screenshots); listing text in `docs/play/listing-en-IN.md` |

## Signing

- Upload key: `~/.config/unfiltered-signing/upload-keystore.jks` (RSA 4096, alias `upload`), settings in
  `~/.config/unfiltered-signing/key.properties`, password also in the macOS Keychain item
  "UNFILTERED Play upload keystore password". Outside Git; back it up somewhere safe.
- Upload certificate SHA-256: `80:5B:04:A7:E8:A0:4F:51:E3:91:13:5C:B7:69:04:7D:2B:DF:7F:B8:08:50:D8:51:9B:61:88:FB:67:E1:38:C3`
- Play App Signing: on ("Releases are signed by Google Play"). Google holds the app-signing key; a lost
  upload key can be reset through Play Console.
- `android/app/build.gradle.kts` refuses to build a release without this key.

## Play Console state

- Done: privacy policy, ads (none), sign-in details (no restrictions), content rating (IARC, educational
  product), target audience 18+ with "restrict users determined to be minors", Data safety (no data
  collected or shared), Advertising ID (no), government app (no), financial features (none), health apps
  (Reproductive and sexual health; Medical reference and education), category Education, contact email,
  default store listing (en-IN) with AI label on screenshot 1.
- Closed testing track "Closed testing - Alpha": India; tester list "UNFILTERED 18+ closed testers"
  (1 tester: the account owner); release "1 (1.0.0) adult edition".
- 2026-11-15: bundle version code 1 uploaded by the owner. The 14 pending changes (closed testing release,
  store listing, declarations) were **submitted for review**; Publishing overview shows "Changes in
  review", with Google's quick checks running first. Not approved yet, not in production, not published.
- Automatic protection (installer check) is on ("Enhanced" bundle). The delivered app's permissions are
  only `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` and `com.android.vending.CHECK_LICENSE`: still no
  INTERNET permission, so "does not request internet access" stays accurate.

## Remaining steps

1. Wait for the closed-testing review (usually up to 7 days, sometimes longer). Fix and resubmit only if
   Google reports a specific problem; do not resubmit an unchanged build.
2. Add at least 12 real adult testers to the tester list. They must opt in from the testing link and stay
   opted in for 14 continuous days. Then apply for production access from the dashboard.
3. Declare trader status (Play deadline February 2027).
4. Decide on the content corrections in `docs/play/PENDING_CONTENT_REVIEW.md` and on expert review.
