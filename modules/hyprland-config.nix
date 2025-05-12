# ~/.dotfiles/modules/hyprland-config.nix
# ---------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
  };

  xdg.configFile = {
    "hypr" = {
      source = ./hypr;
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    hypridle
    hyprlock
    wl-clipboard
    wlr-randr
  ];
}
