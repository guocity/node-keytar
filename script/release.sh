#!/usr/bin/env bash
#
# Release helper: bump the version, commit, create a matching vX.Y.Z tag and
# push it. Pushing the tag is what triggers the CI workflow to build prebuilds
# and publish to npm (via OIDC trusted publishing).
#
# Usage:
#   script/release.sh [patch|minor|major]   Bump version, tag, and push (default: patch)
#   script/release.sh current                Tag the version already in package.json and push
#
set -euo pipefail

cd "$(dirname "$0")/.."

BUMP="${1:-patch}"

# --- safety checks -----------------------------------------------------------
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "$BRANCH" != "master" ]; then
  echo "Error: releases must be cut from 'master' (currently on '$BRANCH')." >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Error: working tree is not clean. Commit or stash changes first." >&2
  exit 1
fi

git fetch origin master --tags --quiet
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]; then
  echo "Error: local master is out of sync with origin/master. Pull/push first." >&2
  exit 1
fi

# --- tag + push --------------------------------------------------------------
if [ "$BUMP" = "current" ]; then
  # Tag the version already present in package.json (no bump).
  TAG="v$(node -p "require('./package.json').version")"
  if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: tag $TAG already exists." >&2
    exit 1
  fi
  git tag "$TAG"
  git push origin "$TAG"
  echo "Pushed tag $TAG. CI will publish to npm."
else
  # npm version updates package.json + package-lock.json, makes a commit, and
  # creates a vX.Y.Z tag (tag-version-prefix defaults to 'v').
  TAG="$(npm version "$BUMP" -m "Release %s")"
  git push origin master --follow-tags
  echo "Bumped and pushed $TAG. CI will publish to npm."
fi
