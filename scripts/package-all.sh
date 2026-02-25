#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
mkdir -p "$OUT"

PKG="${SKILL_CREATOR_PKG:-$HOME/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py}"

python3 "$PKG" "$ROOT/skills/dispatch" "$OUT"
python3 "$PKG" "$ROOT/skills/dispatchi" "$OUT"
python3 "$PKG" "$ROOT/skills/cancel" "$OUT"

ls -la "$OUT"
