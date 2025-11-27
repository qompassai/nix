# /qompassai/nur-packages/modules/0/nv-prime.nix
# Qompass AI Nix nvidia-drivers module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia-prime;
in {
  options.drivers.nvidia-prime = {
    amdgpuBusID = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "AMD GPU PCI bus ID for AMD+NVIDIA hybrid setups";
      example = "PCI:6:0:0";
    };
    allowExternalGpu = mkOption {
      type = types.bool;
      default = false;
      description = "Allow external GPU usage with Prime";
    };
    enable = mkEnableOption "Enable Nvidia Prime Hybrid GPU";
    intelBusID = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
      description = "Intel GPU PCI bus ID (find with: lspci | grep VGA)";
      example = "PCI:0:2:0";
    };
    mode = mkOption {
      type = types.enum ["offload" "sync" "reverseSync"];
      default = "offload";
      description = "Prime operation mode: offload (on-demand), sync (always), or reverseSync (NVIDIA as primary)";
    };
    nvidiaBusID = mkOption {
      type = types.str;
      default = "PCI:0:2:0";
      description = "NVIDIA GPU PCI bus ID (find with: lspci | grep NVIDIA)";
      example = "PCI:1:0:0";
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.drivers.nvidia.enable or false;
        message = "nvidia-prime requires drivers.nvidia.enable = true";
      }
    ];
    environment = {
      sessionVariables = mkIf (cfg.mode == "offload") {
        LIBVA_DRIVER_NAME = "nvidia";
      };
      systemPackages = with pkgs;
        mkIf (cfg.mode == "offload") [
          (writeShellScriptBin "nvidia-offload" ''
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export __NV_PRIME_RENDER_OFFLOAD=1
            export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
            export __VK_LAYER_NV_optimus=NVIDIA_only
            exec "$@"
          '')
          (writeShellScriptBin "nvidia-offload-vulkan" ''
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export __NV_PRIME_RENDER_OFFLOAD=1
            export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
            export __VK_LAYER_NV_optimus=NVIDIA_only
            export VK_ICD_FILENAMES=${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.json
            exec "$@"
          '')
        ];
    };
    hardware.nvidia = {
      powerManagement = {
        enable = mkDefault true;
        finegrained = mkDefault (cfg.mode == "offload");
      };

      prime = {
        allowExternalGpu = cfg.allowExternalGpu;
        amdgpuBusId = mkIf (cfg.amdgpuBusID != null) cfg.amdgpuBusID;
        intelBusId = cfg.intelBusID;
        nvidiaBusId = cfg.nvidiaBusID;
        offload = mkIf (cfg.mode == "offload") {
          enable = true;
          enableOffloadCmd = true;
        };
        reverseSync.enable = mkIf (cfg.mode == "reverseSync") true;
        sync.enable = mkIf (cfg.mode == "sync") true;
      };
    };
    specialisation = mkIf (cfg.mode == "offload") {
      nvidia-sync = {
        configuration = {
          hardware.nvidia.prime = {
            offload.enable = mkForce false;
            sync.enable = mkForce true;
          };
        };
      };
    };
  };
}
