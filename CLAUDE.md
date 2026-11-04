# CLAUDE.md

## Project
`codeagent-eval-harness` (package `ceh`) runs a coding agent on SWE-bench Verified Mini (50 tasks), one Docker container per task. It scores each patch with the official SWE-bench test harness and reports pass rate, tokens, latency and cost per solved task. The key feature is `ceh diff runA runB`, which compares two agent, prompt or model versions and flags regressions. See `specs/000-product.md`.

Status: pre-alpha. Only the scaffold exists; features land one spec at a time.

## Working rules (spec-driven)
- **A request for a plan means a plan, not code.** Don't write implementation code until the user explicitly says to implement.
- **No code under `src/` without an Approved spec.** New work starts with `/spec-new`; implementation goes through `/spec-implement` on a spec whose status is `Approved`. Only the user approves specs.
- Tests are written first, from the spec's acceptance criteria.
- **Never push to `main`, and never commit to it.** Always work on a branch (`spec/NNN-slug` for specs, otherwise `docs/…`, `chore/…`, `ci/…`, `fix/…`) and push that branch. The maintainer opens and merges the PR; don't run `gh pr merge` or create the PR unless asked. A hook blocks pushes to `main`, and GitHub branch protection enforces it.
- Before pushing, run `uv run ruff check`, `uv run ruff format --check`, `uv run pytest` and `uv run pre-commit run --all-files`. CI runs the same, plus a gitleaks scan of the full history, a dependency audit and a PR-title check; the required check is `All checks`.
- **Never put a credential in a commit, a test, a fixture, a doc or a log.** Use obvious placeholders (`YOUR_API_KEY`). If a secret ever lands in a commit, tell the user to revoke it first; rewriting history does not fix a leak. See `CONTRIBUTING.md` and `SECURITY.md`.
- Conventional Commits naming the spec, e.g. `feat(diff): regression gate (spec 007)`.
- Decisions that cut across specs go in `docs/adr/NNNN-title.md`.

## Layout
```
src/ceh/        package (grows per spec)
tests/          pytest; `@pytest.mark.docker` tests run only with --run-docker
specs/          product spec, process, template, one spec per milestone
docs/adr/       architecture decision records
.claude/        project settings, hooks, skills (spec-new, spec-implement)
runs/           eval outputs (gitignored, written only by the harness)
```

## Commands
```bash
uv sync                              # install / update the env
uv run pre-commit install            # once: secret scan + ruff + hygiene on every commit
uv run pytest                        # unit tests (no Docker, no API calls)
uv run pytest --run-docker -m docker # Docker integration tests
uv run ruff check && uv run ruff format --check
```

## Conventions
- Python 3.11+ (dev on 3.13), managed with uv. Add dependencies with `uv add`, never by editing `uv.lock`.
- Ruff for formatting and lint (a hook formats edited `.py` files automatically). Line length 100.
- Pydantic models for anything written to disk. Run artifacts are JSON under `runs/<run_id>/`.
- Unit tests never call a real model API or need Docker. Use fakes and fixtures.
- Check current library APIs with Context7 (swebench, docker, datasets) and the `claude-api` skill (Anthropic SDK, model IDs, pricing) rather than memory.

## Environment notes
- Dev machine is Apple Silicon. SWE-bench images are x86_64 and run under Docker Desktop's Rosetta emulation (ADR 0001). Some tasks may fail because of emulation, so the gold-patch validation step (spec 002) excludes them.
- Provider credentials (API keys, `CLAUDE_CODE_OAUTH_TOKEN`) come from environment variables that the run config names. Config files and manifests never contain secret values. Never read or write `.env` files (a hook blocks it).
- The harness must not assume paid Anthropic access (ADR 0004). Token usage and cost are optional fields and show "n/a" when unknown. The Claude Code adapter passes either a subscription token or an API key into the container, never both.
