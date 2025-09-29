#!/usr/bin/env bash
set -euo pipefail

# create-github-release.sh
# Create a GitHub release with all template zip files
# Usage: create-github-release.sh <version>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

VERSION="$1"

# Remove 'v' prefix from version for release title
VERSION_NO_V=${VERSION#v}

gh release create "$VERSION" \
  .genreleases/dev-flow-template-copilot-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-copilot-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-claude-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-claude-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-gemini-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-gemini-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-cursor-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-cursor-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-opencode-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-opencode-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-qwen-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-qwen-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-windsurf-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-windsurf-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-codex-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-codex-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-kilocode-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-kilocode-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-auggie-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-auggie-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-roo-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-roo-ps-"$VERSION".zip \
  .genreleases/dev-flow-template-droid-sh-"$VERSION".zip \
  .genreleases/dev-flow-template-droid-ps-"$VERSION".zip \
  --title "Spec Kit Templates - $VERSION_NO_V" \
  --notes-file release_notes.md