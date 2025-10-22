# xdg.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  pkgs,
  platform,
  system ? pkgs.system,
  desktopEnv ? null,
}:
let
  baseXdg = {
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
  xdgTable = {
    "linux-x86_64-linux" = baseXdg;
    "linux-aarch64-linux" = {
      portal.extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-termfilechooser
      ];
    };
    "darwin-x86_64-darwin" = {
      icons.enable = false;
      portal.enable = false;
    };
    "darwin-aarch64-darwin" = {
      icons.enable = false;
    };
    "vm-x86_64-linux" = {
      portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
    };
  };
  key = "${platform}-${system}";
  uniqueXdg = if xdgTable ? key then xdgTable.${key} else { };
  desktopXdg =
    if desktopEnv == "gnome" then
      {
        portal.config.gnome.default = [
          "gnome"
          "gtk"
        ];
        portal.extraPortals = [
          pkgs.xdg-desktop-portal-gnome
          pkgs.xdg-desktop-portal-gtk
        ];
      }
    else if desktopEnv == "kde" then
      {
        portal.config.kde.default = [
          "kde"
          "gtk"
        ];
        portal.extraPortals = [
          pkgs.xdg-desktop-portal-kde
          pkgs.xdg-desktop-portal-gtk
        ];
      }
    else
      { };
  mergedXdg = baseXdg // uniqueXdg // desktopXdg;
in
{
  xdg = mergedXdg;
}
