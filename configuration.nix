# ~/.dotfiles/configuration.nix
# -----------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, pkgs, ... }:

{
  imports = [
    ./environment.nix
    ./modules/0/boot.nix
    ./modules/0/common.nix
    ./modules/0/hardware.nix
    ./modules/0/kernel.nix
    ./modules/1/browser.nix
    ./modules/1/media.nix
    ./modules/1/pro.nix
    ./modules/1/zoom.nix
    ./modules/2/git.nix
    ./modules/2/golang.nix
    ./modules/2/jj.nix
    ./modules/2/python.nix
    ./modules/2/rustlang.nix
    ./modules/2/ziglang.nix
    ./modules/hyprland-config.nix
  ];

  hardware.opengl.enable = true;
  services.xserver.videoDrivers = [ "nvidia" "modesetting" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    open = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.nvidia-container-toolkit.enable = true;
}

