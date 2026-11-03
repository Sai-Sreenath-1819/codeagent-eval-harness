#!/usr/bin/env bash
# PostToolUse (Edit|Write): format and auto-fix the edited Python file with ruff.
set -euo pipefail

file=$(jq -r '.tool_response.filePath // .tool_input.file_path // empty')
[[ "$file" == *.py && -f "$file" ]] || exit 0

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
uv run --quiet ruff format --quiet "$file"
uv run --quiet ruff check --fix --quiet "$file" || true  # leftover lint issues are reported by CI, not here
