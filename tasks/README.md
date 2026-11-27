# Task files and branches

Run `nix develop` to make `tasks` available. Create one `tasks/ID.md` per task with `tasks new`. It includes the goal, context, completion criteria, outcome, and a progress log. Each task names a roadmap avenue and may depend on other task IDs. A dependency is satisfied when its task is marked done on the default branch.

| Git location | Meaning |
| --- | --- |
| `origin/proposal/ID` | New task or triage change submitted for review. |
| `origin/DEFAULT:tasks/ID.md` | Accepted task definition. A task marked done here has landed. |
| `origin/task/ID` | Claimed work, a retained handoff, or a submitted result. |
| `origin/review/task/ID` | Reviews of particular commits on a work branch. |
| `origin/review/proposal/ID` | Reviews of particular commits on a proposal branch. |

A landed task is **open** when its priority is 1–3 and its dependencies are done. Priority `new` means it needs triage. A claim becomes **stale** after 48 hours without a newer commit timestamp. A submission is in **review** until it lands. A released task keeps its branch and returns to its state under the latest roadmap and dependencies.

To propose a task after setup, create a worktree and use the same ID for the task and the branch.

```sh
git fetch origin
git worktree add -b proposal/first-reduction ../first-reduction origin/main
cd ../first-reduction
tasks new first-reduction --title "Prove the first reduction" --area lean --avenue proof
# Fill in Goal, Context, and Done when.
git add tasks/first-reduction.md
git commit -m "Propose first reduction"
tasks propose
```

The lead can set priority 1 for the main line, 2 for supporting work, or 3 for optional work before the proposal is merged. To triage a landed task, start `proposal/ID` from the current default branch, update its task file, and run `tasks propose`.

Use `tasks show ID` for current details and `tasks reviews BRANCH` for the review history. From a Git client alone, inspect the work with a branch diff and read the reviews with `git log -p origin/review/task/ID`. Keep work and review branches on the remote while people need their details.
