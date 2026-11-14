# UNFILTERED — Play Store preparation pack

Drafts and checklists for a human to complete. Nothing here guarantees approval: an educational purpose
does not exempt an app from Google Play policy, and sexuality education for mixed ages is a hard case.

## 1. Listing drafts

**Title (≤30):** UNFILTERED: Real Talk Health Ed

**Short description (≤80):** Honest body, puberty, consent and relationship education. Offline. Private.

**Full description (draft):**

> The things everyone wonders about, but nobody explains properly.
>
> UNFILTERED is a health and life-skills education app for Indian learners, in Hinglish, Hindi and English.
> It explains the body, puberty, periods, feelings, consent, relationships, online safety, contraception,
> STIs, the law and where to get help, with clear lessons, interactive labs, myth cards and quizzes.
>
> • Five age tracks, from body-safety basics for young children to full adult health education
> • 98 lessons, 131 myth cards, 300+ quiz questions, 26 decision-path scenarios
> • Labs: Body Lab, Puberty Lab, Period Lab, Protection Lab, Digital Safety Lab and more
> • Ask Unfiltered: private offline search over prepared answers (not an AI)
> • Safety Center with Indian helplines
> • Teacher Mode and a Parent Guide
> • Works fully offline. No account. No ads. No tracking. Nothing leaves your phone.
>
> UNFILTERED is education, not medical or legal advice. [State the real review status here.]

Do not publish the bracketed line as written, and do not claim medical review, government approval or any
endorsement that has not happened.

## 2. Suggested classification

- **Category:** Education. **Tags:** health education.
- **Content rating (IARC questionnaire):** answer honestly that the app contains educational references to
  sex, reproduction, drugs/alcohol (peer pressure), and violence/abuse prevention; no user interaction, no
  user-generated content, no location sharing, no purchases. Expect a Teen or higher rating for the full
  edition.
- **Target audience and content:** this is the key decision.
  - A listing whose target audience includes under-13s falls under the **Families Policy** and must be
    appropriate for children in full. The full edition (which includes 16–17 and 18+ material) will not fit.
  - Recommended: publish **separate listings** — a *school edition* (`--dart-define=EDITION=school`,
    tracks 5–8 to 16–17) reviewed against the Families Policy, or restricted to managed/private
    distribution to schools, and an *adult edition* (`EDITION=adult`, 18+ only) with an 18+ target
    audience. Give each its own `applicationId`.
  - Managed Google Play / private distribution to institutions avoids a public children's listing.

## 3. Health-content declaration checklist

- [ ] Declare the app as providing health **education/information** (not diagnosis, treatment or a medical device)
- [ ] In-app disclaimer present (Settings → Medical and legal disclaimer; on every lesson and answer) ✔ built
- [ ] No misleading health claims; no cures; no personalised advice ✔ by design, **needs clinician review**
- [ ] Sources cited and linked ✔ built (References Center)
- [ ] Replace "not yet reviewed" wording only after real review; keep reviewer records
- [ ] Sexual content policy: educational, non-gratifying, no pornography, diagrams schematic ✔ by design;
      a human must confirm against the current "Inappropriate Content" policy text

## 4. Data safety form (accurate for this build)

| Question | Answer |
|---|---|
| Does the app collect or share user data? | **No** |
| Data collected | None. No account, no identifiers, no analytics, no crash reporting, no ads SDK |
| Data shared with third parties | None |
| Is data encrypted in transit? | Not applicable: the app makes no network requests and has no INTERNET permission |
| Can users request deletion? | Data never leaves the device; Settings → Delete all local data, or uninstall |
| On-device storage | Language, age band, accessibility settings, lesson completion, quiz scores, bookmarks, support-circle choices, optional notes. App-private storage, not separately encrypted. `allowBackup=false` |
| Permissions | None requested. Links open in the browser and helpline numbers open in the dialer, only after a tap |

Re-check this table whenever a dependency is added.

## 5. Privacy policy

A draft is built into the app (Settings → Privacy policy; text in `lib/core/strings.dart`, keys
`legal.privacy.*`, three languages). Before release: have it reviewed by a lawyer (DPDP Act 2023 and
children's data provisions), add the publisher's name and contact details, and host the same text at a
public URL for the Play listing.

## 6. Educational content compliance checklist

- [ ] Independent medical review of all 18 domains (`docs/REVIEW_FLAGS.md`)
- [ ] Independent legal review of Indian law content; verification dates recorded per lesson
- [ ] Child-safeguarding review of tracks A–D, including scenarios and search keywords
- [ ] Hindi and Hinglish language review
- [ ] Helpline numbers and URLs re-verified on the release date
- [ ] No claim of certification or endorsement anywhere in the listing or app
- [ ] Families Policy self-certification (school edition) or 18+ target audience (adult edition)
- [ ] Accessibility pilot with assistive-technology users

## 7. Release signing

The APK built here is signed with the **Android debug key**. It installs for testing; it must not be
uploaded to Play and must not be treated as a production release.

1. Create an upload keystore **outside the repository**:
   `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties` (already ignored by git; never commit it):
   ```
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```
3. In `android/app/build.gradle.kts`, load that file, add a `signingConfigs { create("release") { … } }`
   block and point `buildTypes.release.signingConfig` at it.
4. Build `flutter build appbundle --release` and enrol in Play App Signing.
5. Verify: `apksigner verify --print-certs app-release.apk` must not show "CN=Android Debug".

## 8. Screenshot specifications

- Phone: 2–8 screenshots, 16:9 or 9:16, each side 320–3840 px (1080×1920 recommended)
- Feature graphic: 1024×500. App icon: 512×512 (`docs/icon-512.png`, original artwork)
- Suggested set: Home, Explore, a lesson, Period Lab, Myth Buster, Protection Lab (adult edition only),
  Safety Center, Teacher Mode. Do not use anatomy diagrams in store screenshots for a children's listing.
- 7-inch and 10-inch tablet screenshots if you declare tablet support

## 9. Outstanding human-review requirements

1. Medical, legal and safeguarding sign-off (not done)
2. Decide the distribution model: separate school and adult listings, or private distribution
3. Lawyer-reviewed privacy policy and terms, with publisher details
4. Production signing key and Play App Signing
5. Policy check against the current Families, Inappropriate Content and Health Content policy pages
6. Device testing on low-end phones and with TalkBack
