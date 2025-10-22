# /qompassai/nix/modules/common/core/nix.nix
# Qompass AI NixOS Common Core Nix Module
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  inputs,
  pkgs,
  platform,
  system ? pkgs.system,
}:
let
  baseNix = {
    enable = true;
    channel.enable = true;
    checkAllErrors = false;
    checkConfig = true;
    daemonCPUSchedPolicy = "other";
    daemonIOSchedClass = "best-effort";
    daemonIOSchedPriority = 0;
    distributedBuilds = false;
    extraOptions = ''
      plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
    '';
    gc = {
      automatic = false;
      dates = "daily";
      persistent = false;
      options = "--delete-older-than 10d";
    };
    nrBuildUsers = 64;
    optimise = {
      automatic = true;
      persistent = true;
    };
    package = pkgs.nixVersions.latest;
    settings = {
      accept-flake-config = true;
      allow-dirty = true;
      allow-import-from-derivation = true;
      allow-symlinked-store = true;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      build-prefer-local = true;
      build-use-sandbox = true;
      cores = 0;
      connect-timeout = 30;
      download-attempts = 5;
      max-jobs = "auto";
      max-substitution-jobs = 8;
      min-free = 4294967296;
      print-missing = true;
      pure-eval = false;
      sandbox = true;
      sandbox-build-dir = "/build";
      show-trace = true;
      stall-download-timeout = 300;
      store = "/nix/store";
      substituters = [
        "https://cache.nixos.org"
      ];
      system-features = [
        "benchmark"
        "big-parallel"
        "ca-derivations"
        "kvm"
        "nixos-test"
        "uid-range"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      use-cgroups = true;
      use-registries = true;
      use-sqlite-wal = true;
      use-xdg-base-directories = true;
      warn-dirty = false;
    };
    sshServe = {
      enable = true;
      protocol = "ssh";
      trusted = true;
      write = true;
    };
  };
  nixTable = {
    "linux-x86_64-linux" = {
      settings.trusted-users = [
        "root"
        "@wheel"
        "phaedrus"
      ];
      settings.extra-substituters = [
        "https://cache.garnix.io"
        "https://cache.lix.systems"
        "https://cuda-maintainers.cachix.org"
      ];
    };
    "linux-aarch64-linux" = {
      optimise.automatic = false;
      settings.max-jobs = 2;
      settings.system-features = [
        "aarch64"
        "benchmark"
        "nixos-test"
      ];
    };
    "darwin-x86_64-darwin" = {
      settings.trusted-users = [
        "root"
        "@admin"
      ];
      settings.extra-experimental-features = [ "ca-derivations" ];
    };
  };
  key = "${platform}-${system}";
  uniqueNix = if nixTable ? key then baseNix // nixTable.${key} else baseNix;
in
uniqueNix
