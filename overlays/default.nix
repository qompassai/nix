# default.nix
# Qompass AI Overlay Default
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  inputs,
  system,
  ...
}:
final: prev:
let
  getOverlay =
    overlay: if builtins.isAttrs overlay && overlay ? default then overlay.default else overlay;
  localOverlays = [
    (import ./x86_64.nix)
    (import ./intel.nix)
    (import ./passt-fix.nix)
  ];
  inputOverlays = [
    #(getOverlay inputs.agenix.overlays.default)
    #(getOverlay inputs.fenix.overlays.default)
    #(getOverlay inputs.kernel-overlay.overlays.${system})
    #(getOverlay inputs.neovim-nightly-overlay.default)
    #(getOverlay inputs.nur.overlays.default)
    #(getOverlay inputs.poetry2nix.overlays)
    #(getOverlay (inputs.rust-overlay.overlays.default or (final: prev: { })))
  ];
  nurOverlays = builtins.attrValues (inputs.nur.overlays or { });
  allOverlays = localOverlays ++ inputOverlays ++ nurOverlays;
  applyOverlays = overlays: builtins.foldl' (acc: overlay: acc // (overlay final prev)) { } overlays;
  combinedOverlays = applyOverlays allOverlays;
in
combinedOverlays
// {
  intel-graphics-compiler = prev.intel-graphics-compiler.overrideAttrs (oldAttrs: {
    buildFlagsArray = (oldAttrs.buildFlagsArray or [ "-arch=Gen9" ]) ++ [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      "-DIGC_OPTION_ARCHITECTURE_TARGET=Gen9"
    ];
    buildPhase = ''
      export IGC_ARCH=Gen9
      export IGC_OPTION__ARCHITECTURE_TARGET=Gen9
      make
    '';
  });
}
