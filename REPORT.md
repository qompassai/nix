# NixOS merge and scrub — 2026-11-15

origin_lane=qompassai; content_label=sfw; evidence: brief + Pax gate reads 2026-11-15.
Branch: pax/merge-ssd-20261115. No push, PR, rebuild, or lock update authorized.

Start: audit and memory read. Memory current.md describes a mirror and is stale relative to this brief. Initial tree clean except pre-existing untracked DIVERGENCE.md; left untouched.

Checks: primo drvPath eval; parse all touched Nix files; secret sweep with positive controls; preserve repo-only work and SSD lock bytes. No custom skills used (including tiger-style-nix).
.nix: not-LSP-validated (no theodolite route)

## Stage 1 — base
SSD live closure and four overlays copied; SSD lock retained byte-for-byte. S1 tokens stripped in memory BEFORE writing any destination or commit. Public fetches need no authentication; credential setting removed. No token values recorded. SSD flake retires the broken armhost output (stage 3 decision).
