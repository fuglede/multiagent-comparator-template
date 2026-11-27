{
  description = "Lean Comparator challenge with Git-based task coordination";

  inputs.nixpkgs.url = "nixpkgs";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      tools = pkgs: with pkgs; [
        bash
        bubblewrap
        coreutils
        curl # Mathlib's optional cache downloader.
        elan
        git
        openssh
        python3
        which
      ];

      # Use the current worktree's task script, including after working on a different branch.
      tasksCli = pkgs: pkgs.writeShellApplication {
        name = "tasks";
        runtimeInputs = tools pkgs;
        text = ''
          root=$PWD
          if [[ ! -f "$root/scripts/tasks" ]]; then
            root=$(git rev-parse --show-toplevel)
          fi
          exec python3 "$root/scripts/tasks" "$@"
        '';
      };
    in {
      apps = forAll (pkgs: {
        tasks = {
          type = "app";
          program = "${tasksCli pkgs}/bin/tasks";
          meta.description = "Run the task tool in the current worktree";
        };
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = tools pkgs ++ [ (tasksCli pkgs) ];
        };
      });

      checks = forAll (pkgs:
        let
          source = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [ ./ROADMAP.md ./scripts/tasks ./tasks ];
          };
        in {
          tasks-lint = pkgs.runCommand "tasks-lint" { nativeBuildInputs = [ pkgs.python3 ]; } ''
            python3 ${source}/scripts/tasks lint
            touch "$out"
          '';
        });
    };
}
