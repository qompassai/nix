# /qompassai/NixOS/modules/xdg/hyprland/default.nix
# Qompass AI Nix Hyprland default
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{ config, pkgs, lib, ... }:

let
  gtkEnv      = import ./hypr.d/graphics/gtk.nix;
  mesaEnv     = import ./hypr.d/graphics/mesa.nix;
  nvidiaEnv   = import ./hypr.d/graphics/nvidia.nix;
  vulkanEnv   = import ./hypr.d/graphics/vulkan.nix;
  angleEnv    = import ./hypr.d/graphics/angle.nix;
  x11Env      = import ./hypr.d/graphics/x11.nix;
  intelEnv    = import ./hypr.d/graphics/intel.nix;
  hyprGraphicsEnv = import ./hypr.d/graphics/hypr_graphics.nix;

  allEnvs = lib.foldl' (a: b: a // b) {} [
    gtkEnv
    mesaEnv
    nvidiaEnv
    vulkanEnv
    angleEnv
    x11Env
    intelEnv
    hyprGraphicsEnv
  ];

  genKeybinds   = import ./hypr.d/keybinds/gen_keybinds.nix;
  utilKeybinds  = import ./hypr.d/keybinds/util_bindings.nix;

  coreConfig    = import ./hypr.d/core/core.nix;
  monitorsConfig= import ./hypr.d/core/monitors.nix;
  decorations   = import ./hypr.d/decorations/decorations.nix;
  appsExec      = import ./hypr.d/exec/apps.nix;
  startExec     = import ./hypr.d/exec/start.nix;
in
{
  environment.sessionVariables = allEnvs;

  environment.etc = {
    "hypr/hypr.d/keybinds/gen_keybinds.conf".text = genKeybinds.content;
    "hypr/hypr.d/keybinds/util_bindings.conf".text = utilKeybinds.content;
    "hypr/hypr.d/core/core.conf".text = coreConfig.content;
    "hypr/hypr.d/core/monitors.conf".text = monitorsConfig.content;
    "hypr/hypr.d/decorations/decorations.conf".text = decorations.content;
    "hypr/hypr.d/exec/apps.conf".text = appsExec.content;
    "hypr/hypr.d/exec/start.conf".text = startExec.content;
  };

  programs.hyprland.enable = true;
  programs.hyprland.package = pkgs.hyprland;
}

