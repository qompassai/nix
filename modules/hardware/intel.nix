# /qompassai/NixOS/modules/0/hw/intel.nix
# Qompass AI Nix Intel GPU/drivers module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.intel;
in {
  options.hardware.intel = {
    enable = mkEnableOption "Enable Intel Graphics/GPU support";
    enableCompute = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel GPU compute capabilities (OpenCL, Level Zero)";
    };
    enableHybridCodec = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel hybrid codec support";
    };
    enableMediaSdk = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel Media SDK for hardware encoding/decoding";
    };
    enableOneAPI = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel oneAPI components (DPC++, oneDNN, etc.)";
    };
    enableOpenVINO = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel OpenVINO inference engine";
    };
    enableVulkan = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Vulkan support for Intel graphics";
    };
    enableAiOptimizations = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AI/ML workload optimizations";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(config.drivers.nvidia-prime.enable or false)
          || (config.drivers.nvidia-prime.intelBusID != "");
        message = "When using Intel + NVIDIA Prime, intelBusID must be specified";
      }
    ];
    boot = {
      initrd.kernelModules = ["i915"];
      kernelModules = ["i915"];
      kernelParams =
        [
          "i915.enable_fbc=1"
          "i915.enable_guc=2"
          "i915.enable_psr=1"
          "i915.enable_dc=2"
        ]
        ++ optionals cfg.enableCompute [
          "intel_iommu=on"
          "i915.enable_hangcheck=0"
        ]
        ++ optionals cfg.enableAiOptimizations [
          "i915.scheduler_timeout_ms=0"
          "i915.preempt_timeout=0"
        ];
    };
    environment = {
      etc = {
        "OpenCL/vendors/intel.icd" = mkIf cfg.enableCompute {
          text = "${pkgs.intel-compute-runtime}/lib/libigdrcl.so";
        };
        "level-zero.conf" = mkIf cfg.enableCompute {
          text = ''
            ${pkgs.level-zero}/lib/libze_loader.so.1
          '';
        };
      };
      sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
        VAAPI_DEVICE = "/dev/dri/renderD128";
        DNNL_CPU_RUNTIME = mkIf cfg.enableOneAPI "OMP";
        DNNL_GPU_RUNTIME = mkIf cfg.enableOneAPI "OCL";
        IGC_EnableDPEmulation = mkIf cfg.enableCompute "1";
        NEOReadDebugKeys = mkIf cfg.enableCompute "1";
        INTEL_OPENVINO_DIR = mkIf cfg.enableOpenVINO "${pkgs.openvino}";
        MFX_HOME = mkIf cfg.enableMediaSdk "${pkgs.intel-media-sdk}";
        ONEAPI_DEVICE_SELECTOR = mkIf cfg.enableAiOptimizations "level_zero:gpu";
        SYCL_DEVICE_FILTER = mkIf cfg.enableAiOptimizations "gpu";
        OPENVINO_DEVICE = mkIf (cfg.enableOpenVINO && cfg.enableAiOptimizations) "GPU";
        LD_LIBRARY_PATH =
          mkIf cfg.enableOpenVINO
          "\${LD_LIBRARY_PATH:+\${LD_LIBRARY_PATH}:}${pkgs.openvino}/lib";
      };
      systemPackages = with pkgs;
        [
          clinfo
          intel-gpu-tools
          libva-utils
          vainfo
        ]
        ++ optionals cfg.enableCompute [
          intel-compute-runtime
          level-zero
        ]
        ++ optionals cfg.enableVulkan [
          vulkan-tools
          vulkan-loader
        ]
        ++ optionals cfg.enableOneAPI [
          intel-oneapi-dnn
          intel-oneapi-mkl
          intel-oneapi-tbb
        ]
        ++ optionals cfg.enableOpenVINO [
          openvino
        ]
        ++ optionals cfg.enableAiOptimizations [
          (writeShellScriptBin "intel-ai-offload" ''
            # Force Intel GPU for AI workloads
            export ONEAPI_DEVICE_SELECTOR=level_zero:gpu
            export OPENVINO_DEVICE=GPU
            export SYCL_DEVICE_FILTER=gpu
            export LIBVA_DRIVER_NAME=iHD
            exec "$@"
          '')
          (writeShellScriptBin "intel-gpu-info" ''
            echo "=== Intel GPU Information ==="
            ${intel-gpu-tools}/bin/intel_gpu_top -s 1000 -c 1 2>/dev/null || echo "GPU top unavailable"
            echo ""
            echo "=== VAAPI Info ==="
            ${libva-utils}/bin/vainfo
            echo ""
            echo "=== OpenCL Devices ==="
            ${clinfo}/bin/clinfo
            echo ""
            echo "=== Level Zero Devices ==="
            ${level-zero}/bin/zello_world 2>/dev/null || echo "Level Zero test failed"
          '')
          (writeShellScriptBin "intel-benchmark" ''
            echo "Running Intel GPU benchmarks..."
            echo "=== OpenCL Info ==="
            ${clinfo}/bin/clinfo -l
            echo "=== Memory Bandwidth Test ==="
            # Add your preferred GPU benchmark here
            echo "Benchmark complete."
          '')
        ];
    };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs;
        [
          intel-media-driver
          libva
          libva-utils
          libvdpau-va-gl
          vaapiIntel
        ]
        ++ optionals cfg.enableCompute [
          intel-compute-runtime
          intel-graphics-compiler
          level-zero
        ]
        ++ optionals cfg.enableMediaSdk [
          intel-media-sdk
          libmfx
        ]
        ++ optionals cfg.enableOneAPI [
          intel-oneapi-dnn
          intel-oneapi-mkl
          intel-oneapi-tbb
        ]
        ++ optionals cfg.enableOpenVINO [
          openvino
        ]
        ++ optionals cfg.enableVulkan [
          mesa
          vulkan-loader
          vulkan-tools
          vulkan-validation-layers
        ];
      extraPackages32 = with pkgs.pkgsi686Linux;
        [
          intel-media-driver
          libva
          vaapiIntel
        ]
        ++ optionals cfg.enableVulkan [
          vulkan-loader
          vulkan-validation-layers
        ];
    };
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = cfg.enableHybridCodec;
      };
    };
    services.udev.extraRules = ''
      # Intel GPU device permissions
      SUBSYSTEM=="drm", KERNEL=="card*", ATTRS{vendor}=="0x8086", GROUP="video", MODE="0664"
      SUBSYSTEM=="drm", KERNEL=="renderD*", ATTRS{vendor}=="0x8086", GROUP="render", MODE="0664"
      # Intel compute device permissions
      SUBSYSTEM=="drm", KERNEL=="renderD*", ATTRS{vendor}=="0x8086", TAG+="uaccess"
    '';
    systemd.services.intel-gpu-optimization = mkIf cfg.enableAiOptimizations {
      description = "Intel GPU Performance Optimization";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Set GPU frequency scaling
        echo performance > /sys/class/drm/card0/gt/gt0/freq_boost_enable 2>/dev/null || true
        # Optimize GPU memory management
        echo 1 > /sys/module/i915/parameters/enable_guc 2>/dev/null || true
      '';
    };
  };
}
