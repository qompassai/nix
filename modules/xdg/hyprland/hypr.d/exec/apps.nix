# /qompassai/nix/modules/xdg/hyprland/hypr.d/exec/apps.nix
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
  options.desktop.hyprland.apps = {
    browser = mkOption {
      type = types.str;
      default = "firefox-developer-edition";
      description = "Default web browser";
    };
    calendar = mkOption {
      type = types.str;
      default = "khal interactive";
      description = "Calendar application";
    };
    editor = mkOption {
      type = types.str;
      default = "nvim";
      description = "Default text editor";
    };
    fileManager = mkOption {
      type = types.str;
      default = "thunar";
      description = "Default file manager";
    };
    launcher = mkOption {
      type = types.str;
      default = "fuzzel";
      description = "Application launcher";
    };
    music = mkOption {
      type = types.str;
      default = "ncspot";
      description = "Music player";
    };
    terminal = mkOption {
      type = types.str;
      default = "ghostty";
      description = "Default terminal emulator";
    };
    entryBackgroundColor = mkOption {
      type = types.str;
      default = "rgba(41000311)";
      description = "Entry background color";
    };
    entryBorderColor = mkOption {
      type = types.str;
      default = "rgba(896E6C55)";
      description = "Entry border color";
    };
    entryColor = mkOption {
      type = types.str;
      default = "rgba(FFDAD6FF)";
      description = "Entry color";
    };
    fontFamily = mkOption {
      type = types.str;
      default = "Rubik Light";
      description = "Default font family";
    };
    fontFamilyClock = mkOption {
      type = types.str;
      default = "Rubik Light";
      description = "Clock font family";
    };
    fontMaterialSymbols = mkOption {
      type = types.str;
      default = "Material Symbols Rounded";
      description = "Material symbols font";
    };
    textColor = mkOption {
      type = types.str;
      default = "rgba(FFDAD6FF)";
      description = "Text color";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      blueman
      btop
      firefox-devedition-bin
      fuzzel
      ghostty
      hyprlock
      hyprpaper
      hyprpicker
      hyprshot
      khal
      makoctl
      material-symbols
      ncspot
      pass
      rubik
      thunar
      usbview
      wireplumber
      wl-clipboard
      wlogout
      wofi
      xdg-desktop-portal-hyprland
    ];
    home-manager.users.${primaryUser}.wayland.windowManager.hyprland.settings = let
      appVariables = {
        "$bluetooth" = "blueman-manager";
        "$browser" = cfg.apps.browser;
        "$calendar" = cfg.apps.calendar;
        "$clipboard" = "wl-copy";
        "$color_picker" = "hyprpicker";
        "$editor" = cfg.apps.editor;
        "$emoji_picker" = "wofi-emoji";
        "$entry_background_color" = cfg.apps.entryBackgroundColor;
        "$entry_border_color" = cfg.apps.entryBorderColor;
        "$entry_color" = cfg.apps.entryColor;
        "$exit" = "$launcher";
        "$fileManager" = cfg.apps.fileManager;
        "$font_family" = cfg.apps.fontFamily;
        "$font_family_clock" = cfg.apps.fontFamilyClock;
        "$font_material_symbols" = cfg.apps.fontMaterialSymbols;
        "$launcher" = cfg.apps.launcher;
        "$lock" = "hyprlock";
        "$logout" = "hyprctl dispatch exit";
        "$menu" = "wofi --show drun";
        "$music" = cfg.apps.music;
        "$network" = "nmtui";
        "$notify" = "makoctl dismiss";
        "$password_manager" = "pass";
        "$password_menu" = "pass | wofi --dmenu | xargs pass show";
        "$power_menu" = "wlogout";
        "$process_monitor" = "btop";
        "$screen_share" = "xdg-desktop-portal-hyprland";
        "$screenshot" = "hyprshot -m region";
        "$terminal" = cfg.apps.terminal;
        "$text_color" = cfg.apps.textColor;
        "$update" = "pkcon update";
        "$usb" = "usbview";
        "$volume_down" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "$volume_mute" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "$volume_up" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "$wallpaper" = "hyprpaper";
        "$weather" = "wttr.in";
        "$window_switcher" = "wofi --show window";
      };
    in
      appVariables;
  };
}
