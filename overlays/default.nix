# default.nix
# Qompass AI Overlay Default
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ inputs, system, ... }:
[
  (import ./intel.nix)
  (import ./x86_64.nix)
  (import ./overlays/passt-fix.nix)
  inputs.agenix.overlays.default
  inputs.fenix.overlays.default
  inputs.kernel-overlay.overlays.${system}
  inputs.neovim-nightly-overlay.overlay
  inputs.nur.overlays.default
  inputs.poetry2nix.overlay
]
++ (builtins.attrValues (inputs.nur.overlays or { }))
++ [
  (inputs.rust-overlay.overlays.default or (final: prev: { }))
]
