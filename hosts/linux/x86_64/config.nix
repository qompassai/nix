# /etc/nixos/hosts/linux/x86_64/config.nix
# Qompass AI Nixos Linux x86_64 Config
# Copyright (C) 2025 Qompass AI, All rights reserved
{ inputs, ... }:
{
  imports = [
    ./boot.nix
    ./environment.nix
    ./hardware.nix
    ./misc.nix
    ./nix.nix
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./users.nix
    ./variables.nix
    ./xdg.nix
  ];
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        settings = {
          globalOptions = {
          };
        };
      };
    };
  };
  nixpkgs = {
    buildPlatform = "x86_64-linux";
    config = {
      allowAliases = false;
      allowBroken = false;
      allowUnfree = true;
      allowUnsupportedSystem = false;
      checkMeta = false;
      cudaSupport = true;
      enableParallelBuildingByDefault = true;
      hashedMirrors = [
        "https://cache.nixos.org/tarballs"
        "https://mirror.csclub.uwaterloo.ca/nixpkgs"
        "https://mirror.csclub.uwaterloo.ca/nixpkgs"
        "https://mirrors.ocf.berkeley.edu/nixpkgs"
        "https://mirror.sfo.sonic.net/nixpkgs"
        "https://nix-mirror.s3.amazonaws.com"
        "https://tarballs.nixos.org"
        "https://releases.nixos.org"
      ];
      hostPlatform = "x86_64-linux";
      localSystem = "x86_64-linux";
      overlays = [
        (final: prev: {
          passt = prev.passt.overrideAttrs (old: {
            meta = (old.meta or { }) // {
              maintainers = [ ];
            };
          });
        })
        (final: prev: {
          passt = null;
        })
        (final: prev: {
          hypr-unstable = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
        })
      ];
      strictDepsByDefault = true;
      structuredAttrsByDefault = false;
      warnUndeclaredOptions = false;
    };
  };
  networking = {
    hostName = "primo";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      22
      2342
      5432
      6379
    ];
    firewall.enable = true;
  };
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "weekly";
      operation = "switch";
      randomizedDelaySec = "3600";
    };
    includeBuildDependencies = true;
    rebuild.enableNg = true;
    stateVersion = "25.11";
    switch.enable = true;
    tools = {
      nixos-enter.enable = true;
      nixos-generate-config.enable = true;
      nixos-option.enable = true;
      nixos-rebuild.enable = true;
    };
  };
  systemd = {
    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services."nix-daemon".serviceConfig = {
      Slice = "nix-daemon.slice";
      OOMScoreAdjust = 1000;
    };
  };
  time = {
    timeZone = "America/Los_Angeles";
  };
}
