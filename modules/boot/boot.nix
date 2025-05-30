# /qompassai/NixOS/modules/0/boot.nix
# Qompass AI Nix boot configuration module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.system.boot;
in {
  options.system.boot = {
    enable = mkEnableOption "Enable custom boot configuration";
    enableSystemdBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Enable systemd-boot instead of GRUB";
    };
    enablePlymouth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Plymouth boot splash";
    };
  };
  config = mkIf cfg.enable {
    boot = {
      loader = mkMerge [
        (mkIf cfg.enableSystemdBoot {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
            consoleMode = "auto";
          };
          efi.canTouchEfiVariables = true;
        })

        (mkIf (!cfg.enableSystemdBoot) {
          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            useOSProber = true;
            configurationLimit = 10;
          };
          efi.canTouchEfiVariables = true;
        })
      ];
      plymouth = mkIf cfg.enablePlymouth {
        enable = true;
        theme = "breeze";
      };
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "sd_mod"
          "rtsx_pci_sdmmc"
          "r8169"
          "r8125"
        ];
        kernelModules = [
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];
        kernelModules = ["nvidia_drm"];
        compressor = "zstd";
        compressorArgs = ["-19" "-T0"];
      };
      kernelModules = [
        "kvm-intel"
        "kvm-amd"
        "vfio-pci"
      ];
      tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
      };
      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };
    systemd = {
      services = {
        "getty@tty1".enable = false;
        "autovt@tty1".enable = false;
      };
      defaultUnit = "graphical.target";
    };
  };
}
