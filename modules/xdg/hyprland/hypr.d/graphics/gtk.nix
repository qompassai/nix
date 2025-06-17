# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/gtk.nix
# ----------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved
{
  # GDK_DISABLE = "gl,gl-api,gles-api,egl,vulkan,dmabuf,offload,threads";
  # GDK_GL_DISABLE = "";
  GDK_BACKEND = "wayland,x11";
  GDK_PIXBUF_MODULE_FILE = "/usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
  GDK_SCALE = "1";
  GSK_CACHE_TIMEOUT = "15";
  GSK_RENDERER = "opengl,vulkan";
  GTK_USE_PORTAL = "1";
  GTK_THEME = "Adwaita:dark";
  GTK_A11Y = "test";
  GTK_CSD = "1";
  GTK_MEDIA = "gstreamer";
  # GDK_VULKAN_DISABLE = "dmabuf,ycbr,sempahore-export,sempahore-import,incremental-present,swapchain-maintenance"; # commented out
}

