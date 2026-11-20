#!/usr/bin/env bash
# Publishes a new Android release and points the website's download page at it.
#   1. bump `version:` in pubspec.yaml (e.g. 1.3.0+4)
#   2. tools/release_apk.sh
# Builds the signed release APK (key: ~/.config/unfiltered-signing/key.properties), creates the
# GitHub release vX.Y.Z on itzshashi07/Unfiltered with UNFILTERED.apk, then updates
# website/src/data/app-release.json and pushes the website (Vercel deploys it).
# The website button links to releases/latest/download/UNFILTERED.apk, so it always serves the newest APK.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=itzshashi07/Unfiltered
WEB=website

ver_line=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION=${ver_line%%+*}
CODE=${ver_line##*+}
TAG="v$VERSION"
if gh release view "$TAG" -R "$REPO" >/dev/null 2>&1; then
  echo "Release $TAG already exists: bump the version in pubspec.yaml first." >&2
  exit 1
fi

flutter test
flutter build apk --release
APK=build/app/outputs/flutter-apk/app-release.apk
OUT=$(mktemp -d)
cp "$APK" "$OUT/UNFILTERED.apk"
SHA=$(shasum -a 256 "$OUT/UNFILTERED.apk" | cut -d' ' -f1)
SIZE=$(stat -f %z "$OUT/UNFILTERED.apk" 2>/dev/null || stat -c %s "$OUT/UNFILTERED.apk")
APKSIGNER=$(ls "$HOME"/Library/Android/sdk/build-tools/*/apksigner 2>/dev/null | tail -1)
CERT=$("$APKSIGNER" verify --print-certs "$OUT/UNFILTERED.apk" | awk '/SHA-256 digest/{print toupper($NF); exit}' | sed 's/../&:/g; s/:$//')
STORIES=$(python3 -c "import json;print(len(json.load(open('assets/content/magazine/index.json'))))")
FACTS=$(python3 -c "import json;print(sum(len(a['facts']) for a in json.load(open('assets/content/magazine/datadesk.json'))))")
TODAY=$(date +%Y-%m-%d)

cat > "$OUT/notes.md" <<EOF
**UNFILTERED $VERSION** — Real Talk. Real Science. Zero Shame.

Download **UNFILTERED.apk** below and open it on your Android phone (Android 7.0 or newer). Installing it over an earlier version keeps your progress.

SHA-256 of UNFILTERED.apk: \`$SHA\`
Signing certificate SHA-256: \`$CERT\`
EOF

git tag -a "$TAG" -m "UNFILTERED $VERSION"
git push origin "$TAG"
gh release create "$TAG" "$OUT/UNFILTERED.apk" -R "$REPO" --title "UNFILTERED $VERSION" --notes-file "$OUT/notes.md" --latest

python3 - "$WEB/src/data/app-release.json" "$VERSION" "$CODE" "$TODAY" "$SIZE" "$SHA" "$CERT" "$STORIES" "$FACTS" <<'PY'
import json, sys
p, version, code, date, size, sha, cert, stories, facts = sys.argv[1:]
d = json.load(open(p))
d.update(version=version, versionCode=int(code), date=date, sizeBytes=int(size), sha256=sha, certSha256=cert,
         stories=int(stories), facts=int(facts))
json.dump(d, open(p, "w"), indent=2)
open(p, "a").write("\n")
PY
git -C "$WEB" add src/data/app-release.json
git -C "$WEB" commit -m "Android app $VERSION on the download page"
git -C "$WEB" push origin main
echo "Released $TAG: https://github.com/$REPO/releases/tag/$TAG"
