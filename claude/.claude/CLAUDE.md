# Global Instructions

## Git

- Never add Claude as a co-author.
- Never mention Claude as co-author or generator in commits or PRs (no
  "Co-Authored-By", no "Generated with Claude Code" line, in either commit
  messages or PR descriptions).
- Commit subject lines must be 50 characters or fewer.

## Code

- Comments: sparse — a line or two max, not paragraph-length explanations.

## Agents & Workflows

- Findings (bugs, review issues, research claims) get an independent,
  fresh-context verifier before they are reported.
- Fix loops stop after 2 rounds with no progress; report what is left.
- `/ship` is the single SDLC front door: track → grill → plan → build/test/
  review → release. `/ship plan <req>` stops after `.pipeline/brief.md`;
  `/ship go` builds from it. Engine `team` = planner/coder/tester/pr-reviewer
  teammates; `workflow` = `ship-flow`. QA a live site: `/ship qa <url>`.
  The `agent-dash` mod (`/dash`, auto-opens per run, plus a band) shows the
  stage, agent tree, workflow runs and usage.

## Outward Sends

- Never use the email address on the Claude account for verification, test
  sends, signups, or account creation — including plus-addressed variants.
  Ask which address to use, every time.
- Always check first before any test that sends something outward: email, SMS,
  push to a real person, or a message to a third-party service.

## Installed CLI Tools

| Tool | Use for | Not for |
|---|---|---|
| Grep tool | All search (it is ripgrep) | — |
| `ast-grep` | Shape queries regex would botch; repo-wide mechanical rewrites | Name lookups |
| `git dft` | AST diffs that ignore formatting noise | — |
| `shellcheck` | Every shell script, before it ships | — |
| `yq` | YAML/TOML edits | Use instead of `sed` |

## Skills

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) — any input to knowledge
  graph. Trigger: `/graphify`. When the user types `/graphify`, use the
  installed graphify skill or instructions before doing anything else.
