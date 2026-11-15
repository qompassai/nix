# NixOS merge and scrub — 2026-11-15

origin_lane=qompassai; content_label=sfw; evidence: brief + Pax gate reads 2026-11-15.
Branch: pax/merge-ssd-20261115. No push, PR, rebuild, or lock update authorized.

Start: audit and memory read. Memory current.md describes a mirror and is stale relative to this brief. Initial tree clean except pre-existing untracked DIVERGENCE.md; left untouched.

Checks: primo drvPath eval; parse all touched Nix files; secret sweep with positive controls; preserve repo-only work and SSD lock bytes. No custom skills used (including tiger-style-nix).
.nix: not-LSP-validated (no theodolite route)

## Stage 1 — base
SSD live closure and four overlays copied; SSD lock retained byte-for-byte. S1 tokens stripped in memory BEFORE writing any destination or commit. Public fetches need no authentication; credential setting removed. No token values recorded. SSD flake retires the broken armhost output (stage 3 decision).

Stage-1 commit initially refused: empty environment identity overrides. Resolved by unsetting four empty GIT identity variables for commits, using existing configured Pax identity. Base primo drvPath eval PASSED.

## Stage 2 — repo work preserved
All repo-only template/, topology/, packages/, nixos-installer/ files preserved. overlays/ retains all repo files; default and x86_64 replaced by SSD versions because live outputs import them. No duplicate repo variants retained without a live consumer.

23 divergent-path decisions:
- SSD wins (live): configuration.nix, flake.lock, flake.nix; hosts/linux/x86_64/{boot,config,environment,hardware,misc,nix,programs,security,services,users,variables,xdg}.nix; overlays/{default,x86_64}.nix; treefmt.nix.
- Repo retained (outside SSD live closure): checks.nix; hosts/linux/x86_64/{default,devshells,packages}.nix; modules/common/core/pkgs.nix.
SSD additions: devshells.nix, modules/modules-list.nix and hosts/linux/x86_64/packages/core.nix. No bulk copy of dead SSD modules or credential-bearing nix.conf.

## Stage 3 — eval breakers
Primo base drvPath eval PASSED: /nix/store/97ij117vqdr6j969h5vjk80xqlcajkgj-nixos-system-primo-25.11.20251124.5ae3b07.drv. Locked nixpkgs attribute probe: oneDNN=true, onednn=false. SSD hardware uses the name valid at this lock; no speculative rename. Armhost output retired: no deployed ARM hardware base supplied; pointing it at SSD modules-list would import primo x86_64 configuration. ARM source files retained.
