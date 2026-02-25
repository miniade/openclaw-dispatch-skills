#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <workspace-skills-dir>" >&2
  echo "Example: $0 /home/miniade/.openclaw/workspace-coder/skills" >&2
  exit 2
fi

TARGET="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$TARGET"

for s in dispatch dispatchi cancel; do
  rm -rf "$TARGET/$s"
  cp -a "$ROOT/skills/$s" "$TARGET/$s"
  echo "Synced: $s"
done

echo "Done. Skills synced to: $TARGET"
