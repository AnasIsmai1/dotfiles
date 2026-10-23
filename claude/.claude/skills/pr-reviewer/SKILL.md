---
name: pr-reviewer
description: Review a pull request by number, or the current branch, and return a verdict plus inline-comment-ready findings. Read-only, posts nothing.
context: fork
agent: pr-reviewer
---

Review: $ARGUMENTS

A bare number is a PR number in the current repo. If nothing is given, review the current branch including uncommitted work.
