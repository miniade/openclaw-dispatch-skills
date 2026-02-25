#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${OPENCLAW_DISPATCH_ENV:-$HOME/.config/openclaw/dispatch.env}"
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

RESULTS_BASE="${RESULTS_BASE:-$HOME/.openclaw/data/claude-code-results}"
CC_RALPH_CANCEL_BIN="${CC_RALPH_CANCEL_BIN:-$(command -v cc-ralph-cancel 2>/dev/null || echo "$HOME/.local/bin/cc-ralph-cancel")}"

if [[ $# -ne 1 ]]; then
  echo "Usage: /cancel <run-id>" >&2
  exit 2
fi

if [[ ! -x "$CC_RALPH_CANCEL_BIN" ]]; then
  echo "Error: cancel helper not found: $CC_RALPH_CANCEL_BIN" >&2
  exit 2
fi

RUN_ID="$1"
TARGET_DIR=""

if [[ "$RUN_ID" == */* ]]; then
  CANDIDATE="$RESULTS_BASE/$RUN_ID"
  if [[ -d "$CANDIDATE" ]]; then
    TARGET_DIR="$CANDIDATE"
  fi
else
  mapfile -t MATCHES < <(find "$RESULTS_BASE" -mindepth 2 -maxdepth 2 -type d -name "$RUN_ID" 2>/dev/null | sort)
  if [[ ${#MATCHES[@]} -eq 1 ]]; then
    TARGET_DIR="${MATCHES[0]}"
  elif [[ ${#MATCHES[@]} -gt 1 ]]; then
    echo "Error: run-id is ambiguous. Use <project>/<run-id>. Matches:" >&2
    printf '%s\n' "${MATCHES[@]}" >&2
    exit 2
  fi
fi

if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
  echo "Error: run-id not found: $RUN_ID" >&2
  exit 2
fi

"$CC_RALPH_CANCEL_BIN" --result-dir "$TARGET_DIR"

echo "CANCEL_SENT run_id=$RUN_ID result_dir=$TARGET_DIR"
