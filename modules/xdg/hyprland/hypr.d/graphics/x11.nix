# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/x11.nix
# ----------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  SDL_VIDEODRIVER = "wayland,x11";
  QT_QPA_PLATFORM = "wayland;xcb";
  WLR_EGL_NO_X11 = "1";
  WLR_X11_NO_ATOMS = "1";
  XCURSOR_SIZE = "32";
  XWAYLAND_NO_GLAMOR = "1";
}

