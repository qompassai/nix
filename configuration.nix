# ~/.dotfiles/configuration.nix
# -----------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./hosts/default/config.nix
    ./modules/boot/boot.nix
    ./modules/boot/kernel.nix
    ./modules/boot/common.nix
    ./modules/hardware/hardware.nix
    ./modules/hardware/intel.nix
    ./modules/hardware/nvidia.nix
    ./modules/dev/python.nix
    ./modules/dev/rust.nix
    ./environment.nix
  ];

  hardware.opengl.enable = true;
  services.xserver.videoDrivers = ["nvidia" "modesetting"];
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
  system.boot.enable = true;
  system.kernel.enable = true;
  hardware.qompass.enable = true;
  hardware.intel.enable = true;
  services.qompass.networking.enable = true;
  services.qompass.security.enable = true;
  desktop.fonts.enable = true;
}
