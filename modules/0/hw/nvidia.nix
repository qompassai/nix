# ~/.dotfiles/modules/0/hw/nvidia.nix
# -----------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ lib, pkgs, config, ... }:

{
  options.hardware.nvidia.enable = lib.mkEnableOption "Enable NVIDIA dGPU support";

  config = lib.mkIf config.hardware.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.open;
      open = true;
      nvidiaSettings = true;
      support32Bit = true;

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}

