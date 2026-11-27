# Working on this challenge

Read `ROADMAP.md`, `Challenge.lean`, and `comparator.json`. Set `TASKS_AGENT` to a stable session name unique among contributors, even if several sessions share Git credentials. Enter the Nix shell with `nix develop` and run `tasks` from your current worktree. Use `nix develop -c tasks …` for one-off commands. Task files and reviews travel through the shared Git remote.

## Pick up a task

1. Check the review queue with `tasks list --state review,proposed`. Review a waiting submission when you can, then look for a task.
2. Run `tasks list --state open` and `tasks show ID`. Read the task, its notes, and its prerequisites. Prefer the highest-priority open task you can advance.
3. Run `tasks claim ID --worktree ../ID` and work in that checkout. The claim reserves `origin/task/ID` with an expected prior tip, so simultaneous claims cannot replace one another. If a push loses the race, the command leaves the local checkout available for inspection. Coordinate stale handoffs with the lead before using `claim --force`.

## Work and submit

- Commit complete steps in your task worktree. Run `tasks log "what happened"` to commit a progress entry and push it with your work. Keep research notes in `notes/ID.md` and add new Lean lemma modules under `Proofs/`.
- Keep statements, shared definitions, toolchain pins, and verification rules under maintainer review. Put shared definitions in `Statement.lean` or `Statement/`. Keep Lean placeholders and experimental assumptions in scratch work or notes until you can present a checked result.
- Fill in **Outcome** in the task file before submission. State what was learned, how it advances the roadmap, and which checks you ran. Distinguish Lean-verified results, paper proofs, numerical evidence, conjectures, and refutations. For a solution, include the Comparator verdict.
- Commit the outcome and run `tasks submit --summary "result"`. This pushes your branch for review. When a forge is available you can open a pull request from that branch to the default branch. Address feedback on the same branch and ask for review of the updated commit.
- Propose useful follow-up work on a `proposal/ID` branch as described in `tasks/README.md`. Use a separate task when a partial result is independently useful, so it can land before the larger task.
- To hand off work, commit it and run `tasks release --reason "next concrete step"`. This publishes the handoff and makes the branch available to claim again from its last pushed commit.

## Review and merge

Fetch and capture the exact commit you intend to review. The example assumes `main` is the default branch.

```sh
branch=task/first-lemma
git fetch origin
tip=$(git rev-parse "origin/$branch")
git log --oneline "origin/main..$tip"
git diff "origin/main...$tip"
tasks reviews "$branch"
```

Read the task and review the mathematical argument, assumptions, and completion criteria. Check the captured commit in a separate checkout and reproduce the relevant checks. The reviewer and the person merging must each differ from the task owner.

```sh
tasks review "$branch" --tip "$tip" --approve -m "Checked the argument and ran ./scripts/check"
tasks merge "$branch"
```

Use `--changes` instead of `--approve` to request corrections. Add line comments with `--note PATH:LINE "comment"`. Both verdicts are pushed to `origin/review/BRANCH`. The latest review must approve the current tip before a merge. Use the same commands for `proposal/ID` branches.

The lead maintains the roadmap and triages proposals. Integrate reviewed changes with `tasks merge`. If your server supports access rules, reserve updates to the default branch for integrators.
