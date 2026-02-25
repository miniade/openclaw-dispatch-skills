#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${OPENCLAW_DISPATCH_ENV:-$HOME/.config/openclaw/dispatch.env}"
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

REPOS_ROOT="${REPOS_ROOT:-$HOME/repos}"
LAUNCH_LOG_DIR="${LAUNCH_LOG_DIR:-$HOME/.openclaw/data/dispatch-launch}"
CC_DISPATCHI_BIN="${CC_DISPATCHI_BIN:-$(command -v cc-dispatchi 2>/dev/null || echo "$HOME/.local/bin/cc-dispatchi")}"
DISPATCHI_MAX_ITERATIONS="${DISPATCHI_MAX_ITERATIONS:-20}"
DISPATCHI_COMPLETION_PROMISE="${DISPATCHI_COMPLETION_PROMISE:-COMPLETE}"
DISPATCH_PERMISSION_MODE="${DISPATCH_PERMISSION_MODE:-bypassPermissions}"

if [[ $# -lt 3 ]]; then
  echo "Usage: /dispatchi <project> <task-name> <prompt...>" >&2
  exit 2
fi

if [[ ! -x "$CC_DISPATCHI_BIN" ]]; then
  echo "Error: cc-dispatchi binary not found: $CC_DISPATCHI_BIN" >&2
  exit 2
fi

PROJECT="$1"
TASK_NAME="$2"
shift 2
PROMPT="$*"

WORKDIR="${REPOS_ROOT}/${PROJECT}"
mkdir -p "$WORKDIR"
mkdir -p "$LAUNCH_LOG_DIR"

RUN_ID="$(date -u +%Y%m%d-%H%M%S)-${PROJECT}-${TASK_NAME}-interactive"
RUN_LOG="$LAUNCH_LOG_DIR/${RUN_ID}.log"

CMD=("$CC_DISPATCHI_BIN"
  -n "$TASK_NAME"
  -w "$WORKDIR"
  -p "$PROMPT"
  --max-iterations "$DISPATCHI_MAX_ITERATIONS"
  --completion-promise "$DISPATCHI_COMPLETION_PROMISE"
  --permission-mode "$DISPATCH_PERMISSION_MODE"
)

nohup "${CMD[@]}" >"$RUN_LOG" 2>&1 &
PID=$!

echo "DISPATCHI_STARTED pid=$PID project=$PROJECT task=$TASK_NAME workdir=$WORKDIR run_id=$RUN_ID log=$RUN_LOG max_iter=$DISPATCHI_MAX_ITERATIONS completion=$DISPATCHI_COMPLETION_PROMISE"
