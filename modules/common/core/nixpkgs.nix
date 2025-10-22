# nixpkgs.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  inputs,
  pkgs,
  platform,
  system ? pkgs.system,
}:
let
  baseNixpkgs = {
    buildPlatform = "x86_64-linux";
    config = {
      allowAliases = false;
      allowBroken = false;
      allowUnfree = true;
      allowUnsupportedSystem = false;
      checkMeta = false;
      cudaSupport = true;
      enableParallelBuildingByDefault = true;
      strictDepsByDefault = true;
      structuredAttrsByDefault = false;
      warnUndeclaredOptions = false;
      hashedMirrors = [
        "https://cache.nixos.org/tarballs"
        "https://mirror.csclub.uwaterloo.ca/nixpkgs"
        "https://mirrors.ocf.berkeley.edu/nixpkgs"
        "https://mirror.sfo.sonic.net/nixpkgs"
        "https://nix-mirror.s3.amazonaws.com"
        "https://tarballs.nixos.org"
        "https://releases.nixos.org"
      ];
      overlays = [
        (final: prev: {
          passt = prev.passt.overrideAttrs (old: {
            meta = (old.meta or { }) // {
              maintainers = [ ];
            };
          });
        })
        (final: prev: { passt = null; })
        (final: prev: {
          hypr-unstable = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
        })
      ];
    };
  };
  nixpkgsTable = {
    "linux-x86_64-linux" = {
      config.enableParallelBuildingByDefault = true;
    };
    "linux-aarch64-linux" = {
      config = {
        allowUnfree = true;
        cudaSupport = false;
        strictDepsByDefault = false;
        hashedMirrors = [
          "https://cache.nixos.org/tarballs"
          "https://mirror.sonic.net/nixpkgs"
        ];
      };
    };
    "darwin-x86_64-darwin" = {
      config = {
        allowUnfree = false;
        enableParallelBuildingByDefault = false;
        allowUnsupportedSystem = true;
      };
    };
    "nvidia-aarch64-linux" = {
      config = {
        cudaSupport = true;
        allowUnfree = true;
        strictDepsByDefault = true;
      };
    };
    "vm-x86_64-linux" = {
      config = {
        allowBroken = true;
        allowUnfree = true;
      };
    };
  };
  key = "${platform}-${system}";
  uniqueNixpkgs = if nixpkgsTable ? key then baseNixpkgs // nixpkgsTable.${key} else baseNixpkgs;
in
uniqueNixpkgs
