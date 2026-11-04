## Summary
<!-- What does this change and why? PR title format: `type(scope): summary (spec NNN)` -->

## Spec / issue
<!-- Link the Approved spec (specs/NNN-*.md) or the issue. Docs/CI-only changes can say "n/a". -->

## How I tested it
<!-- Commands run and results. Say if Docker tests were or were not run. -->

## Checklist
- [ ] Targets an **Approved** spec, or is docs/CI/chore only
- [ ] Tests written from the acceptance criteria and passing (`uv run pytest`)
- [ ] `uv run ruff check` and `uv run ruff format --check` are clean
- [ ] No credentials, tokens, `.env` files or real run output in the diff
- [ ] No tests call a real model API
- [ ] Docs, spec status and the roadmap updated if behavior changed
