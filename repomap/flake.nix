# repomap — always-fresh codebase maps for coding agents.
#
# A generic flake: add it as an input to ANY repo's flake.nix and the repo
# gets a ranked, budgeted map of its Rust codebase, regenerated automatically
# whenever sources change under the dev shell.
#
# Consumer wiring (in the consuming repo's flake.nix):
#
#   inputs.repomap.url = "github:qompassai/nix?dir=repomap";  # or "path:/…/repomap"
#
#   outputs = { self, nixpkgs, flake-utils, repomap, ... }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let pkgs = nixpkgs.legacyPackages.${system}; in {
#         devShells.default = pkgs.mkShell {
#           packages = [ repomap.packages.${system}.repomap ];
#           shellHook = repomap.lib.refreshHook {
#             pkg = repomap.packages.${system}.repomap;
#           };
#         };
#       });
#
# Then every `nix develop` (or direnv `use flake`) refreshes
# `$PWD/.repomap.txt` — a derived, gitignored artifact — whenever a `.rs`
# file is newer than it. One-shot: `nix run .#repomap -- /path/to/repo`.
{
  description = "repomap — ranked, budgeted codebase maps for coding agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # tree_sitter_rust is not packaged in nixpkgs. Use the upstream abi3
        # wheel (the exact artifact `pip install tree_sitter_rust` puts on
        # this machine): building the sdist would need <tree_sitter/parser.h>,
        # which neither nixpkgs' tree-sitter nor its python bindings ship.
        # abi3 wheels run on any CPython >= 3.9, so this tracks nixpkgs'
        # python3.
        #
        # The wheel is VENDORED in ./wheels/ (hash-verified against the
        # upstream PyPI artifact at vendoring time:
        # sha256-4DPFqTtXyI4Kg1iA3jn8gCkJ/2n1eq/2AAIRwZbqUZA=), so the
        # flake is self-contained — no PyPI access needed at build time.
        # To bump the version, drop the new wheel in ./wheels/ and update
        # the filename below.
        #
        # Linux/x86_64 only for now — other platforms get a clear error,
        # not a broken build.
        tree-sitter-rust-py =
          if pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64 then
            pkgs.python3Packages.buildPythonPackage rec {
              pname = "tree_sitter_rust";
              version = "0.24.2";
              format = "wheel";
              src = ./wheels/tree_sitter_rust-0.24.2-cp39-abi3-manylinux1_x86_64.manylinux_2_28_x86_64.manylinux_2_5_x86_64.whl;
              # The wheel declares `tree-sitter` as a dependency; withPackages
              # below provides it, so don't let the build try to fetch it.
              dependencies = [ ];
            }
          else
            throw "repomap: tree_sitter_rust is only packaged for linux/x86_64 (upstream abi3 wheel)";

        repomap-py = pkgs.python3.withPackages
          (ps: [ ps.tree-sitter tree-sitter-rust-py ]);

        repomap-pkg = pkgs.writeShellScriptBin "repomap" ''
          # NB: do NOT use `exec -a` here: the withPackages python env is a
          # venv, and CPython locates the venv via argv[0] — renaming it
          # breaks sys.path and imports fail. prog= is set in argparse.
          exec ${repomap-py}/bin/python ${./repo_map.py} "$@"
        '';

        app = {
          type = "app";
          program = "${repomap-pkg}/bin/repomap";
        };
      in
      {
        packages.default = repomap-pkg;
        packages.repomap = repomap-pkg;

        apps.default = app;
        apps.repomap = app;

        formatter = pkgs.alejandra;
      })) // {
        # refreshHook: drop-in dev-shell hook for any repo. Regenerates
        # <root>/.repomap.txt only when a .rs file is newer than it, so
        # entering the shell stays cheap when nothing changed.
        #
        #   shellHook = repomap.lib.refreshHook {
        #     pkg = repomap.packages.${system}.repomap;
        #   };
        lib.refreshHook = { pkg, root ? "$PWD", out ? ".repomap.txt", budget ? 15000 }: ''
          _repomap_out="${root}/${out}"
          if [ ! -f "$_repomap_out" ] || [ -n "$(find "${root}" -name '*.rs' -newer "$_repomap_out" 2>/dev/null | head -1)" ]; then
            echo "repomap: refreshing $_repomap_out…" >&2
            ${pkg}/bin/repomap "${root}" --budget ${toString budget} --out "$_repomap_out" >/dev/null 2>&1 \
              && echo "repomap: wrote $_repomap_out" >&2 \
              || echo "repomap: generation failed (non-fatal)" >&2
          fi
          unset _repomap_out
        '';

        templates.default = {
          path = ./template;
          description = "repomap wiring for any repo's flake.nix";
        };
      };
}
