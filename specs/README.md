# Specs

This project is built spec-first. Every feature starts as a spec here, gets approved, and only then gets implemented.

## Lifecycle
| Status | Meaning | Who sets it |
|---|---|---|
| Draft | Written, under review | author (`/spec-new`) |
| Approved | Reviewed; ready to build | the maintainer, by editing the status line |
| In Progress | Branch `spec/NNN-slug` open | `/spec-implement` |
| Implemented | Acceptance criteria met, tests pass, merged | `/spec-implement`, then merge |
| Superseded | Replaced by a later spec | author |

## Rules
- One spec per milestone, small enough to build and review in one sitting.
- Acceptance criteria are testable statements; each one maps to a test in the spec's Test plan.
- A spec that would contradict an Accepted ADR needs a new ADR first.
- Implementation that departs from the spec goes in the spec's "Implementation notes", and the spec is updated.

## Roadmap
Reordered on 2026-11-03 for [ADR 0004](../docs/adr/0004-provider-and-harness-agnostic.md): a minimal agent with a free provider comes early, so the pipeline can be tested end to end without paid credits.

| # | Spec | Status | Delivers |
|---|---|---|---|
| 000 | [Product](000-product.md) | Draft | Goals, metrics, regression rules, success criteria |
| 001 | Dataset & sandbox | — | Load Verified Mini; per-task Docker sandbox on the official images. Settles swebench v5 CLI (`swebench eval`, `--task-repo` on ARM) vs legacy `run_evaluation` |
| 002 | Gold validation | — | `ceh validate`: run gold patches, write `excluded.json` for emulation failures |
| 003 | Agent interface & accounting | — | `Agent` protocol; optional token usage; cost from price table, agent-reported, or unknown ("n/a") |
| 004 | Minimal agent & providers | — | Provider-neutral tool loop; `openai_compatible` provider (Ollama, OpenRouter, Groq, Gemini and others) first, then `anthropic` |
| 005 | Runner | — | `ceh run`: concurrent, resumable, per-task results and trajectories; rate limiting and 429 backoff |
| 006 | Scoring & report | — | `ceh score` / `ceh report`: resolved flags, summary.json, report.md; tolerates missing usage |
| 007 | Diff & regression gate | — | `ceh diff A B`: per-task change classes, metric deltas, comparability warning, Markdown, exit 1 on regression |
| 008 | Generic command adapter | — | Run any CLI agent in the container from a command template; optional usage parser |
| 009 | Claude Code adapter | — | Headless `claude -p` in the container; subscription token or API key, never both |
