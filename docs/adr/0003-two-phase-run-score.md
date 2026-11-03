# 0003 — Separate run and score phases; per-task results on disk

**Status:** Accepted
**Date:** 2026-11-02

## Context
Running the agent costs money and time. Scoring is deterministic but slow under emulation. A crash midway through a 50-task run shouldn't mean paying for the agent work again.

## Decision
- **Run** phase: for each task, start the sandbox, run the agent, collect the patch, and write `runs/<run_id>/tasks/<instance_id>.json` plus a trajectory file. Tasks whose result file already exists are skipped, so re-running the same command resumes.
- **Score** phase: write `predictions.jsonl` from the task results, call the SWE-bench harness, and record `resolved` on each task result.
- **Report** and **diff** read only these files.
- `manifest.json` records the config and a hash of it, a hash of the prompt file, the model ID, the harness git SHA, the swebench version, the price table version and timestamps.

## Consequences
- Scoring can be re-run, or upgraded, without re-running agents.
- Reports and diffs are pure functions of files on disk, which makes them easy to unit-test with fixture runs.
- Disk use grows with trajectories. `runs/` is gitignored.
