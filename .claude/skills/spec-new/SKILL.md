---
name: spec-new
description: Draft a new feature spec in specs/ from the template, status Draft. Use when the user says "new spec", "write a spec for X", "/spec-new 001-dataset-sandbox", or wants to start a roadmap item. Never writes implementation code.
---

# spec-new

Create `specs/NNN-slug.md` for one roadmap item. This skill produces a document, not code.

## Steps

1. **Pick the number and slug.** If the user gave `NNN-slug`, use it. Otherwise take the next free number in `specs/` and a short kebab-case slug. Check the roadmap table in `specs/README.md` for the intended scope of that number.
2. **Read context first:** `specs/000-product.md`, `specs/README.md`, the ADRs in `docs/adr/`, and any spec this one depends on. The new spec must not contradict an Approved spec or an Accepted ADR; if it needs to, say so under Open questions.
3. **Copy `specs/_template.md`** to the new path and fill every section:
   - **Acceptance criteria** are a checklist of observable, testable statements ("`ceh diff A B` exits 1 when any task goes pass→fail"). Each one must map to at least one test in the Test plan.
   - **Interfaces** show exact signatures, CLI flags and file formats, so the implementation has no guesswork.
   - **Non-goals** list what's deliberately left out.
   - For any library or external tool (swebench, docker SDK, anthropic, Claude Code CLI), check current behavior with Context7 or the `claude-api` skill before writing it into the spec, and note the version checked.
4. **Ask only for what's genuinely missing.** Use sensible defaults and record them under Open questions instead of interrogating the user.
5. Set `**Status:** Draft` and add the spec to the roadmap table in `specs/README.md`.
6. **Stop.** Summarize the spec in a few lines and ask the user to review it. Do not create a branch, write code, or mark it Approved — only the user approves.
