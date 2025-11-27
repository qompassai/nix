# /qompassai/nur-packages/modules/0/nvidia-drivers.nix
# Qompass AI Nix nvidia-drivers module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.drivers.nvidia;
in {
  options.drivers.nvidia = {
    enable = mkEnableOption "Enable Nvidia Drivers";
    enableWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland optimizations for NVIDIA";
    };
  };
  config = mkIf cfg.enable {
    boot = {
      blacklistedKernelModules = ["nouveau"];
      extraModprobeConfig = ''
        # NVIDIA Driver Configuration
        options nvidia NVreg_DynamicPowerManagement=2
        options nvidia NVreg_DynamicPowerManagementVideoMemoryThreshold=2000
        options nvidia NVreg_EnableGpuFirmware=0
        options nvidia NVreg_EnablePCIERelaxedOrderingMode=1
        options nvidia NVreg_EnableResizableBar=1
        options nvidia NVreg_EnableS0ixPowerManagement=1
        options nvidia NVreg_IgnoreMMIOCheck=1
        options nvidia NVreg_InitializeSystemMemoryAllocations=0
        options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
        options nvidia NVreg_PreserveVideoMemoryAllocations=1
        options nvidia NVreg_RestrictProfilingToAdminUsers=0
        options nvidia NVreg_UsePageAttributeTable=1
        options nvidia_drm atomic=1
        options nvidia_drm fbdev=1
        options nvidia_drm modeset=1
        options nvidia_modeset debug_force_color_space=13
        options nvidia_modeset disable_hdmi_frl=0
        options nvidia_modeset disable_vrr_memclk_switch=1
        options nvidia_modeset enable_overlay_layers=1
        options nvidia_modeset hdmi_deepcolor=1
        options nvidia_modeset opportunistic_display_sync=1
        options nvidia_modeset output_rounding_fix=1
        options nvidia_modeset vblank_sem_control=1
        options nvidia_uvm uvm_disable_hmm=0
        options nvidia_uvm uvm_enable_va_space_mm=1
        options nvidia_uvm uvm_global_oversubscription=1
        options nvidia_uvm uvm_leak_checker=2
        options nvidia_uvm uvm_page_table_location=vid
        options nvidia_uvm uvm_peer_copy=virt
        options nvidia_uvm uvm_perf_access_counter_batch_count=32
        options nvidia_uvm uvm_perf_access_counter_migration_enable=1
        options nvidia_uvm uvm_perf_access_counter_threshold=100
        options nvidia_uvm uvm_perf_fault_batch_count=64
        options nvidia_uvm uvm_perf_fault_coalesce=1
        options nvidia_uvm uvm_perf_prefetch_enable=1
        options nvidia_uvm uvm_perf_prefetch_min_faults=2
        options nvidia_uvm uvm_perf_prefetch_threshold=4
        options nvidia_uvm uvm_perf_thrashing_enable=0
      '';
    };
    environment.sessionVariables = mkIf cfg.enableWayland {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
    };
    services.xserver.videoDrivers = ["nvidia"];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
        libvdpau
        libvdpau-va-gl
        mesa
        nvidia-vaapi-driver
        vaapiVdpau
        vdpauinfo
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vulkan-loader
        vulkan-validation-layers
      ];
    };
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = true;
      dynamicBoost.enable = true;
      nvidiaPersistenced = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
}
