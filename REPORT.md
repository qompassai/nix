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

## Stage 4 — scrub and self-contained sops
S1 tokens removed before copying; SSD nix.conf never copied. Authenticated fetch settings removed because only public inputs are used. Removed PAT prompting/writing from quickstart and its README copy, and empty credential setting from duplicate module. No secret values printed or committed. Existing historical commits were not rewritten; this is a final-tree scrub, not history remediation.

Live common sops module now imports declared sops-nix and local secrets/primo.yaml, with SSH host-key age conversion and early password hash files for normal user and root. Users made immutable so declarative hashes apply. Encrypted PLACEHOLDER values generated with sops; no real values. Matt must populate them before deployment. .sops.yaml recipient derived using upstream ssh-to-age 1.2.0 and /etc/ssh/ssh_host_ed25519_key.pub; no private key accessed. Verify deployed SSD host key matches primo's current host key before provisioning. Armhost retired, so no invented recipient.

lib/mkSystem.nix does not exist in this repo or final tree. Its dead SSD helper (with unsafe fallback and unrelated undeclared inputs) was deliberately not copied. No such fallback exists in merged tree.

Tool note: obtaining ssh-to-age via nix shell unexpectedly proposed a toolchain build; interrupted it, no system build or rebuild run. Instead ran upstream cached source with system Go and cached vendor dependencies outside repo. Primary references: locked sops-nix README and module option declarations; locked nixpkgs attribute eval; upstream ssh-to-age CLI source; installed sops help.

## Stage 5 — mechanical security fixes
Replaced root SSH password access with prohibit-password and disabled keyless SSH store serving, including dormant duplicate definitions to prevent unsafe reactivation. Files: hosts/linux/x86_64/nix.nix, hosts/linux/x86_64/services.nix, hosts/common/core/config.nix, modules/hosts/linux/x86_64/nix.nix, modules/hosts/linux/x86_64/services.nix, modules/hosts/common/core/config.nix, modules/common/core/nix.nix.
Passwordless wheel sudo left AS IS (live security.nix and dormant definitions): Matt must decide. Other audit debt left unchanged: automatic-upgrade store path, formatter, Android system string, broad daemon access and sandbox exceptions, open firewall ports, duplicate settings, dead parse failures.

## Stage 6 — final gates and completion

| Check | Result |
| --- | --- |
| Exact requested primo drvPath eval, --no-write-lock-file | PASS: /nix/store/cqglfc050pi25gq2smznj69zkxvs1ixg-nixos-system-primo-25.11.20251124.5ae3b07.drv |
| armhost eval | SKIPPED: retired; output names eval returns only primo |
| nix-instantiate --parse, every touched .nix | PASS: 26/26; zero failures |
| Requested secret-pattern sweep, all non-Git worktree files | PASS: 226 files, zero hits; values never emitted |
| Adversarial sweep controls | PASS: all six requested classes detected in memory-only synthetic strings |
| S1 exact-value check over new commit patches | PASS: zero occurrences across stages 1–5; values not emitted |
| SSD lock byte equality | PASS |
| Protected repo directories vs original HEAD | PASS: template/, topology/, packages/, nixos-installer/ unchanged |
| sops filestatus secrets/primo.yaml | PASS: encrypted=true |
| SOPS envelope vs policy | PASS: recipient matches, two encrypted fields and encrypted MAC |
| Effective security settings eval | PASS: root SSH prohibit-password; store SSH enable/write/trusted false; mutableUsers false; two early hash files under /run/secrets-for-users |
| Passwordless wheel sudo | Confirmed false for wheelNeedsPassword; deliberately preserved |
| Additional git diff --check | FAIL: two SSD-source trailing-whitespace lines in hosts/linux/x86_64/services.nix (2, 141); left unchanged to avoid unrelated formatting |
| Build, activation, runtime decryption | NOT RUN: eval-only scope; real secret population required |
| LSP | .nix: not-LSP-validated (no theodolite route) |

No custom skill materially used. No push, PR, remote changes, nix flake update, nixos-rebuild, or source-tree edits. No existing history rewritten. Six local stage commits including this report/gates commit. Pre-existing DIVERGENCE.md remains untracked and unchanged. Diff is ready for Pax review and Matt's push decision, with placeholders explicitly requiring provisioning before deployment.

Open owner decisions: populate encrypted hashes and verify deployed host public key; decide passwordless sudo; manage S1 token revocation/history separately. Pre-existing formatter, Android output, auto-upgrade and other audit debt are outside this merge's eval gates.
