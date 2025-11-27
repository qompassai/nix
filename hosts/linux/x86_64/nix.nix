# nix.nix
# Qompass AI Linux x86_64 Nix Config
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ inputs, pkgs, ... }:
{
  nix = {
    #buildMachines = {
    #  hostName = "builder1.example.com";
    #  system = "x86_64-linux";
    #  supportedFeatures = [ "big-parallel" "nixos-test" "benchmark" "kvm" ];
    #  sshUser = "builder";
    #  sshKey = "/home/youruser/.ssh/id_ed25519";
    #  speedFactor = 2;
    #  systems = [ "x86_64-linux" "aarch64-linux" ];
    #};
    channel.enable = true;
    checkAllErrors = false;
    checkConfig = true;
    daemonCPUSchedPolicy = "other";
    daemonIOSchedClass = "best-effort";
    daemonIOSchedPriority = 0;
    distributedBuilds = false;
    enable = true;
    extraOptions = ''
      plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
    '';
    gc = {
      automatic = false;
      dates = "daily";
      persistent = false;
      options = "--delete-older-than 10d";
    };
    optimise = {
      automatic = true;
      persistent = true;
    };
    package = pkgs.nixVersions.latest;
    #registry = {
    #  lix.flake = inputs.lix;
    #  lix-module.flake = inputs.lix-module;
    #  hyprland.flake = inputs.hyprland;
    #  kernel-overlay.flake = inputs.kernel-overlay;
    #  nixos-hardware.flake = inputs.nixos-hardware;
    #  nixpkgs.flake = inputs.nixpkgs;
    #  rust-overlay.flake = inputs.rust-overlay;
    #  sops-nix.flake = inputs.sops-nix;
    #};
    settings = {
      accept-flake-config = true;
      access-tokens = "";
      allow-dirty = true;
      allow-import-from-derivation = true;
      allow-unsafe-native-code-during-evaluation = false;
      allowed-uris = [
        "github:"
        "https://github.com/nixos"
        "https://github.com/nix-community"
        "https://github.com/hyprwm"
        "https://flakehub.com"
        "git+ssh://github.com"
      ];
      allowed-users = [
        "@nixbld"
        "phaedrus"
        "@wheel"
        "*"
      ];
      allow-symlinked-store = true;
      always-allow-substitutes = false;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      build-dir = "/var/tmp/nix-build";
      build-prefer-local = true;
      build-use-sandbox = true;
      builders-use-substitutes = true;
      build-users-group = "nixbld";
      compress-build-log = true;
      cores = 0;
      connect-timeout = 30;
      debugger-on-trace = false;
      download-attempts = 5;
      download-speed = 0;
      eval-cache = false;
      eval-profiler = "disabled";
      extra-experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "daemon-trust-override"
        "dynamic-derivations"
        "fetch-closure"
        "flakes"
        "impure-derivations"
        "lix-custom-sub-commands"
        "mounted-ssh-store"
        "nix-command"
        "parse-toml-timestamps"
        "repl-automation"
      ];
      extra-trusted-public-keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.iog.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "d/dwC2PX1o/KXVnuRbcMbNkTatKF59gZ6z4lWQtaonI="
        "qnix:d/dwC2PX1o/KXVnuRbcMbNkTatKF59gZ6z4lWQtaonI="
      ];
      extra-substituters = [
        "https://cache.garnix.io"
        "https://cache.iog.io"
        "https://cache.lix.systems"
        "https://cuda-maintainers.cachix.org"
        "https://flakehub.com"
      ];
      fallback = true;
      flake-registry = [
        ""
      ];
      fsync-metadata = false;
      gc-keep-derivations = false;
      gc-reserved-space = 4294967296;
      http-connections = 50;
      http2 = true;
      id-count = 8388608;
      ignore-try = true;
      ignored-acls = [
        "security.csm"
        "security.selinux"
        "system.nfs4_acl"
      ];
      impersonate-linux-26 = false;
      impure-env = [
        "CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt"
        "GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt"
        "GIT_TERMINAL_PROMPT=0"
        "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
      ];
      keep-build-log = true;
      keep-derivations = false;
      keep-env-derivations = false;
      keep-failed = false;
      keep-going = true;
      keep-outputs = false;
      log-lines = 50;
      max-build-log-size = 0;
      max-free = 9223372036854775807;
      max-jobs = "auto";
      max-silent-time = 900;
      max-substitution-jobs = 8;
      min-free = 4294967296;
      nar-buffer-size = 33554432;
      narinfo-cache-negative-ttl = 3600;
      narinfo-cache-positive-ttl = 3600;
      netrc-file = "/home/phaedrus/.config/nix/netrc";
      preallocate-contents = true;
      print-missing = true;
      pure-eval = false;
      require-drop-supplementary-groups = true;
      require-sigs = true;
      restrict-eval = false;
      retry-attempts = 1;
      sandbox = true;
      sandbox-build-dir = "/build";
      sandbox-dev-shm-size = "75%";
      sandbox-fallback = false;
      sandbox-paths = [
        "/bin/sh=/run/current-system/sw/bin/sh"
        "/dev/nvidiactl?"
        "/dev/nvidia-uvm?"
        "/dev/nvidia-modeset?"
        "/dev/dri?"
        "/usr/share/fonts?"
        "/etc/ssl/certs/ca-certificates.crt"
      ];
      secret-key-files = "/etc/nix/keys/qnix.sec";
      ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";
      store = "/nix/store";
      substitute = true;
      substituters = [
        "https://cache.flox.dev"
        "https://cache.garnix.io"
        "https://cache.iog.io"
        "https://cache.lix.systems"
        "https://cache.nixos.org"
        "https://cuda-maintainers.cachix.org"
        "https://ghostty.cachix.org"
        "https://hyprland.cachix.org"
        "https://kernel-overlay.cachix.org"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      show-trace = true;
      stalled-download-timeout = 300;
      sync-before-registering = true;
      system-features = [
        "benchmark"
        "big-parallel"
        "ca-derivations"
        "gccarch-x86-64-v3"
        "kvm"
        "nixos-test"
        "uid-range"
      ];
      tarball-ttl = 3600;
      trust-tarballs-from-git-forges = true;
      trusted-public-keys = [
        "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.iog.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ghostty.cachix.org-1:WTrThZtR2ZuQirrZvrmRQKHehTOnBg9xZMQ6VIHdUso="
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "kernel-overlay.cachix.org-1:rUvSa2sHn0a7RmwJDqZvijlzZHKeGvmTQfOUr2kaxr4="
        "lix.systems:1cjqjprsDP3zzjn7mzdJM1a3RmwSLQZWMWePVETGuEk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "qnix:d/dwC2PX1o/KXVnuRbcMbNkTatKF59gZ6z4lWQtaonI="
      ];
      trusted-substituters = [
        "https://bunker.cachix.org"
        "https://cache.nixos.org"
        "https://cache.garnix.io"
        "https://hydra.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-users = [
        "root"
        "@wheel"
        "phaedrus"
      ];
      upgrade-nix-store-path-url = [
        "https://github.com/nixos/nixpkgs/raw/master/nixos/modules/installer/tools/nix-fallback-paths.nix"
      ];
      use-case-hack = false;
      use-cgroups = true;
      use-registries = true;
      use-sqlite-wal = true;
      use-xdg-base-directories = true;
      warn-dirty = false;
      warn-large-path-threshold = 0;
    };
    sshServe = {
      enable = true;
      protocol = "ssh";
      trusted = true;
      write = true;
    };
  };
}
