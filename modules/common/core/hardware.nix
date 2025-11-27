# hardware.nix
# Qompass AI Common Core Hardware Config
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  lib,
  pkgs,
  platform,
  system ? pkgs.system,
  cpuType ? null,
  gpuType ? null,
}:
let
  baseHardware = {
    enableAllFirmware = true;
    firmwareCompression = "zstd";
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics.enable = true;
  };

  hardwareTable = {
    "linux-x86_64-linux" = {
      cpu = {
        intel.updateMicrocode = true;
      };
      graphics.extraPackages = with pkgs; [
        mesa
        nvtop
        vulkan-tools
      ];
      nvidia = {
        dynamicBoost.enable = true;
        open = true;
        modesetting.enable = true;
        prime.enable = true;
        videoAcceleration = true;
      };
      intel-gpu-tools.enable = true;
    };
    "linux-aarch64-linux" = {
      cpu.arm.neon.enable = true;
      graphics.extraPackages = with pkgs; [
        mesa
        linuxFirmware
      ];
    };
    "darwin-x86_64-darwin" = {
      graphics.extraPackages = with pkgs; [ coreutils ];
      bluetooth.enable = false;
    };
    "nvidia-aarch64-linux" = {
      graphics.extraPackages = with pkgs; [
        cudaPackages.cudatoolkit
        linuxFirmware
      ];
      nvidia.open = true;
    };
    "vm-x86_64-linux" = {
      graphics.extraPackages = with pkgs; [ qemu ];
      ksm.enable = true;
    };
  };
  key = "${platform}-${system}";
  uniqueHardware = if hardwareTable ? key then hardwareTable.${key} else { };
  cpuHardware =
    if cpuType == "intel" then
      { cpu.intel.updateMicrocode = true; }
    else if cpuType == "amd" then
      { cpu.amd.updateMicrocode = true; }
    else
      { };
  gpuHardware =
    if gpuType == "nvidia" then
      {
        graphics.extraPackages = (
          with pkgs;
          [
            nvidia_x11
            nvidia-settings
          ]
        );
      }
    else
      { };
  mergedHardware = baseHardware // uniqueHardware // cpuHardware // gpuHardware;
in
{
  hardware = mergedHardware;
}
