#!/usr/bin/env bash
set -euo pipefail

# Publish all skills in this repo to ClawHub.
#
# Inputs via env:
#   VERSION      (required, semver, e.g. 1.0.0)
#   SLUG_PREFIX  (default: miniade-)
#   TAGS         (default: latest)
#   CHANGELOG    (default: "release <VERSION>")
#   DRY_RUN      (default: false)
#
# Requires:
#   - clawhub CLI installed
#   - authenticated session (e.g., clawhub login --token ...)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${VERSION:-}"
SLUG_PREFIX="${SLUG_PREFIX:-miniade-}"
TAGS="${TAGS:-latest}"
CHANGELOG="${CHANGELOG:-release ${VERSION:-unknown}}"
DRY_RUN="${DRY_RUN:-false}"

if [[ -z "$VERSION" ]]; then
  echo "Error: VERSION is required (env)." >&2
  exit 2
fi

if ! command -v clawhub >/dev/null 2>&1; then
  echo "Error: clawhub CLI not found in PATH" >&2
  exit 2
fi

publish_one() {
  local skill_dir="$1"
  local slug="$2"
  local name="$3"

  local cmd=(clawhub publish "$skill_dir"
    --slug "$slug"
    --name "$name"
    --version "$VERSION"
    --changelog "$CHANGELOG"
    --tags "$TAGS"
    --no-input)

  if [[ "$DRY_RUN" == "true" || "$DRY_RUN" == "1" ]]; then
    echo "[DRY_RUN] ${cmd[*]}"
    return 0
  fi

  echo "Publishing: $slug ($skill_dir) version=$VERSION tags=$TAGS"
  "${cmd[@]}"
}

publish_one "skills/dispatch"  "${SLUG_PREFIX}dispatch"  "Dispatch (Claude Code)"
publish_one "skills/dispatchi" "${SLUG_PREFIX}dispatchi" "Dispatchi (Ralph Loop)"
publish_one "skills/cancel"    "${SLUG_PREFIX}cancel"    "Cancel Dispatch Run"

echo "Done."
