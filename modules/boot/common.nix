# /qompassai/NixOS/modules/0/common.nix
# Qompass AI Nix common system configuration
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.system.common;
in {
  options.system.common = {
    enable = mkEnableOption "Enable common system configuration";
    hostname = mkOption {
      type = types.str;
      default = "qompass-workstation";
      description = "System hostname";
    };
  };
  config = mkIf cfg.enable {
    networking.hostName = cfg.hostname;
    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };
    services = {
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      fwupd.enable = true;
      thermald.enable = true;
      irqbalance.enable = true;
      system76-scheduler.enable = true;
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
      };
    };
    security = {
      rtkit.enable = true;
      polkit.enable = true;
      sudo.wheelNeedsPassword = false;
    };
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        builders-use-substitutes = true;
        max-jobs = "auto";
        cores = 0;
        build-cores = 0;
        max-silent-time = 3600;
        timeout = 7200;
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cuda-maintainers.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgKpQYt4+ZhKLDpDyFB6qhWXkn88tg="
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
    environment.systemPackages = with pkgs; [
      git
      curl
      wget
      htop
      neofetch
      tree
      intel-gpu-tools
      nvtop
      iotop
      gcc
      clang
      cmake
      pkg-config
      python3
      conda
      qiskit
    ];
  };
}
