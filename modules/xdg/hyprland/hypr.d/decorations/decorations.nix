# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/decorations/decorations.nix
# ---------------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
# modules/desktop/hyprland/config/decorations.nix
# Copyright (C) 2025 Qompass AI, All rights reserved
# -------------------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktop.hyprland;
  primaryUser = builtins.head (
    builtins.filter (user: config.users.users.${user}.uid >= 1000)
    (builtins.attrNames config.users.users)
  );

  user = config.users.users.${primaryUser};
in {
  options.desktop.hyprland.decorations = {
    enableShaders = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom shaders";
    };
    shaderPreset = mkOption {
      type = types.enum ["none" "vibrance" "chromatic_abberation" "crt" "drugs" "extradark" "invert" "solarized"];
      default = "none";
      description = "Predefined shader preset to use";
    };
  };
  config = mkIf cfg.enable {
    home-manager.users.${primaryUser} = {
      home.file = mkIf cfg.decorations.enableShaders {
        ".config/hypr/shaders/vibrance.frag".source = ./raw-configs/hypr.d/decorations/shaders/vibrance.frag;
        ".config/hypr/shaders/chromatic_abberation.frag".source = ./raw-configs/hypr.d/decorations/shaders/chromatic_abberation.frag;
        ".config/hypr/shaders/crt.frag".source = ./raw-configs/hypr.d/decorations/shaders/crt.frag;
        ".config/hypr/shaders/drugs.frag".source = ./raw-configs/hypr.d/decorations/shaders/drugs.frag;
        ".config/hypr/shaders/extradark.frag".source = ./raw-configs/hypr.d/decorations/shaders/extradark.frag;
        ".config/hypr/shaders/invert.frag".source = ./raw-configs/hypr.d/decorations/shaders/invert.frag;
        ".config/hypr/shaders/solarized.frag".source = ./raw-configs/hypr.d/decorations/shaders/solarized.frag;
      };
      wayland.windowManager.hyprland.settings = {
        decoration = {
          screen_shader =
            mkIf (cfg.decorations.enableShaders && cfg.decorations.shaderPreset != "none")
            "${user.home}/.config/hypr/shaders/${cfg.decorations.shaderPreset}.frag";
        };
      };
    };
  };
}
