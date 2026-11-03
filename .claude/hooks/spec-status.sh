#!/usr/bin/env bash
# SessionStart: print the current branch and each spec's status so every session
# starts knowing what is approved and in progress. Stdout is added to Claude's context.
set -o pipefail  # no -u: macOS bash 3.2 treats an empty array as unbound

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$root" || exit 0

echo "Branch: $(git branch --show-current 2>/dev/null || echo '?')"
echo "Specs:"
shopt -s nullglob
specs=(specs/[0-9][0-9][0-9]-*.md)
if (( ${#specs[@]} == 0 )); then
  echo "  (none yet)"
fi
for f in "${specs[@]}"; do
  status=$(grep -m1 -E '^\*\*Status:\*\*' "$f" | sed -E 's/^\*\*Status:\*\* *//')
  printf '  %-40s %s\n' "$(basename "$f" .md)" "${status:-unknown}"
done
echo "Rule: implement only specs with status Approved (use /spec-implement)."
