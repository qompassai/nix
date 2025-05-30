# ~/.dotfiles/modules/1/media.nix
# -------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true; 
  };
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    obs-studio
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })

    vulkan-tools
    libva-utils
    nvidia-vaapi-driver
  ];
}
