# Security policy

## Reporting a vulnerability
Please **do not open a public issue** for a security problem.

Use GitHub's private reporting: open the repository's **Security** tab and choose **Report a vulnerability**. Include what you found, how to reproduce it, and what you think the impact is. You'll get a reply as soon as the maintainer can.

The project is pre-alpha, so only the latest `main` is supported.

## Leaked credentials
If a key, token or password ends up in a commit, issue, PR or log:
1. **Revoke or rotate it immediately.** This is the only step that actually fixes the leak.
2. Tell the maintainer through the private channel above.
3. Remove it from the repository afterwards. Deleting a commit or rewriting history does not make a pushed secret safe.

## What the repo does to prevent leaks
- Pre-commit hooks (gitleaks, private-key detection) block the commit locally.
- GitHub secret scanning and push protection block known token formats at push time.
- CI scans the full git history with gitleaks on every pull request.
- Workflows use read-only tokens by default, pin third-party actions to commit SHAs, and do not run on untrusted code with secrets (no `pull_request_target`).
- `.env*` files and `runs/` output are git-ignored, and a Claude Code hook blocks edits to them.

## Scope notes
This tool runs model-generated commands inside Docker containers. Any credential you pass into a container is readable by those commands. Use scoped, low-limit keys for evaluations, and see `docs/adr/0004-provider-and-harness-agnostic.md`.
