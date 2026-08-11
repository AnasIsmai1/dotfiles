# Global Instructions

## Git

- Never add Claude as a co-author.
- Commit subject lines must be 50 characters or fewer.

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
