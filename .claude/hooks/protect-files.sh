#!/usr/bin/env bash
# PreToolUse (Edit|Write): block edits to secrets, the lockfile, and eval outputs.
# Exit code 2 blocks the tool call and shows stderr to Claude.
set -euo pipefail

file=$(jq -r '.tool_input.file_path // empty')
[[ -n "$file" ]] || exit 0

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
rel="${file#"$root"/}"

case "$rel" in
  .env | .env.* | */.env | */.env.*)
    echo "Blocked: $rel holds secrets. Ask the user to edit it themselves." >&2
    exit 2 ;;
  uv.lock)
    echo "Blocked: change uv.lock with 'uv add' / 'uv lock', not by hand." >&2
    exit 2 ;;
  runs/*)
    echo "Blocked: runs/ holds eval outputs written by the harness; don't edit them by hand." >&2
    exit 2 ;;
esac
exit 0
