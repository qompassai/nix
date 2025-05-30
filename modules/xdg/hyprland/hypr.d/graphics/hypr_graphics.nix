# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/hypr_graphics.nix
# Copyright (C) 2025 Qompass AI, All rights reserved
# --------------------------------------------------------------------------
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
  options.desktop.hyprland.graphics = {
    cursorSize = mkOption {
      type = types.int;
      default = 24;
      description = "Cursor size";
    };
    cursorTheme = mkOption {
      type = types.str;
      default = "Bibata-Modern-Ice";
      description = "Hyprcursor theme";
    };
    enableElectronWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support for Electron applications";
    };
    enableGaming = mkOption {
      type = types.bool;
      default = true;
      description = "Enable gaming-specific optimizations";
    };
    enableMozillaWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support for Mozilla applications";
    };
    enableMultiGpu = mkOption {
      type = types.bool;
      default = true;
      description = "Enable multi-GPU configuration";
    };
    enableQtWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support for Qt applications";
    };
    enableWaylandApps = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland support for applications";
    };
    qtTheme = mkOption {
      type = types.enum ["hyprland-quick-style" "kvantum" "qt6ct"];
      default = "kvantum";
      description = "Qt platform theme";
    };
    rendererBackend = mkOption {
      type = types.enum ["gl" "gles2" "vulkan"];
      default = "gl";
      description = "Graphics renderer backend";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bibata-cursors
      kvantum
      libGL
      libGLU
      mesa
      qt6ct
      vulkan-loader
      vulkan-tools
      wayland
      wayland-protocols
      wayland-utils
    ];
    home-manager.users.${primaryUser}.wayland.windowManager.hyprland.settings = {
      env = let
        baseEnv = [
          "AQ_NO_MODIFIERS,1"
          "AQ_RENDER_BACKEND,${cfg.graphics.rendererBackend}"
          "__EGL_VENDOR_LIBRARY_FILENAMES,${user.home}/.local/share/glvnd/egl_vendor.d/50_mesa.json:${user.home}/.local/share/glvnd/egl_vendor.d/10_nvidia.json"
          "EGL_PLATFORM,wayland"
          "EGL_PLATFORM_ANGLE_TYPE,0x3450"
          "GST_PLUGIN_PATH,/usr/lib/gstreamer-1.0"
          "HYPRCURSOR_FORCE_SOFTWARE,1"
          "HYPRCURSOR_SIZE,${toString cfg.graphics.cursorSize}"
          "HYPRCURSOR_THEME,${cfg.graphics.cursorTheme}"
          "ILLOGICAL_IMPULSE_VIRTUAL_ENV,${user.home}/.local/state/ags/.venv"
          "NIXOS_OZONE_WL,1"
          "OZONE_PLATFORM,auto"
          "WLR_RENDERER,${cfg.graphics.rendererBackend}"
          "WLR_RENDERER_ALLOW_SOFTWARE,1"
          "WLR_USE_LIBINPUT,1"
        ];
        multiGpuEnv = optionals cfg.graphics.enableMultiGpu [
          "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
          "AQ_MGPU_NO_EXPLICIT,1"
          "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
        ];
        waylandAppsEnv = optionals cfg.graphics.enableWaylandApps [
          "CLUTTER_BACKEND,wayland"
          "WEBKIT_FORCE_WAYLAND,1"
          "WEBVIEW_FORCE_WAYLAND,1"
        ];
        electronWaylandEnv = optionals cfg.graphics.enableElectronWayland [
          "DISCORD_ENABLE_WAYLAND,1"
          "ELECTRON_ENABLE_FEATURES,UseOzonePlatform,WaylandWindowDecorations"
          "ELECTRON_ENABLE_LOGGING,1"
          "ELECTRON_ENABLE_WAYLAND,1"
          "ELECTRON_FLAGS,--enable-wayland-ime --wayland-text-input-version=3"
          "ELECTRON_OZONE_PLATFORM,wayland"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
        ];
        mozillaWaylandEnv = optionals cfg.graphics.enableMozillaWayland [
          "MOZ_DBUS_REMOTE,1"
          "MOZ_ENABLE_WAYLAND,1"
          "MOZ_WEBRENDER,1"
        ];
        qtWaylandEnv = optionals cfg.graphics.enableQtWayland [
          "QML2_IMPORT_PATH,/usr/lib/qt6/qml"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_QPA_PLATFORMTHEME,${cfg.graphics.qtTheme}"
          "QT_SCALE_FACTOR,1"
          "QT_STYLE_OVERRIDE,${cfg.graphics.qtTheme}"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        ];
        gamingEnv = optionals cfg.graphics.enableGaming [
          "SDL_DYNAMIC_API,/usr/local/lib/libSDL3.so.0"
          "SDL_DYNAMIC_API_ALL,1"
          "SDL_VIDEO_X11_DGAMOUSE,0"
          "SDL_VIDEO_YUV_HWACCEL,1"
          "UE_WAYLAND_EGL_FORWARD,1"
        ];
        allEnv = baseEnv ++ multiGpuEnv ++ waylandAppsEnv ++ electronWaylandEnv ++ mozillaWaylandEnv ++ qtWaylandEnv ++ gamingEnv;
      in
        sort lessThan allEnv;
    };
  };
}
