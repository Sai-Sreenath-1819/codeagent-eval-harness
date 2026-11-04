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
 ┌─────────────────────┐   pluggable: minimal loop (any model) │ Claude Code │ any CLI agent
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

## No paid API credits? That's fine
The harness is designed so it doesn't depend on any one model provider or agent tool ([ADR 0004](docs/adr/0004-provider-and-harness-agnostic.md)). Planned ways to run it:

| You have | Use |
|---|---|
| A local model server (Ollama, LM Studio) | Built-in minimal agent, OpenAI-compatible provider, $0 |
| A free API tier (Gemini, OpenRouter, Groq and similar) | Built-in minimal agent, OpenAI-compatible provider |
| A Claude Pro/Max/Team/Enterprise subscription | Claude Code adapter with a token from `claude setup-token` (no API key) |
| Another agent CLI (Aider, SWE-agent, OpenHands, Codex CLI, Gemini CLI...) | Generic command adapter |
| An Anthropic or OpenAI API key | Built-in minimal agent, or Claude Code with the key |

Things to know:
- Small or free models may solve very few of the 50 tasks. The pipeline still works, but scores will be low and noisy.
- Free tiers and subscriptions have rate or usage limits. Runs are resumable, so a limit stops a run instead of ruining it.
- When a provider reports no prices or token counts, those columns show "n/a". Tokens per solved task and solved tasks per hour still let you compare runs.
- Your credentials are visible to the agent's shell inside its container. Prefer scoped, low-limit keys. A subscription token has account-wide scope, so treat it as sensitive.

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
- Something to drive the agent, from the table above: a local model, a free API key, a Claude subscription, or another agent CLI. Credentials go in environment variables that the run config names.

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

## Contributing
All changes go through pull requests: `main` is protected, and a PR needs the `All checks` status to pass (lint, tests, a secret scan of the full history, a dependency audit and a PR-title check). A Claude review bot comments on each PR. See [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow and [SECURITY.md](SECURITY.md) for reporting vulnerabilities or leaked credentials.

## License
[MIT](LICENSE)
