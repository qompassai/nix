# ~/.dotfiles/modules/0/hw/intel.nix
# ----------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ lib, pkgs, ... }:

{
  options.hardware.intel.enable = lib.mkEnableOption "Enable Intel iGPU support";

  config = lib.mkIf config.hardware.intel.enable {
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libva
        libva-utils
        libvdpau-va-gl
      ];
    };
  };
}

