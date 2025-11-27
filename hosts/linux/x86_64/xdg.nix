# xdg.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ pkgs, ... }:
{
  xdg = {
    autostart.enable = true;
    icons.enable = true;
    menus.enable = true;
    mime.enable = true;
    sounds.enable = true;
    terminal-exec.enable = true;
    portal = {
      enable = true;
      wlr.enable = false;
      xdgOpenUsePortal = true;
      config = {
        common.default = [
          "hyprland"
          "gtk"
        ];
        hyprland.default = [
          "hyprland"
          "gtk"
        ];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-shana
        pkgs.xdg-desktop-portal-termfilechooser
      ];
    };
  };
}
