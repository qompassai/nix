#/qompassai/nix/modules/2/zig.nix
# ---------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ lib, pkgs, zig-overlay }:

let
  zigVersions = zig-overlay.packages.${pkgs.system};
in {
  zig = version: zigVersions."zig_${lib.replaceStrings ["."] ["_"] version}";

  buildZigProject = { src, version, targets ? ["native"], ... }@attrs:
    pkgs.stdenv.mkDerivation ({
      nativeBuildInputs = [ zigVersions."zig_${lib.replaceStrings ["."] ["_"] version}" ];
      configurePhase = ''
        mkdir -p $out/bin
      '';
      buildPhase = ''
        zig build install -Doptimize=ReleaseSafe --prefix $out
      '';
    } // attrs);

  innherit zls = zig-overlay.packages.${pkgs.system}.zls;
}

