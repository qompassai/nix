# modules/desktop/hyprland/config/monitors.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktop.hyprland;
  monitorLayouts = {
    quad = {
      preferred = [
        "DP-1,preferred,0x0,1.0" # Leftmost
        "DP-5,preferred,2560x0,1.0" # Second from left
        "eDP-1,preferred,6400x0,1.0" # Third from left (laptop)
        "HDMI-A-1,preferred,8320x0,1.0" # Rightmost
      ];
      highRefresh = [
        "DP-1,2560x1440@143.932999,0x0,1.0"
        "DP-5,3840x1080@59.995998,2560x0,1.0"
        "eDP-1,1920x1200@144.001007,6400x0,1.0"
        "HDMI-A-1,2560x1440@143.932999,8320x0,1.0"
      ];
    };
    triple = {
      preferred = [
        "DP-1,preferred,0x0,1.0"
        "DP-5,preferred,2560x0,1.0"
        "eDP-1,preferred,6400x0,1.0"
      ];
      highRefresh = [
        "DP-1,2560x1440@143.932999,0x0,1.0"
        "DP-5,3840x1080@59.995998,2560x0,1.0"
        "eDP-1,1920x1200@144.001007,6400x0,1.0"
      ];
    };
    dual = {
      preferred = [
        "DP-1,preferred,0x0,1.0"
        "eDP-1,preferred,2560x0,1.0"
      ];
      highRefresh = [
        "DP-1,2560x1440@143.932999,0x0,1.0"
        "eDP-1,1920x1200@144.001007,2560x0,1.0"
      ];
    };
    single = {
      preferred = [
        "eDP-1,preferred,0x0,1.0"
      ];
      highRefresh = [
        "eDP-1,1920x1200@144.001007,0x0,1.0"
      ];
    };
  };
in {
  options.desktop.hyprland.monitors = {
    usePreferredResolution = mkOption {
      type = types.bool;
      default = true;
      description = "Use preferred resolution for all monitors";
    };
    enableHighRefreshRate = mkOption {
      type = types.bool;
      default = false;
      description = "Use high refresh rate specific resolutions";
    };
    monitorLayout = mkOption {
      type = types.enum ["quad" "triple" "dual" "single"];
      default = "quad";
      description = "Monitor layout configuration";
    };
    workspaceMapping = mkOption {
      type = types.bool;
      default = true;
      description = "Enable workspace to monitor mapping";
    };
  };
  config = mkIf cfg.enable {
    home-manager.users.phaedrus.wayland.windowManager.hyprland.settings = {
      monitor = let
        layout = monitorLayouts.${cfg.monitors.monitorLayout};
        resolutionType =
          if cfg.monitors.enableHighRefreshRate
          then "highRefresh"
          else "preferred";
      in
        layout.${resolutionType}
        ++ [
          ",preferred,auto,auto"
        ];
      workspace = mkIf cfg.monitors.workspaceMapping (
        if cfg.monitors.monitorLayout == "quad"
        then [
          "1, monitor:DP-1, default:true" # Main workspace on leftmost
          "2, monitor:DP-1"
          "3, monitor:DP-5" # Second monitor workspaces
          "4, monitor:DP-5"
          "5, monitor:eDP-1" # Laptop screen workspaces
          "6, monitor:eDP-1"
          "7, monitor:HDMI-A-1" # Rightmost monitor workspaces
          "8, monitor:HDMI-A-1"
          "9, monitor:HDMI-A-1"
          "10, monitor:HDMI-A-1"
        ]
        else if cfg.monitors.monitorLayout == "triple"
        then [
          "1, monitor:DP-1, default:true"
          "2, monitor:DP-1"
          "3, monitor:DP-1"
          "4, monitor:DP-5"
          "5, monitor:DP-5"
          "6, monitor:DP-5"
          "7, monitor:eDP-1"
          "8, monitor:eDP-1"
          "9, monitor:eDP-1"
          "10, monitor:eDP-1"
        ]
        else if cfg.monitors.monitorLayout == "dual"
        then [
          "1, monitor:DP-1, default:true"
          "2, monitor:DP-1"
          "3, monitor:DP-1"
          "4, monitor:DP-1"
          "5, monitor:DP-1"
          "6, monitor:eDP-1"
          "7, monitor:eDP-1"
          "8, monitor:eDP-1"
          "9, monitor:eDP-1"
          "10, monitor:eDP-1"
        ]
        else [
          "1, monitor:eDP-1, default:true"
        ]
      );
    };
  };
}
