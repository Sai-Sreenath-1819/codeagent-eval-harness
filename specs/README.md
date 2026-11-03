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
| # | Spec | Status | Delivers |
|---|---|---|---|
| 000 | [Product](000-product.md) | Draft | Goals, metrics, regression rules, success criteria |
| 001 | Dataset & sandbox | — | Load Verified Mini; per-task Docker sandbox on the official images. Settles swebench v5 CLI (`swebench eval`, `--task-repo` on ARM) vs legacy `run_evaluation` |
| 002 | Gold validation | — | `ceh validate`: run gold patches, write `excluded.json` for emulation failures |
| 003 | Pricing & agent interface | — | `Agent` protocol, usage→cost, minimal Claude tool-use agent |
| 004 | Runner | — | `ceh run`: concurrent, resumable, per-task results and trajectories |
| 005 | Scoring & report | — | `ceh score` / `ceh report`: resolved flags, summary.json, report.md |
| 006 | Diff & regression gate | — | `ceh diff A B`: per-task change classes, metric deltas, Markdown, exit 1 on regression |
| 007 | Claude Code adapter | — | Headless `claude -p` agent inside the task container |
