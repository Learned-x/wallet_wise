#!/usr/bin/env bash
set -euo pipefail

# release.sh
# Usage: ./release.sh v0.1.0
# This script creates an annotated tag and pushes it to origin, then creates a GitHub Release using gh CLI if available.

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <tag>"
  exit 1
fi

TAG=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Releasing $TAG from branch $BRANCH"

# Ensure working tree is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean. Commit or stash changes first."
  git status --porcelain
  exit 1
fi

# Fetch and ensure branch up-to-date
git fetch origin
git checkout $BRANCH
git pull --rebase origin $BRANCH

# Create annotated tag
git tag -a $TAG -m "$TAG"

echo "Pushing tag $TAG to origin"
git push origin $TAG

# Create GitHub release via gh if available
if command -v gh >/dev/null 2>&1; then
  echo "Creating GitHub release via gh"
  if [ -f CHANGELOG.md ]; then
    gh release create $TAG --title "$TAG" --notes-file CHANGELOG.md
  else
    gh release create $TAG --title "$TAG" --notes "Release $TAG"
  fi
else
  echo "gh CLI not found. Skipping release creation. You can create a release manually or install gh: https://github.com/cli/cli"
fi

echo "Release $TAG created (tag pushed)."
