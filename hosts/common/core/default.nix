# /qompassai/nix/hosts/common/core/default.nix
# Qompass AI Nix Common Host Core Defaults
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:
let
  platform = if isDarwin then "darwin" else "nixos";
  platformModules = "${platform}Modules";
in
{
  imports = lib.flatten [
    inputs.sops-nix.${platformModules}.sops
    (map lib.custom.relativeToRoot [
      "modules/common"
      "modules/hosts/common"
      "modules/hosts/${platform}"
      "hosts/common/core/${platform}.nix"
      "hosts/common/core/sops.nix"
      "hosts/common/core/ssh.nix"
      #"hosts/common/core/services"
      "hosts/common/users/primary"
      "hosts/common/users/primary/${platform}.nix"
    ])
  ];
  hostSpec = {
    username = "ta";
    handle = "emergentmind";
    inherit (inputs.nix-secrets)
      domain
      email
      userFullName
      networking
      ;
  };
  networking.hostName = config.hostSpec.hostName;
  environment.systemPackages = [ pkgs.openssh ];
  nixpkgs = {
    overlays = [ outputs.overlays.default ];
    config = {
      allowUnfree = true;
    };
  };
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      abort-on-warn = false;
      accept-flake-config = true;
      auto-optimise-store = true;
      connect-timeout = 5;
      build-cores = 0;
      cores = 0;
      log-lines = 25;
      max-build-log-size = 0;
      max-jobs = [ "auto" ];
      max-substitution-jobs = 16;
      min-free = 128000000;
      max-free = 1000000000;
      print-missing = true;
      trusted-users = [ "@wheel" ];
      warn-dirty = false;
      allow-import-from-derivation = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "configurable-impure-env"
        "dynamic-derivations"
        "fetch-closure"
        "fetch-tree"
        "flakes"
        "git-hashing"
        "impure-derivations"
        "local-overlay-store"
        "mounted-ssh-store"
        "nix-command"
        "parse-toml-timestamps"
        "pipe-operators"
        "recursive-nix"
        "verified-fetches"
      ];
      substitute = true;
      substituters = "https://cache.nixos.org";
      show-trace = true;
      stalled-download-timeout = 300;
      sync-before-registering = true;
      system-features = [
        "benchmark"
        "big-parallel"
        "ca-derivations"
        "kvm"
        "nixos-test"
        "uid-range"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://bunker.cachix.org"
        "https://cache.garnix.io"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      upgrade-nix-store-path-url = "https://github.com/NixOS/nixpkgs/raw/master/nixos/modules/installer/tools/nix-fallback-paths.nix";
      use-registries = true;
      use-sqlite-wal = true;
      use-xdg-base-directories = true;
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = "source ''${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  };
}
