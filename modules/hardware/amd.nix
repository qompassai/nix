# /qompassai/nur-packages/modules/0/amd-drivers.nix
# Qompass AI Nix amd-drivers module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.drivers.amdgpu;
in {
  options.drivers.amdgpu = {
    enable = mkEnableOption "Enable AMD Graphics Drivers";
    enableCompute = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AMD GPU compute capabilities (ROCm, OpenCL, HIP)";
    };
    enableMachineLearning = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AMD machine learning libraries (MIOpen, rocBLAS)";
    };
    enableMediaAcceleration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AMD hardware video acceleration (VAAPI, AMF)";
    };
    enableOverclocking = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GPU overclocking and power management tools";
    };
    enableROCm = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ROCm platform for GPU computing";
    };
    enableVulkan = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Vulkan support for AMD graphics";
    };
    rocmVersion = mkOption {
      type = types.enum ["5" "6"];
      default = "6";
      description = "ROCm version to use";
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(config.drivers.nvidia-prime.enable or false)
          || (config.drivers.nvidia-prime.amdgpuBusID != null);
        message = "When using AMD + NVIDIA Prime, amdgpuBusID must be specified";
      }
    ];
    boot = {
      initrd.kernelModules = ["amdgpu"];
      kernelModules = ["amdgpu"];
      kernelParams =
        [
          "amdgpu.dpm=1"
          "amdgpu.si_support=1"
          "radeon.si_support=0"
        ]
        ++ optionals cfg.enableOverclocking [
          "amdgpu.ppfeaturemask=0xffffffff"
        ];
    };
    environment = {
      etc = mkIf cfg.enableROCm {
        "OpenCL/vendors/amdocl64.icd".text = "${pkgs.rocmPackages.clr}/lib/libamdocl64.so";
      };
      sessionVariables = {
        GPU_FORCE_64BIT_PTR = mkIf cfg.enableCompute "1";
        GPU_MAX_ALLOC_PERCENT = mkIf cfg.enableCompute "100";
        GPU_MAX_HEAP_SIZE = mkIf cfg.enableCompute "100";
        GPU_SINGLE_ALLOC_PERCENT = mkIf cfg.enableCompute "100";
        GPU_USE_SYNC_OBJECTS = mkIf cfg.enableCompute "1";
        HIP_PLATFORM = mkIf cfg.enableROCm "amd";
        HIP_VISIBLE_DEVICES = mkIf cfg.enableROCm "0";
        ROCM_PATH = mkIf cfg.enableROCm "${pkgs.rocmPackages.rocm-runtime}";
        ROCM_VERSION = mkIf cfg.enableROCm cfg.rocmVersion;

        LIBVA_DRIVER_NAME = mkIf cfg.enableMediaAcceleration "radeonsi";
      };
      systemPackages = with pkgs;
        [
          clinfo
          libva-utils
          radeontop
          vulkan-tools
        ]
        ++ optionals cfg.enableCompute [
          (writeShellScriptBin "amd-gpu-info" ''
            echo "=== AMD GPU Information ==="
            ${radeontop}/bin/radeontop -d - -l 1
            echo ""
            echo "=== OpenCL Devices ==="
            ${clinfo}/bin/clinfo
            echo ""
            echo "=== ROCm Information ==="
            ${pkgs.rocmPackages.rocminfo}/bin/rocminfo
          '')
          (writeShellScriptBin "amd-ai-offload" ''
            # Force AMD GPU for AI workloads
            export HIP_VISIBLE_DEVICES=0
            export ROCR_VISIBLE_DEVICES=0
            export HSA_OVERRIDE_GFX_VERSION=10.3.0
            exec "$@"
          '')
        ]
        ++ optionals cfg.enableOverclocking [
          corectrl
        ]
        ++ optionals cfg.enableROCm [
          rocmPackages.clr
          rocmPackages.rocm-runtime
          rocmPackages.rocminfo
        ]
        ++ optionals cfg.enableMachineLearning [
          rocmPackages.miopen
          rocmPackages.rocblas
          rocmPackages.rocsparse
          rocmPackages.rccl
        ];
    };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs;
        [
          libva
          libva-utils
          mesa
        ]
        ++ optionals cfg.enableCompute [
          rocmPackages.clr
          rocmPackages.rocm-opencl-icd
          rocmPackages.rocm-opencl-runtime
        ]
        ++ optionals cfg.enableMachineLearning [
          rocmPackages.miopen
          rocmPackages.rocblas
          rocmPackages.rocfft
          rocmPackages.rocsparse
        ]
        ++ optionals cfg.enableMediaAcceleration [
          libva
          libva-utils
          libvdpau-va-gl
        ]
        ++ optionals cfg.enableROCm [
          rocmPackages.rocm-runtime
          rocmPackages.rocminfo
        ]
        ++ optionals cfg.enableVulkan [
          amdvlk
          mesa
          vulkan-loader
          vulkan-tools
          vulkan-validation-layers
        ];

      extraPackages32 = with pkgs.pkgsi686Linux;
        [
          libva
          mesa
        ]
        ++ optionals cfg.enableVulkan [
          vulkan-loader
          vulkan-validation-layers
        ];
    };
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "amdvlk"
      ];

    systemd.tmpfiles.rules = mkIf cfg.enableROCm [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      "L+    /opt/rocm/lib   -    -    -     -    ${pkgs.rocmPackages.rocm-runtime}/lib"
      "L+    /opt/rocm/include   -    -    -     -    ${pkgs.rocmPackages.rocm-runtime}/include"
    ];
    services = {
      udev.extraRules = ''
        # AMD GPU device permissions
        SUBSYSTEM=="drm", KERNEL=="card*", ATTRS{vendor}=="0x1002", GROUP="video", MODE="0664"
        SUBSYSTEM=="drm", KERNEL=="renderD*", ATTRS{vendor}=="0x1002", GROUP="render", MODE="0664"
        # ROCm device permissions
        SUBSYSTEM=="kfd", KERNEL=="kfd", GROUP="render", MODE="0666"
        SUBSYSTEM=="misc", KERNEL=="kfd", GROUP="render", MODE="0666"
      '';
      xserver.videoDrivers = ["amdgpu"];
    };
    users.groups.render = {};
    users.groups.video = {};
  };
}
