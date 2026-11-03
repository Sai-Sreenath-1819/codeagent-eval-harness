---
name: spec-implement
description: Implement one Approved spec end to end — branch, failing tests from the acceptance criteria, implementation, checks, spec status update, commit — then stop for review. Use when the user says "implement spec 001", "/spec-implement 001", or "build the approved spec".
---

# spec-implement

Implement exactly one spec from `specs/`. Argument: the spec number or file name.

## Preconditions (refuse if any fails)

- The spec file exists and its status line is `**Status:** Approved`. If it is Draft, stop and tell the user it needs approval first.
- The working tree is clean (`git status`). If not, stop and ask.
- Every spec listed under "Depends on" is Implemented.

## Steps

1. **Branch:** `git switch -c spec/NNN-slug` from `main`. Set the spec status to `In Progress`.
2. **Tests first.** For each acceptance criterion, write the test(s) the Test plan names, in `tests/`. Run `uv run pytest` and confirm the new tests fail for the right reason.
   - Tests needing Docker get `@pytest.mark.docker`. Tests must never call the real Anthropic API; use fakes or recorded fixtures.
3. **Implement** in `src/ceh/` until the tests pass. Stay inside the spec's scope; anything extra goes under the spec's Open questions or a follow-up note, not into the code.
   - Add runtime dependencies with `uv add <pkg>`, only those the spec names.
   - Check current library APIs with Context7 or the `claude-api` skill rather than memory.
4. **Checks:** `uv run ruff check`, `uv run ruff format --check`, `uv run pytest`. All must pass. If the spec has Docker acceptance criteria and Docker is running, also run `uv run pytest --run-docker -m docker` and report the result honestly.
5. **Update the spec:** tick each acceptance criterion that is met, note any deviation under a "Implementation notes" heading, and set the status to `Implemented`. Update the roadmap table in `specs/README.md`.
6. **Commit** with Conventional Commits naming the spec, e.g. `feat(sandbox): per-task Docker sandbox (spec 001)`. Split into a few logical commits if that reads better (tests, implementation, docs).
7. **Stop for review.** Report what was built, the test results, and any deviations. Never merge into `main` and never push; the user does that.
