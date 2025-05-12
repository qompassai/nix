# ~/.dotfiles/apps/browser.nix
# ----------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brave
    chromium
    firefox
    vivaldi
  ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };
}
