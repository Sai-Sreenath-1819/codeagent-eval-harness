#!/usr/bin/env bash
# PreToolUse (Bash): refuse any push that would update main/master. Exit code 2 blocks the call.
# Rule: work on a branch and push the branch; the maintainer opens and merges the PR.
set -o pipefail

cmd=$(jq -r '.tool_input.command // empty')
[[ "$cmd" == *git* && "$cmd" == *push* ]] || exit 0

block() {
  echo "Blocked: $1 Push a branch instead and let the maintainer open the PR (see CONTRIBUTING.md)." >&2
  exit 2
}

current_branch() {
  git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Check each segment of a compound command (a && b; c | d) on its own.
while IFS= read -r seg; do
  [[ "$seg" =~ ^[[:space:]]*git([[:space:]]+(-C|-c)[[:space:]]+[^[:space:]]+)*[[:space:]]+push([[:space:]]|$) ]] || continue

  args=${seg#*push}
  positional=()
  for w in $args; do
    case "$w" in
      --all | --mirror) block "'git push $w' would update main." ;;
      -*) ;;
      *) positional+=("$w") ;;
    esac
  done

  # `git push` or `git push <remote>` with no refspec pushes the current branch.
  if (( ${#positional[@]} <= 1 )); then
    b=$(current_branch)
    [[ "$b" == main || "$b" == master ]] && block "you are on '$b' and this push would update it."
    continue
  fi

  for ((i = 1; i < ${#positional[@]}; i++)); do
    ref=${positional[$i]}
    ref=${ref#+}
    dst=${ref##*:}
    dst=${dst#refs/heads/}
    if [[ "$dst" == HEAD ]]; then
      dst=$(current_branch)
    fi
    [[ "$dst" == main || "$dst" == master ]] && block "'${positional[$i]}' targets '$dst'."
  done
done < <(printf '%s\n' "$cmd" | tr ';&|' '\n')

exit 0
