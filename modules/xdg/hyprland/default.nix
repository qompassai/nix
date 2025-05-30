# /qompassai/NixOS/modules/xdg/hyprland/default.nix
# Qompass AI Nix Hyprland default
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.desktop.hyprland;
  readConfig = path: builtins.readFile (./raw-configs + "/${path}");
in {
  imports = [
    ./config/animations.nix
    ./config/core.nix
    ./config/decorations.nix
    ./config/exec.nix
    ./config/graphics.nix
    ./config/input.nix
    ./config/keybinds.nix
    ./config/layouts.nix
    ./config/media.nix
    ./config/ml.nix
    ./config/rules.nix
    ./config/wallpaper.nix
  ];
  options.desktop.hyprland = {
    enable = mkEnableOption "Enable Hyprland window manager";
    useRawConfigs = mkOption {
      type = types.bool;
      default = true;
      description = "Use existing .conf files instead of Nix syntax";
    };
    configMode = mkOption {
      type = types.enum ["raw" "nix" "hybrid"];
      default = "hybrid";
      description = "Configuration mode: raw (use .conf files), nix (pure Nix), or hybrid";
    };
    enableDebug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug configurations";
    };
    enableML = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ML-specific configurations";
    };
    enableNvidiaPatches = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA-specific patches";
    };
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package =
        mkIf (inputs ? hyprland)
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
    home-manager.users.phaedrus = {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        xwayland.enable = true;
        extraConfig = mkIf cfg.useRawConfigs (
          concatStringsSep "\n" [
            (readConfig "hypr.d/core.conf")
            (readConfig "hypr.d/animations.conf")
            (readConfig "hypr.d/decorations.conf")
            (readConfig "hypr.d/input.conf")
            (readConfig "hypr.d/layouts.conf")
            (readConfig "hypr.d/rules.conf")
            (readConfig "hypr.d/keybinds.conf")
            (readConfig "hypr.d/exec.conf")
            (readConfig "hypr.d/graphics.conf")
            (readConfig "hypr.d/media.conf")
            (optionalString cfg.enableML (readConfig "hypr.d/ml.conf"))
            (optionalString cfg.enableDebug (readConfig "hypr.d/debug.conf"))

            "source = ~/.config/hypr/hypr.d/wallpaper/hyprpaper.conf"
          ]
        );
      };
      home.file = mkIf cfg.useRawConfigs (
        listToAttrs (
          map (path: {
            name = ".config/hypr/${path}";
            value = {source = ./raw-configs + "/${path}";};
          }) [
            "hypr.d/animations/animations-fast.conf"
            "hypr.d/animations/animations-optimized.conf"
            "hypr.d/core/env.conf"
            "hypr.d/core/general.conf"
            "hypr.d/core/monitors.conf"
            "hypr.d/decorations/decoration.conf"
            "hypr.d/decorations/shaders/chromatic_abberation.frag"
            "hypr.d/decorations/shaders/crt.frag"
            "hypr.d/decorations/shaders/drugs.frag"
            "hypr.d/decorations/shaders/extradark.frag"
            "hypr.d/decorations/shaders/invert.frag"
            "hypr.d/decorations/shaders/solarized.frag"
            "hypr.d/exec/apps.conf"
            "hypr.d/exec/start.conf"
            "hypr.d/graphics/nvidia.conf"
            "hypr.d/graphics/intel.conf"
            "hypr.d/graphics/vulkan.conf"
            "hypr.d/input/cursor.conf"
            "hypr.d/input/device.conf"
            "hypr.d/keybinds/gen_bindings.conf"
            "hypr.d/keybinds/media_bindings.conf"
            "hypr.d/keybinds/util_bindings.conf"
            "hypr.d/keybinds/workspace_bindings.conf"
            "hypr.d/layouts/dwindle.conf"
            "hypr.d/layouts/master.conf"
            "hypr.d/layouts/gestures.conf"
            "hypr.d/layouts/misc.conf"
            "hypr.d/media/animations.conf"
            "hypr.d/media/pipewire.conf"
            "hypr.d/media/render.conf"
            "hypr.d/ml/intel.conf"
            "hypr.d/ml/tensorflow.conf"
            "hypr.d/rules/window_rules.conf"
            "hypr.d/rules/layer_rules.conf"
            "hypr.d/rules/workspaces_rules.conf"
            "hypr.d/wallpaper/hyprpaper.conf"
            "hypr.d/wallpaper/wp/wall0.png"
            "hypridle.conf"
            "hyprlock.conf"
          ]
        )
      );
    };
    environment.systemPackages = with pkgs; [
      hyprpaper
      hyprpicker
      hyprcursor
      hypridle
      hyprlock
      grimblast
      slurp
      grim
      rofi-wayland
      dunst
      waybar
      alacritty
      thunar
    ];
  };
}
