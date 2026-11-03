# 0002 — Pluggable agents behind one protocol

**Status:** Accepted
**Date:** 2026-11-02

## Context
We want to evaluate two kinds of agent:
- a minimal tool-use loop on the Claude API, which is cheap, transparent and easy to A/B on prompt or model
- Claude Code in headless mode, which is closer to real-world use

Both must produce comparable results.

## Decision
Define one `Agent` protocol. Given a task, a started sandbox and a run config, it drives the agent until it stops and returns accounting: usage, cost, turns and stop reason. The **harness**, not the agent, collects the patch (a `git diff` of the repo against the base commit), so every agent is scored the same way.

Adapters:
1. **minimal_claude**: a manual Messages API loop with the Anthropic-defined bash and text-editor tools, executed through `sandbox.exec`. Usage is read per turn and priced from a pinned table.
2. **claude_code**: installs the CLI in the task container and runs `claude -p --output-format json`. It runs as a non-root user, because the CLI refuses `--dangerously-skip-permissions` as root. Usage and cost come from its JSON result.

## Consequences
- New agents are one adapter file plus a registry entry.
- Cost accounting differs by source: our own price table for minimal_claude, Claude Code's own `total_cost_usd` for claude_code. The manifest records which source was used.
- Agents never see the host filesystem. The container is the isolation boundary.
