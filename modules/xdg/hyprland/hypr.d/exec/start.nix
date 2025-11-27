# /qompassai/nur-packages/modules/xdg/hyprland/hypr.d/exec/start.nix
# /qompassai/nix/modules/xdg/hyprland/hypr.d/exec/start.nix
# Copyright (C) 2025 Qompass AI, All rights reserved
# --------------------------------------------------------------
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
  cacheDirectoryCommands = [
    "mkdir -p ${user.home}/.cache/{mesa_shader_cache_db,nvidia/{GLCache,ComputeCache/{TensorRT,engine_cache}},vulkan/{pipeline_cache,shader_cache},opencl-cache,tensorrt/{engine_cache,timing_cache},UnrealEngine/{ShaderCache,BinaryCache},hyprland/{logs,tmp},xdg-desktop-portal-wlr,xdg-desktop-portal}"
    "mkdir -p ${user.home}/.local/share/{vulkan/{implicit_layer.d,config.d,settings.d,icd.d,explicit_layer.d,registry},UnrealEngine/Common/{DerivedDataCache,ShaderCache},pocl/cuda}"
    "chmod 755 ${user.home}/.cache/{mesa_shader_cache_db,nvidia,vulkan,UnrealEngine,mesa_shader_cache/{ShaderCache,BinaryCache},opencl-cache,tensorrt,hyprland}"
    "chmod 755 ${user.home}/.local/share/{vulkan,UnrealEngine,UnrealEngine/Common,UnrealEngine/Common/{DerivedDataCache,ShaderCache},pocl}"
  ];
in {
  options.desktop.hyprland.exec = {
    cursorSize = mkOption {
      type = types.int;
      default = 24;
      description = "Cursor size";
    };
    cursorTheme = mkOption {
      type = types.str;
      default = "Bibata-Modern-Ice";
      description = "Cursor theme name";
    };
    enableAudioServices = mkOption {
      type = types.bool;
      default = true;
      description = "Enable audio services (PipeWire, WirePlumber)";
    };
    enableBluetooth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Bluetooth services";
    };
    enableCacheDirectories = mkOption {
      type = types.bool;
      default = true;
      description = "Create graphics and shader cache directories";
    };
    enableClipboard = mkOption {
      type = types.bool;
      default = true;
      description = "Enable clipboard management services";
    };
    enableDesktopServices = mkOption {
      type = types.bool;
      default = true;
      description = "Enable desktop services (waybar, dunst, etc.)";
    };
    enableDock = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nwg-dock-hyprland";
    };
    enableWallpaper = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hyprpaper wallpaper service";
    };
    wallpaperConfig = mkOption {
      type = types.str;
      default = "${user.home}/.config/hypr/hypr.d/wallpaper/hyprpaper.conf";
      description = "Path to hyprpaper configuration file";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bibata-cursors
      blueman
      bluez
      cliphist
      dunst
      easyeffects
      hyprpaper
      nwg-dock-hyprland
      pipewire
      tmux
      waybar
      wireplumber
      wl-clip-persist
      wl-clipboard
      xdg-desktop-portal
      xdg-desktop-portal-hyprland
    ];
    services = {
      blueman.enable = mkIf cfg.exec.enableBluetooth true;
      dbus.enable = true;
      pipewire = mkIf cfg.exec.enableAudioServices {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
    };
    home-manager.users.${primaryUser}.wayland.windowManager.hyprland.settings = {
      exec-once = let
        systemInit = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "export SWAYSOCK=$HYPRLAND_INSTANCE_SIGNATURE"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user start hyprpolkitagent"
          ''tmux setenv -g HYPRLAND_INSTANCE_SIGNATURE "$HYPRLAND_INSTANCE_SIGNATURE"''
          "/usr/lib/xdg-desktop-portal"
          "xdg-desktop-portal-hyprland"
        ];
        audioServices = optionals cfg.exec.enableAudioServices [
          "easyeffects --gapplication-service"
        ];
        cacheSetup = optionals cfg.exec.enableCacheDirectories cacheDirectoryCommands;
        clipboardServices = optionals cfg.exec.enableClipboard [
          "cliphist store"
          "clipboard-sync"
          "wl-clip-persist --clipboard regular"
          "wl-paste --type image --watch cliphist store"
          "wl-paste --type text --watch cliphist store"
          "wl-paste -p --watch wl-copy"
        ];
        desktopServices = optionals cfg.exec.enableDesktopServices [
          "dunst"
          "hyprctl setcursor ${cfg.exec.cursorTheme} ${toString cfg.exec.cursorSize}"
          "waybar"
        ];
        dockService = optionals cfg.exec.enableDock [
          ''sleep 5 && nwg-dock-hyprland -i 32 -w 5 -mb 10 -ml 10 -mr 10 -x -c "wofi --show drun" -lp start''
        ];
        bluetoothServices = optionals cfg.exec.enableBluetooth [
          "/usr/lib/bluetooth/bluetoothd"
          "blueman-applet"
          "bluetoothctl agent on"
          "bluetoothctl default-agent"
        ];
        wallpaperService = optionals cfg.exec.enableWallpaper [
          "hyprpaper --config ${cfg.exec.wallpaperConfig}"
        ];
        allServices = systemInit ++ audioServices ++ cacheSetup ++ clipboardServices ++ desktopServices ++ dockService ++ bluetoothServices ++ wallpaperService;
      in
        sort lessThan allServices;
      exec = sort lessThan (optionals cfg.exec.enableAudioServices [
        "systemctl --user start pipewire"
        "systemctl --user start pipewire-pulse"
        "systemctl --user start wireplumber"
      ]);
    };
  };
}
