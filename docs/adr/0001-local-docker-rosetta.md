# 0001 — Run official x86 SWE-bench images locally under Rosetta

**Status:** Accepted
**Date:** 2026-11-02

## Context
SWE-bench publishes per-task Docker images for x86_64. The primary dev machine is an Apple Silicon Mac. The options were:
- local Docker with Rosetta emulation
- a remote x86 executor (Modal or a cloud VM)
- an executor interface that supports both

## Decision
Run tasks in local Docker Desktop, using the official x86_64 images under Rosetta emulation. Keep the sandbox behind a small interface (start, exec, read/write file, diff, stop) so a remote executor can be added later without touching agents or scoring.

Because emulation can break tasks for reasons unrelated to the agent, a **gold validation** step (spec 002) runs every task's reference patch first. Tasks the gold patch doesn't pass are written to `excluded.json`, and metrics and diffs leave them out.

## Consequences
- Free to run and simple to set up. It needs Docker Desktop with Rosetta turned on, 8+ CPUs, 16 GB+ RAM and about 120 GB of disk.
- Slower than native x86. Concurrency stays low (around 3) and is measured, not assumed.
- Results are comparable across runs on the same machine, but not exactly to the official leaderboard. The README says so.
- Adding Modal or a VM later is a new executor behind the same interface.
