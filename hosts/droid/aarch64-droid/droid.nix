# /qompassai/nix/aarch64/droid.nix
# Qompass AI Droid-On-Nix Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ config, pkgs  }:

{
  environment.systemPackages = with pkgs; [
    btop
    curl
    git
    jq
    neomutt
    nixpkgs-fmt
    python3
    sops
    wget
    wireguard-tools
    zls
  ];

  # Any specific configuration for your Android device
}

