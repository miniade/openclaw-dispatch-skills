#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
mkdir -p "$OUT"

PKG="${SKILL_CREATOR_PKG:-}"
if [[ -z "$PKG" ]]; then
  NPM_ROOT_GLOBAL="$(npm root -g 2>/dev/null || true)"
  if [[ -n "$NPM_ROOT_GLOBAL" && -f "$NPM_ROOT_GLOBAL/openclaw/skills/skill-creator/scripts/package_skill.py" ]]; then
    PKG="$NPM_ROOT_GLOBAL/openclaw/skills/skill-creator/scripts/package_skill.py"
  elif [[ -f "$HOME/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py" ]]; then
    PKG="$HOME/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py"
  fi
fi

if [[ -z "$PKG" || ! -f "$PKG" ]]; then
  echo "Error: package_skill.py not found. Install openclaw globally or set SKILL_CREATOR_PKG." >&2
  exit 2
fi

python3 "$PKG" "$ROOT/skills/dispatch" "$OUT"
python3 "$PKG" "$ROOT/skills/dispatchi" "$OUT"
python3 "$PKG" "$ROOT/skills/cancel" "$OUT"

ls -la "$OUT"
