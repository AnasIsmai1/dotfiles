---
description: One SDLC front door. Track → grill → plan → build/test/review (agent team or workflow) → release. `plan <req>` stops after the brief; `go` builds from it.
argument-hint: <request> | plan <request> | go | qa <url> [flows...]
---

Ship this: $ARGUMENTS

## 0. Route
- Starts with `plan `: run steps 1–4 on the rest, set status stage `brief`, tell me to run `/ship go`, and **stop**.
- Exactly `go`: read `.pipeline/brief.md` (if it's missing, say so and stop), take `Track:` and `Engine:` from it, and jump to step 5.
- Anything else: run every step.

**Status.** At every stage change, write `.pipeline/status.json`:
`{"track","engine","stage","round","verdict","updated"}`
- `stage` is one of `grill|plan|brief|spec|build|test|review|verify|release|done`.
- `verdict` is one of `null|SHIP|NEEDS WORK|BLOCK|NEEDS ANSWERS`.
- Only this session writes it; the agent-dash mod reads it.

## 1. Scout and pick a track
Read just enough to ground the request: the files it touches, how tests run, and any UI URL. If `graphify-out/graph.json` exists, query it instead of reading files blind.

| Track | When | Plan step | Default engine |
|---|---|---|---|
| **qa** | Test a live site, no code change (`qa ...`, or a URL plus flows) | none; go to step 5 | qa-run workflow |
| **fix** | A bug, or a small change to 1–3 files | grill only | workflow |
| **feature** | New behaviour with several user stories, or a change across modules | grill, then PRD | team |
| **interface** | A new module, API, or public function shape | grill, then design it twice | team |
| **refactor** | Restructuring with no change in behaviour | refactor-plan interview | team |

Round 1 of the grill opens with two questions:
- **Track:** recommend your pick.
- **Engine:** `team` (planner, coder, tester and reviewer as live teammates you can watch and message; costs more) or `workflow` (one-shot `ship-flow`; cheaper). Recommend the track's default.

## 2. Grill (every track except qa)
Use the `grilling` skill. Ask with AskUserQuestion, at most 4 questions per round and at most 2 rounds, recommended answer first. Ask only what would change the build: scope edges, acceptance criteria (what proves it works), data, auth, money, outward sends, and what's out of scope. Skip anything the code already answers. If domain terms clash with the names in the code, pick one name per concept (the `ubiquitous-language` approach), inline.

## 3. Plan step (by track)
Read the named skill's SKILL.md and follow its process, with these overrides. **Never publish to an issue tracker or GitHub unless I say so.** Write to `.pipeline/` instead.
- **feature**: follow `~/.claude/skills/to-prd/SKILL.md`. Use its template, keep it ponytail-lean, and confirm the test seams with me. Save it to `.pipeline/prd.md`. If the PRD holds more than one shippable slice, split it the way `to-issues` does, into vertical slices, and ship the first slice only. List the rest under "Next slices".
- **interface**: follow `~/.claude/skills/design-an-interface/SKILL.md`. Run 3 design agents in parallel with radically different constraints, and make one of them "the smallest thing that works (ponytail)". Show the comparison and let me pick or graft, then save the chosen interface to `.pipeline/interface.md`.
- **refactor**: follow `~/.claude/skills/request-refactor-plan/SKILL.md` steps 1–7: interview, options, scope, test coverage, and a tiny-commit plan. Save it to `.pipeline/refactor-plan.md`. If test coverage is too thin, the first commits add characterization tests.

## 4. Brief
Write `.pipeline/brief.md` in this shape:
- `Track:`
- `Engine:`
- Goal: one line.
- Acceptance criteria: checkable bullets.
- Out of scope.
- Constraints and decisions, each with its reason.
- UI URL, if any.
- The plan artifact, linked.

For **refactor**, the criteria must include "behaviour unchanged: the existing tests pass before and after every commit step." Show me the brief and wait for "go", unless this run came from `/ship go`.

## 5. Run
**qa**: call the Workflow tool with name `qa-run` and args `{url, flows, engine}`. Use `engine: "real-browser"` only if the flows need a login I already have in Zen.

**Engine `workflow`**, and the fallback whenever teammates can't spawn (`-p`, or `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` unset):
- Set the stage to `build`.
- Call the Workflow tool with name `ship-flow` and args `{feature: <goal>, brief: <brief.md text>, criteria: <acceptance bullets>, url: <UI URL if any>}`.
- When it returns, set the stage to `done` with its verdict.

**Engine `team`.** If this session is in plan mode, ask me to leave it first, because teammates spawned in plan mode are read-only.
1. Spawn teammates using the `planner`, `coder`, `tester` and `pr-reviewer` agent types.
2. Create the tasks with TaskCreate, each blocked by the one before:
   - `spec`, owned by planner → `.pipeline/spec.md`
   - `build`, owned by coder → `.pipeline/changes.md`
   - `test-r1`, owned by tester → `.pipeline/test-results.md`

   Update the status stage as each task starts. If the planner messages you open questions, set the verdict to `NEEDS ANSWERS`, ask me, write the answers into the brief, and tell the planner to continue.
3. **Fix loop (you own it).** After each test task, read the header of `test-results.md` (`passed`, `plantedRejected`, the failure count). Track `best` = the lowest failure count so far, and `stale` = how many rounds in a row failed to beat it.
   - While `(!passed || plantedRejected < 3) && stale < 2`: create `fix-rN` (coder), then `test-rN` (tester). Increment `round` in the status.
4. **Review.** Create a `review` task for pr-reviewer: review the working-tree diff against the spec and report only real correctness, security, and spec-mismatch issues. Then load the `ponytail-review` skill and add its findings as low or med severity. Write `.pipeline/review.md` with one finding per line: `file:line [severity] claim`.
   - **QA, in parallel:** if there's a UI URL, run the `qa-tester` agent as a subagent (engine headless) against the acceptance criteria and edge cases.
5. **Verify** (stage `verify`). For each finding, run the `dave` agent as a subagent with: "Try to refute this finding. Read the code yourself. Default to refuted if you can't confirm it." Keep only the findings that aren't refuted.
6. **Verdict.**
   - **BLOCK**: tests failed, or a confirmed critical or high finding, or a QA FAIL.
   - **NEEDS WORK**: otherwise, if planted failures caught < 3, or any confirmed finding, or QA CONCERNS.
   - **SHIP**: otherwise.

   Set the status, then shut the teammates down and clean up the team.

## 6. Report, then release
Report the verdict, the tests (passed, planted N/3, rounds), the QA gate, and the confirmed findings with file:line, plus how many were dropped. If the verdict is `NEEDS ANSWERS`, ask me and loop back to step 4. For **feature**, offer the next slice.

**Release, only on SHIP.** Use AskUserQuestion: "Release? (branch + commit + PR, recommended / commit only / no)". On yes, set the stage to `release`:
1. `git switch -c <fix|feat|refactor>/<slug>`, unless you're already on a non-default branch.
2. Stage only the paths listed in `.pipeline/changes.md` (plus their test files). Never stage `.pipeline/`.
3. Commit. Guard the subject with `[ ${#subj} -le 50 ]`. Follow CLAUDE.md's Git rules: no co-author line and no "Generated with" line.
4. Run `git log -1 --format=%B | grep -iE "co-authored-by|generated (with|by)|claude code|anthropic"`. It must print nothing; if it does, amend. (File names like CLAUDE.md are fine.)
5. For **branch + commit + PR**: `git push -u origin HEAD`, then `gh pr create --title "$subj" --body-file -`. The body has: summary, acceptance criteria as checkboxes, tests (passed, planted N/3, rounds), QA gate, and confirmed findings plus how many were dropped. No Claude mention. If there's no remote or no `gh`, stop after the commit.
6. **Never merge.** Set the stage to `done`.
7. Save one line to this project's auto-memory: the goal, the PR URL (or the commit hash), and the verdict.
