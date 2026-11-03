# 000 — Product

**Status:** Draft
**Depends on:** none
**ADRs:** [0001](../docs/adr/0001-local-docker-rosetta.md), [0002](../docs/adr/0002-pluggable-agents.md), [0003](../docs/adr/0003-two-phase-run-score.md)

## Summary
A harness that answers one question cheaply and reliably: **did this change to my coding agent make it better or worse?** It runs an agent on real GitHub issues from SWE-bench Verified Mini, each in its own Docker sandbox. It scores the patches with SWE-bench's own tests and reports what each solved task cost. Two runs can be diffed, and regressions are flagged.

## Motivation
Prompt, model and harness changes to coding agents are usually judged by vibes or by expensive full-benchmark runs. A fast, reproducible 50-task loop with per-task diffs makes agent changes reviewable like code changes: "this prompt edit fixed 3 tasks, broke 1, and cost 12% more per solve."

## Goals
1. Run a pluggable coding agent on all 50 tasks of SWE-bench Verified Mini, with one isolated container per task.
2. Score each patch with the official SWE-bench grading (FAIL_TO_PASS and PASS_TO_PASS tests).
3. Report pass rate, token use, latency and cost per solved task.
4. **Diff two runs**: classify every task's change, show metric deltas, write a Markdown report that can be pasted into a PR, and exit non-zero on regressions so it can gate CI.
5. Make runs reproducible and resumable: every run records exactly what produced it.

## Non-goals (v1)
- Full SWE-bench / Verified (500 tasks), or other benchmarks. The design must not preclude them, but v1 only targets Mini.
- A web dashboard. Output is CLI tables and Markdown.
- Remote or cloud execution (Modal, x86 VMs). The executor is local Docker (ADR 0001).
- Statistical significance testing beyond repeat-based flakiness detection.
- Agents from providers other than Anthropic.

## Users
- An engineer iterating on an agent's prompt, tools or model, who wants a before/after comparison in minutes to hours rather than days.
- A reviewer who reads a diff report on a PR.

## Metric definitions
All metrics are computed over **evaluated tasks**: the selected tasks minus those in `excluded.json`, which lists tasks whose gold patch fails in this environment (spec 002).

| Metric | Definition |
|---|---|
| Resolved | SWE-bench resolution status `FULL`: every FAIL_TO_PASS and PASS_TO_PASS test passes after applying the patch. Anything else (partial, failed tests, patch didn't apply, empty patch, agent error, timeout) is **unresolved**. |
| Pass rate | resolved / evaluated tasks. Errors count in the denominator. |
| Tokens | Per task: `input` (uncached), `cache_write`, `cache_read`, `output`, reported separately and as totals. "Total input" = input + cache_write + cache_read. |
| Latency | Wall-clock seconds of the agent phase per task, from the container being ready to the agent stopping. Excludes image pull and scoring. Reported as mean, p50, p95. |
| Cost | USD per task, from API usage × the pinned price table (minimal agent), or as reported by Claude Code (`total_cost_usd`). Run cost = sum over all tasks, including unresolved ones. |
| Cost per solved task | run cost / resolved count. Shown as "n/a" when nothing is resolved. |

## Regression rules (diff of baseline A → candidate B)
- Each task falls into one class:
  - **regression**: resolved in A, unresolved in B
  - **fix**: unresolved in A, resolved in B
  - **stable-pass** or **stable-fail**: same result in both
  - **excluded**: excluded in either run
  - **flaky**: results differ across repeats of the same config (`--repeat k`)
- Flaky tasks are reported but don't count as regressions or fixes.
- **Gate:** `ceh diff` exits 1 when the number of regressions exceeds `--max-regressions` (default 0).
- Metric deltas are shown for pass rate, cost per solved task, mean and p95 latency, and total tokens. These produce warnings, not failures. A warning fires when cost per solved task or p95 latency worsens by more than `--warn-pct` (default 20%).
- A diff between runs on different task sets or datasets refuses to run unless `--allow-mismatch` is given. In that case it compares only the intersection.

## Planned CLI (details in later specs)
```
ceh validate                         # gold patches → excluded.json            (002)
ceh run --config configs/x.yaml      # agent phase, resumable                 (004)
ceh score <run_id>                   # SWE-bench grading                      (005)
ceh report <run_id>                  # summary.json + report.md               (005)
ceh diff <run_a> <run_b>             # change classes, deltas, gate           (006)
```

## Success criteria for v1
- [ ] A full 50-task run of the minimal Claude agent completes on the dev Mac, and survives being interrupted and resumed.
- [ ] `ceh report` produces every metric above. Its numbers match a hand check on 3 tasks.
- [ ] `ceh diff` of two runs with a known prompt change produces a correct Markdown report, and exits 1 on an injected regression.
- [ ] Two runs of the same config agree on at least 90% of evaluated tasks. This measures the noise floor, and the result goes in the README.
- [ ] Both agent adapters (minimal Claude, Claude Code) run through the same pipeline.

## Open questions
- **Throughput under Rosetta:** default concurrency for the agent and scoring phases. Default: 3 workers, measured in spec 004.
- **swebench version:** the v5 CLI (`swebench eval ... --task-repo`, builds images locally on ARM) or the legacy `python -m swebench.harness.run_evaluation` with prebuilt x86 images. Decided in spec 001 after checking current docs.
- **Default model and effort** for the minimal agent. Default: `claude-opus-5-5` at effort `high`, configurable per run.
- **Price table freshness:** prices are pinned in code with an "as of" date, and the manifest records them. Updating prices is a deliberate change.
