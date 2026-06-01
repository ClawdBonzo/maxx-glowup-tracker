#!/bin/bash
# Stop hook: after each turn, if there are changes AND the app builds, commit + push to main.
# Build-gated so broken code never lands. Always exits 0 so it never blocks the session.
REPO="/Users/robgoldstein/Desktop/Maxx-GlowUp-Tracker"
cd "$REPO" || exit 0

# Nothing changed -> done.
[ -z "$(git status --porcelain)" ] && exit 0

# Build-gate: simulator build (no signing). If it fails, do NOT commit.
if ! ( cd "$REPO/MaxxApp" && xcodebuild build -scheme MaxxApp -configuration Debug \
        -sdk iphonesimulator -derivedDataPath /tmp/maxx_hook_build -quiet ) >/dev/null 2>&1; then
  echo '{"systemMessage":"⚠️ Auto-commit skipped: build is red. Fix the build, then it will push on the next turn."}'
  exit 0
fi

# Build green -> commit + push (resilient; never errors the session).
git add -A >/dev/null 2>&1
git commit -m "auto: build-verified snapshot [skip ci]" >/dev/null 2>&1
if git push origin main >/dev/null 2>&1; then
  echo '{"systemMessage":"✓ Build green — auto-committed & pushed to main."}'
else
  echo '{"systemMessage":"✓ Build green — committed locally, but git push failed (check network/auth)."}'
fi
exit 0
