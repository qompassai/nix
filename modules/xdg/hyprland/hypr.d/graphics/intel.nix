# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/intel.nix
# ------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

#https://intel.github.io/llvm/EnvironmentVariables.html

{
EGL_DRIVER = "iris";
__EGL_VENDOR_LIBRARY_FILENAMES="/home/phaedrus/.local/share/glvnd/egl_vendor.d/50_mesa.json:/home/phaedrus/.local/share/glvnd/egl_vendor.d/10_nvidia.json";
}
