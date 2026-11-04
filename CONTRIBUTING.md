# Contributing

Thanks for helping. This project is **pre-alpha** and built spec-first, so a short read of this page saves everyone time.

## The rules in one place
1. **Never push to `main`.** Work on a branch and open a pull request. GitHub enforces this: `main` is protected, and merging needs the `All checks` status to pass.
2. **Features start as a spec.** No code under `src/` without a spec in [`specs/`](specs/README.md) whose status is **Approved**. For a new idea, open an issue or a draft spec first.
3. **Tests first.** Write tests from the spec's acceptance criteria, then the code.
4. **Never commit credentials.** See [Secrets](#secrets-and-credentials) below.
5. **Small PRs.** One spec, or one focused change, per PR.

## Getting set up
You need [uv](https://docs.astral.sh/uv/) and Python 3.11+. Docker is only needed for the Docker integration tests.

```bash
git clone https://github.com/Sai-Sreenath-1819/codeagent-eval-harness.git
cd codeagent-eval-harness
uv sync
uv run pre-commit install        # runs the secret scan, ruff and file hygiene on every commit
```

Before opening a PR, run what CI runs:
```bash
uv run ruff check
uv run ruff format --check
uv run pytest                    # unit tests: no Docker, no network, no model API calls
uv run pre-commit run --all-files
```

## Branches, commits and pull requests
- **Branch names:** `spec/NNN-slug` for spec work, otherwise `feat/…`, `fix/…`, `docs/…`, `chore/…`, `ci/…`.
- **Commits and PR titles** use [Conventional Commits](https://www.conventionalcommits.org/) and name the spec when there is one:
  `feat(sandbox): per-task Docker sandbox (spec 001)`. Allowed types: `feat fix docs chore test refactor ci build perf revert`.
  Merges are squash merges, so **the PR title becomes the commit message on `main`**. CI checks the title.
- Fill in the PR template. Link the spec. Say how you tested it.
- Keep generated output (`runs/`, logs) out of PRs.

## What runs on every PR
All of these must pass before merging. The `All checks` job collects them, and it is the one check branch protection requires.

| Job | What it checks |
|---|---|
| lint | `ruff check` and `ruff format --check` |
| test (py3.11, py3.13) | `pytest`. Docker-marked tests are skipped; no model API is ever called |
| secret scan | gitleaks over the full git history |
| dependency audit | `pip-audit` on the locked dependencies |
| PR title | Conventional Commits format |

Also on PRs, but not required to merge:
- **CodeQL** scans the Python code and the workflow files.
- **Claude review** comments on the PR. It is advice. Read it, fix what is right, and reply where you disagree. A human maintainer makes the call.

## Specs and tests
- Use `/spec-new` (in Claude Code) or copy [`specs/_template.md`](specs/_template.md) to draft a spec. Specs are approved by the maintainer.
- Every acceptance criterion maps to a test. Unit tests use fakes and fixtures; they must not call a real model API or need Docker.
- Tests that need Docker get `@pytest.mark.docker` and run with `uv run pytest --run-docker -m docker`.
- Decisions that cut across specs go in [`docs/adr/`](docs/adr/).

## Secrets and credentials
This repo is public, and git history is forever. A secret that reaches a pushed commit must be treated as leaked.

- **Never commit** API keys, `CLAUDE_CODE_OAUTH_TOKEN`, passwords, private keys, `.env` files, or real run output that might contain them. `.env*` and `runs/` are git-ignored.
- Configs refer to credentials **by environment variable name**, never by value.
- In tests and docs use obviously fake placeholders (`YOUR_API_KEY`, `sk-fake`).
- Three layers catch mistakes: the pre-commit hook (gitleaks and `detect-private-key`) blocks the commit, GitHub push protection blocks the push, and CI scans the history of every PR.
- **If you leak a credential:** revoke or rotate it **first**. Only then clean up. Deleting the commit or rewriting history does not undo a leak, because copies and caches may exist. Tell a maintainer. See [SECURITY.md](SECURITY.md).
- Agents run model-written commands in containers that can see the credentials you pass in. Use scoped, low-limit keys for evaluations.

## Working with Claude Code
The repo is set up for [Claude Code](https://claude.com/claude-code). `CLAUDE.md` holds the working rules, and `.claude/` has hooks that format Python, protect sensitive files and block pushes to `main`, plus the `/spec-new` and `/spec-implement` skills. Using AI assistance is fine. You are responsible for what you submit.

## Maintainers: one-time setup for the Claude review
The review job needs a Claude subscription token as a repository secret. It does not use an API key.
1. In your own terminal run `claude setup-token` and copy the token it prints. Don't paste it into chat or an issue.
2. Run `gh secret set CLAUDE_CODE_OAUTH_TOKEN` and paste the token when prompted.

Until the secret exists the job skips itself. Reviews use your plan's usage. The job is skipped for PRs from forks and for Dependabot, because GitHub does not give those runs secrets.

## License
By contributing you agree that your contributions are licensed under the [MIT License](LICENSE).
