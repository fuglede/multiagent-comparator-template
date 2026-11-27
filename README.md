# Lean challenge workspace

Divide a Lean Comparator challenge into independently reviewable tasks. Markdown files describe the work. A shared Git remote carries task claims, submissions, reviews, and completed results. Contributors use the same workflow with a bare Git repository, a self-hosted server, or a hosted forge.

## Set up a challenge

1. Copy the **contents** of this directory to the root of a new Git repository. Use a shared remote called `origin`. For a bare remote you can run `git init --bare -b main /path/to/team.git` on the host, then add its Git URL as `origin` in the working clone. Contributors need permission to push task and review branches, and whoever integrates work needs permission to update the default branch.
2. Replace [Challenge.lean](Challenge.lean) with the statements to prove, using `sorry` for their proof bodies. Set `theorem_names` in [comparator.json](comparator.json) to the fully qualified target names. Use `definition_names` if the challenge also asks for definitions. Put shared definitions in `Statement.lean` or `Statement/` and import them from both sides. [Lean Comparator configuration](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/#lake-comparator)
3. Fill in [ROADMAP.md](ROADMAP.md) and create a few first tasks. Use Nix on Linux with flakes enabled. If the template files are new to Git, stage them with `git add .` so the flake can see them. Set `TASKS_AGENT` to your session name and fill in the generated task's **Done when** before committing it. [Nix flake setup](https://wiki.nixos.org/wiki/Flake#Setup)

   ```sh
   export TASKS_AGENT=lead
   nix develop -c tasks new first-lemma --no-fetch --title "Prove the first reduction" \
     --area lean --avenue proof --priority 1 --goal "Reduce the main goal to a reusable lemma."
   ```

4. Stage the new task files, run `nix flake check` and `nix develop -c ./scripts/check`, then commit and push the initial files to the default branch. Fresh clones infer the base branch from `origin/HEAD` or fall back to `main` or `master`. Set `TASKS_BASE` if your local clone needs a different base.

For a new worker, supply the clone, credentials for the shared remote, and a stable session name. For example:

> You are `algebra-1`. Follow `AGENTS.md`. Read the roadmap and challenge, check the review queue, then claim one ready task in a separate worktree. Push complete steps and submit the result for review.

See [AGENTS.md](AGENTS.md) for the contribution loop and [tasks/README.md](tasks/README.md) for the branch protocol. A forge can display a submitted branch as a pull request. The Git workflow also provides the diff, reviews, checks, and merge when a forge is absent.

## Verify work

Run `nix develop` at the repository root. The shell supplies Git, Python, Elan, Bubblewrap, and `tasks`. Elan installs the version in `lean-toolchain` on the first Lean command. Use `nix develop -c COMMAND` for a one-off command or `nix run .#tasks -- list` for the task board.

| Command | What it checks |
| --- | --- |
| `nix flake check` | Validates the flake and lints task files and their roadmap references. |
| `lake build Challenge` | Elaborates the challenge. Its proof holes produce the expected `sorry` warnings. |
| `lake build` | Compiles `Proofs.lean` and all modules under `Proofs/`. |
| `lake check` | Replays the proof library in Lean's kernel and checks its axioms. |
| `lake comparator` | Checks that `Solution.lean` proves the configured statements using permitted axioms. |
| `./scripts/check` | Lints the task files, checks intermediate proofs, and runs Comparator when a solution exists. |

Leave `Solution.lean` absent while the team develops lemmas. When the configured targets are ready, add a `Solution.lean` that declares the same fully qualified names as `Challenge.lean`. Import lemma modules and shared definitions directly. Keep `sorryAx` out of `permitted_axioms`.

Here is `Solution.lean` for the bundled example.

```lean
namespace Challenge

theorem goal (a b : Nat) : a + b = b + a := Nat.add_comm a b

end Challenge
```

`tasks merge` runs the proof checks in a fresh temporary worktree of the proposed merge before updating the shared base. A project with CI can run `nix develop -c ./scripts/check` on a Linux runner with user namespaces available for Bubblewrap. For an independent kernel check, configure an external kernel or run `lake comparator --paranoid` in the dev shell. [Lean proof validation](https://lean-lang.org/doc/reference/latest/ValidatingProofs/)

### Dependencies

The starter uses Lean's standard library. To use Mathlib, add this to `lakefile.toml`, run `lake update`, and commit `lake-manifest.json`. When changing Lean versions, pick a Mathlib revision built for that toolchain.

```toml
[[require]]
name = "mathlib"
git = "https://github.com/leanprover-community/mathlib4.git"
rev = "v4.36.0"
```

For local development, Mathlib provides `lake exe cache get`. Prefer specific imports to limit work in the sandboxed build and kernel replay. [Mathlib dependency setup](https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency)
