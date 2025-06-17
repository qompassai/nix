# ~/.GH/Qompass/NixOS/modules/xdg/hyprland/hypr.d/graphics/angle.nix
# ------------------------------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  ANGLE_DEFAULT_PLATFORM = "vulkan";
  ANGLE_CAPTURE_SERIALIZE_STATE = "1";
  ANGLE_FEATURE_OVERRIDES_ENABLED = "prefer_vulkan";
  ANGLE_PLATFORM = "vulkan";
  ANGLE_PLATFORM_FEATURES = "vulkan_synchronization2";
}

