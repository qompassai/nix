# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/vulkan.nix
# -------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
  VK_ICD_FILENAMES = "/home/phaedrus/.local/share/vulkan/icd.d";
  VK_KHR_PRESENT_WAIT_ENABLED = "1";
  # __VK_LAYER_NV_optimus = "NVIDIA_only";
  VK_LAYER_PATH = "/home/phaedrus/.local/share/vulkan/explicit_layer.d";
  VK_PRESENT_MODE = "mailbox";
  VK_LOADER_LAYERS_DISABLE = "VK_LAYER_MESA_overlay:VK_LAYER_MESA_device_select:VK_LAYER_LUNARG_api_dump:VK_LAYER_LUNARG_monitor";
  MESA_VK_WSI_LIST = "wayland";
  # VK_DEVICE_FILTER = "intel";
  # VK_LAYER_PATH = "/home/phaedrus/.local/share/vulkan/implicit_layer.d"
  VK_LOADER_DISABLE_LAYER_MESA = "1";
  VK_WSI_MODE = "wayland";
}
