# repomap

Always-fresh, ranked, budgeted codebase maps for coding agents — as a
generic Nix flake any repo can consume.

## What it does

`repomap /path/to/repo` walks a repo's Rust sources, parses them with
tree-sitter, ranks definitions by cross-file references (qualified calls
like `T::m`, type-position references, module paths — not bare-name
frequency), and writes a budgeted map: the highest-signal definitions
first, then a complete per-file table of contents. Agents read the map
instead of the whole tree.

## Use in any repo

In your repo's `flake.nix`:

```nix
inputs.repomap.url = "github:qompassai/nix?dir=repomap";

# in outputs:
devShells.default = pkgs.mkShell {
  packages = [ repomap.packages.${system}.repomap ];
  shellHook = repomap.lib.refreshHook {
    pkg = repomap.packages.${system}.repomap;
  };
};
```

Add `.repomap.txt` to your `.gitignore` — it is a derived artifact.

Every `nix develop` / direnv entry then regenerates `$PWD/.repomap.txt`
whenever any `.rs` file is newer than it, and does nothing when the tree
is unchanged. One-shot generation without the hook:

```
nix run github:qompassai/nix?dir=repomap -- /path/to/repo --budget 15000 --out ./my-map.txt
```

A `templates.default` output shows the same wiring; copy
`template/flake.nix` into a new repo to start.

## Status

Prototype implementation: Python + tree-sitter, in `repo_map.py`. A Rust
port (`phlow-repomap`) will replace the package implementation later; the
flake interface (`packages.repomap`, `apps.repomap`, `lib.refreshHook`)
stays the same, so consumers won't notice the swap.
