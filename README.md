# codeagent-eval-harness

**Did that change to your coding agent make it better or worse?**

`codeagent-eval-harness` (`ceh`) runs a coding agent on real GitHub issues from [SWE-bench Verified Mini](https://huggingface.co/datasets/MariusHobbhahn/swe-bench-verified-mini) (50 tasks), each in its own Docker sandbox. It scores every patch with SWE-bench's own tests and reports pass rate, token use, latency and **cost per solved task**. Its main feature is a diffable report between two agent or prompt versions that flags regressions:

```
$ ceh diff baseline-v1 prompt-v2
                       baseline-v1   prompt-v2     Δ
pass rate                 42.0%        46.0%     +4.0 pp
cost / solved task        $0.81        $0.74     -8.6%
p95 latency               412 s        455 s    +10.4%
fixes: 3   regressions: 1   flaky: 2   excluded: 1
REGRESSION  django__django-11099   resolved → unresolved
exit 1
```
*(Illustrative output. The harness is under construction.)*

> **Status: pre-alpha.** Only the project scaffold exists. Features are built one spec at a time; see the [roadmap](specs/README.md#roadmap).

## How it works
```
 SWE-bench Verified Mini (50 tasks)
            │
            ▼
 ┌─────────────────────┐   one fresh container per task (official image, repo at /testbed)
 │  Sandbox (Docker)   │
 └─────────┬───────────┘
           ▼
 ┌─────────────────────┐   pluggable: minimal Claude tool-use loop │ Claude Code headless
 │  Agent              │   records tokens, cost, turns, wall time
 └─────────┬───────────┘
           ▼  git diff vs base commit
 runs/<id>/tasks/*.json    ← resumable; the run phase is separate from scoring
           │
           ▼
 ┌─────────────────────┐   official SWE-bench grading (FAIL_TO_PASS + PASS_TO_PASS)
 │  Score              │
 └─────────┬───────────┘
           ▼
   report.md / summary.json  ──►  ceh diff A B  ──►  regressions, deltas, exit code
```

## Metrics
| Metric | Meaning |
|---|---|
| Pass rate | Tasks fully resolved by SWE-bench's tests ÷ tasks evaluated |
| Tokens | Input (uncached, cache write, cache read) and output, per task and total |
| Latency | Agent wall-clock per task: mean, p50, p95 |
| Cost per solved task | Total run cost (all tasks) ÷ tasks resolved |

Exact definitions and the regression rules are in [specs/000-product.md](specs/000-product.md).

## Planned usage
```bash
ceh validate                          # run gold patches once; exclude tasks broken by the environment
ceh run --config configs/minimal.yaml # agent phase (resumable)
ceh score <run_id>                    # SWE-bench grading
ceh report <run_id>                   # summary.json + report.md
ceh diff <baseline_run> <candidate_run>
```

## Requirements
- Docker Desktop. On Apple Silicon, turn on **Rosetta for x86/amd64 emulation** and allocate 8+ CPUs, 16 GB+ RAM and about 120 GB of disk. SWE-bench images are x86_64; see [ADR 0001](docs/adr/0001-local-docker-rosetta.md).
- [uv](https://docs.astral.sh/uv/) and Python 3.11+.
- `ANTHROPIC_API_KEY` exported in your shell.

## Development
```bash
uv sync
uv run pytest                          # unit tests (no Docker, no API calls)
uv run pytest --run-docker -m docker   # integration tests
uv run ruff check && uv run ruff format --check
```

The project is **spec-driven**:
1. A feature starts as a spec in [`specs/`](specs/README.md), using the template.
2. The spec gets reviewed and its status set to **Approved**.
3. It's implemented on a `spec/NNN-slug` branch, with tests written first from its acceptance criteria.

Cross-cutting decisions are recorded as ADRs in [`docs/adr/`](docs/adr/).

This repo is set up for [Claude Code](https://claude.com/claude-code): `CLAUDE.md` holds the working rules, and `.claude/` provides:
- **Skills:** `/spec-new` (drafts a spec) and `/spec-implement` (builds an Approved spec, tests first).
- **Hooks:**
  - ruff auto-format on edit
  - a block on edits to `.env*`, `uv.lock` and `runs/`
  - a spec-status banner at session start

## License
[MIT](LICENSE)
