# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/nvidia.nix
# -------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

opengl.nvidia_anti_flicker = true;

  CUDA_VISIBLE_DEVICES = "0,1,2,3,4";
  DRI_PRIME = "1";
  DRI_PRIME_RENDER_OFFLOAD = "1";
  GBM_BACKEND = "nvidia-drm";
  __GL_ALLOW_FLIPPING = "1";
  __GL_ALLOW_UNOFFICIAL_PROTOCOL = "1";
  # __GL_CACHE_MAX_SIZE not set (unlimited)
  __GL_MAX_FRAME_AGE = "3";
  __GL_MaxFramesAllowed = "1";
  __GL_GSYNC_ALLOWED = "1";
  __GL_SYNC_TO_VBLANK = "1";
  __GL_SHADER_DISK_CACHE_PATH = "/home/phaedrus/.cache/nvidia/GLCache";
  __GL_SHADER_DISK_CACHE = "1";
  __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  __GL_THREADED_OPTIMIZATIONS = "1";
  __GL_VRR_ALLOWED = "1";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  LIBVA_DRIVER_NAME = "nvidia";
  __NV_PRIME_RENDER_OFFLOAD = "1";
  __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
  NVD_BACKEND = "direct";
  VK_LAYER_NV_optimus = "1";
}
