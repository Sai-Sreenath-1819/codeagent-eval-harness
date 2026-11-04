# 0004 — Provider- and harness-agnostic by design

**Status:** Accepted
**Date:** 2026-11-03
**Amends:** [0002](0002-pluggable-agents.md)

## Context
ADR 0002 assumed a paid Anthropic API key. Many people who would use this harness don't have one. They may have only a Claude subscription, a free API tier (Gemini, OpenRouter, Groq and similar), a local model server (Ollama, LM Studio), or a different agent CLI that they already use. If the harness only works with paid Anthropic credits, those people can't use it at all.

Checked against the Claude Code docs (2026-11):
- `claude setup-token` prints a long-lived OAuth token. Exporting it as `CLAUDE_CODE_OAUTH_TOKEN` authenticates headless runs with a Pro, Max, Team or Enterprise subscription.
- In `-p` mode, a present `ANTHROPIC_API_KEY` is **always** used and overrides the subscription.

## Decision
Make the harness flexible at three independent layers.

### 1. Agent harness: what drives the task
The `Agent` protocol from ADR 0002 stays. The adapters become:
- **minimal**: our own tool-use loop. The model comes from a provider (layer 2).
- **claude_code**: headless `claude -p` in the container. It authenticates with either `CLAUDE_CODE_OAUTH_TOKEN` (subscription) or `ANTHROPIC_API_KEY`. The adapter passes exactly one of them into the container, and never passes the API key when subscription auth is wanted.
- **command**: a generic adapter for any other CLI agent (Aider, SWE-agent, OpenHands, Codex CLI, Gemini CLI and so on). The run config gives a command template that runs inside the task container. The harness still collects the `git diff` itself, so every agent is scored the same way. An optional usage parser (regex or JSON path) pulls token counts or cost from the agent's output. Without one, those fields are "n/a".

### 2. Model provider: which model the minimal agent calls
A small `Provider` protocol takes messages and tool definitions and returns a normalized response with optional usage. Two implementations:
- **openai_compatible**: configured with `base_url`, `api_key_env` and `model`. This one adapter covers Ollama, LM Studio, OpenRouter, Groq, Gemini's OpenAI-compatible endpoint, OpenAI, and any gateway that speaks that API.
- **anthropic**: the Anthropic Messages API.

The minimal agent defines its tools (shell command, file view, create, string-replace) as plain JSON-schema functions, not Anthropic's built-in tool types. That way the same tools work on every provider.

### 3. Credentials
Run configs name environment variables and never contain secret values. The manifest records the provider, the base URL's host, the model and the auth mode (`api_key`, `subscription` or `none`), and never the secret.

### Accounting when data is missing
- Token usage fields are optional. A task result may have no token counts at all.
- Cost comes from, in order: the price table (when the model is listed), cost reported by the agent, or "unknown". Local and free-tier models are priced at $0, set explicitly in the config.
- When cost is unknown, "cost per solved task" shows "n/a". The report adds **tokens per solved task** (when tokens are known) and **solved tasks per hour** so runs without prices can still be compared.

### Free tiers and subscriptions have limits
- The runner supports per-run `max_concurrency` and `requests_per_minute`, and retries with backoff on HTTP 429.
- If a limit stops a run (a subscription's usage cap, a free tier's daily quota), affected tasks get the stop reason `rate_limited`. The run stays resumable, as in ADR 0003.

### Comparability
`ceh diff` prints the manifest differences between the two runs. If the provider, model or agent differs, it warns that the comparison mixes causes. It does not refuse to run.

## Consequences
- More people can run it: Claude subscribers, free-tier users, local-model users, and people committed to another agent CLI.
- More adapters to test. Unit tests use fakes only, with no network and no real model.
- Small or free models may resolve very few tasks. The pipeline still works, but pass rates will be low and noisy. The README says so plainly.
- Containers need network access to the provider. A host-local server (Ollama) is reached through `host.docker.internal`.
- **Security:** the agent's shell can read environment variables in its container, so a model-written command could read the key or token. The container is throwaway, but the credential is real. Users should prefer scoped, low-limit API keys. The subscription token has account-wide scope, so the README warns about it.
- Specs 003 and later change accordingly (see the roadmap in `specs/README.md`).
