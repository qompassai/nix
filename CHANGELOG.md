# Changelog — qompassai/nix

## 2026-09-28 — License normalization to Apache 2.0

**Decision (per Matt's directive):** the project's license is now Apache
License 2.0 ONLY.

- **Removed** `LICENSE-AGPL` (GNU Affero General Public License v3) and
  `LICENSE-QCDA` (Qompass Commercial Distribution Agreement 1.0). The
  previous dual-license model (AGPL-3.0 for open use + Q-CDA commercial
  option) is retired for this repo. Rationale per Matt: a single
  permissive license (Apache 2.0) for all Qompass AI language projects.
- **Added** `LICENSE` — the complete, unmodified Apache License 2.0 text
  (https://www.apache.org/licenses/LICENSE-2.0.txt), appendix attributing
  `Copyright 2025 Qompass AI` (year kept from the repo's existing
  copyright headers).
- **README.md**: replaced the AGPL v3 + Q-CDA badges with an Apache 2.0
  badge; removed the entire "Dual-License Notice" section (AGPL
  rationale, commercial-option rationale, cybersecurity references) and
  replaced it with a concise `## License` section pointing at `./LICENSE`.
- **Metadata**: `.zenodo.json` and `CITATION.cff` license fields updated
  from `Q-CDA-1.0` to the SPDX identifier `Apache-2.0`.

**Exceptions:**
- `overlays/passt-fix.nix` keeps `license = super.lib.licenses.mit;`
  untouched. That field is nixpkgs package metadata describing the
  upstream `passt` package being overlaid, not this project's license;
  changing it would misattribute third-party software and break the
  nixpkgs license-attribute convention. Left intact per the
  third-party-metadata exception.

**Validation:** `LICENSE` diffed against the canonical apache.org text
(only the appendix copyright line differs, as intended); `.zenodo.json`
parses as JSON; README renders (no broken badge/link references remain
to the deleted license files — verified zero matches for
AGPL/Q-CDA/dual-license strings outside this changelog).
