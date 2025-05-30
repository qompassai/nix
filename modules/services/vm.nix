# /qompassai/nur-packages/modules/0/vm-guest-services.nix
# Qompass AI Nix vm-guest-services module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vm.guest-services;
in {
  options.vm.guest-services = {
    enable = mkEnableOption "Enable Virtual Machine Guest Services";
    hypervisor = mkOption {
      type = types.enum ["auto" "qemu" "vmware" "virtualbox" "hyper-v" "xen"];
      default = "auto";
      description = "Hypervisor type (auto-detect or specify)";
    };
    enableClipboardSharing = mkOption {
      type = types.bool;
      default = true;
      description = "Enable clipboard sharing between host and guest";
    };
    enableFileSharing = mkOption {
      type = types.bool;
      default = true;
      description = "Enable file sharing capabilities";
    };
    enableGraphicsAcceleration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable graphics acceleration for VMs";
    };
    enableNetworkOptimization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable network optimizations for VMs";
    };
    enablePerformanceOptimizations = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CPU and memory optimizations";
    };
    enableResolutionScaling = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic resolution scaling";
    };
    enableTimeSync = mkOption {
      type = types.bool;
      default = true;
      description = "Enable time synchronization with host";
    };
    enableUSBRedirection = mkOption {
      type = types.bool;
      default = false;
      description = "Enable USB device redirection";
    };
  };
  config = mkIf cfg.enable {
    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = mkDefault cfg.enableClipboardSharing;
      spice-webdavd.enable = mkDefault cfg.enableFileSharing;
      chrony = mkIf cfg.enableTimeSync {
        enable = mkDefault true;
        extraConfig = ''
          # VM-specific time sync optimizations
          makestep 1.0 3
          rtcsync
        '';
      };
      vmwareGuest = mkIf (cfg.hypervisor == "vmware" || cfg.hypervisor == "auto") {
        enable = mkDefault true;
        headless = mkDefault false;
      };
      virtualboxGuest = mkIf (cfg.hypervisor == "virtualbox" || cfg.hypervisor == "auto") {
        enable = mkDefault true;
        x11 = mkDefault true;
      };
      xenGuest = mkIf (cfg.hypervisor == "xen" || cfg.hypervisor == "auto") {
        enable = mkDefault true;
      };
    };
    boot = mkIf cfg.enablePerformanceOptimizations {
      kernelParams =
        [
          "elevator=noop"
          "clocksource=kvm-clock"
          "no_timer_check"
          "noreplace-paravirt"
          "tsc=reliable"
        ]
        ++ optionals (cfg.hypervisor == "hyper-v" || cfg.hypervisor == "auto") [
          "clocksource=hyperv_clocksource_tsc_page"
        ];
      initrd.availableKernelModules =
        [
          "virtio_net"
          "virtio_pci"
          "virtio_mmio"
          "virtio_blk"
          "virtio_scsi"
          "9p"
          "9pnet_virtio"
        ]
        ++ optionals (cfg.hypervisor == "vmware" || cfg.hypervisor == "auto") [
          "vmw_pvscsi"
          "vmxnet3"
        ]
        ++ optionals (cfg.hypervisor == "hyper-v" || cfg.hypervisor == "auto") [
          "hv_vmbus"
          "hv_storvsc"
          "hv_netvsc"
          "hv_utils"
        ];
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
    };

    hardware.graphics = mkIf cfg.enableGraphicsAcceleration {
      enable = true;
      extraPackages = with pkgs;
        [
          mesa
          libva
          libva-utils
        ]
        ++ optionals (cfg.hypervisor == "vmware" || cfg.hypervisor == "auto") [
          xorg.xf86videosvga
        ]
        ++ optionals (cfg.hypervisor == "virtualbox" || cfg.hypervisor == "auto") [
          virtualboxGuestAdditions
        ];
    };
    environment = {
      systemPackages = with pkgs;
        [
          qemu-guest-agent
        ]
        ++ optionals cfg.enableClipboardSharing [
          xclip
          wl-clipboard
        ]
        ++ optionals (cfg.hypervisor == "vmware" || cfg.hypervisor == "auto") [
          open-vm-tools
        ]
        ++ optionals (cfg.hypervisor == "virtualbox" || cfg.hypervisor == "auto") [
          virtualboxGuestAdditions
        ]
        ++ optionals cfg.enableUSBRedirection [
          spice-gtk
          usbredir
        ];
      sessionVariables = mkIf cfg.enableGraphicsAcceleration {
        LIBGL_ALWAYS_SOFTWARE = mkDefault "0";
        MESA_LOADER_DRIVER_OVERRIDE = mkIf (cfg.hypervisor == "qemu") "virtio-gpu";
      };
    };
    networking = mkIf cfg.enableNetworkOptimization {
      firewall.allowPing = mkDefault true;
      interfaces =
        mkIf (cfg.hypervisor == "qemu" || cfg.hypervisor == "auto") {
        };
    };
    fileSystems = mkIf cfg.enablePerformanceOptimizations {
      "/" = {
        options = mkDefault ["noatime" "nodiratime"];
      };
    };
    security = {
      sudo.wheelNeedsPassword = mkDefault false;
    };
    systemd = {
      extraConfig = mkIf cfg.enablePerformanceOptimizations ''
        DefaultTimeoutStopSec=30s
        DefaultTimeoutStartSec=30s
      '';
      services = {
        vm-memory-balloon = mkIf cfg.enablePerformanceOptimizations {
          description = "VM Memory Balloon Service";
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.util-linux}/bin/modprobe virtio_balloon";
          };
        };
        vm-time-sync = mkIf cfg.enableTimeSync {
          description = "VM Time Synchronization";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.systemd}/bin/timedatectl set-ntp true";
          };
        };
      };
    };
    specialisation = {
      vmware-optimized = mkIf (cfg.hypervisor == "auto") {
        configuration = {
          services.vmwareGuest.enable = mkForce true;
          services.qemuGuest.enable = mkForce false;
        };
      };
      virtualbox-optimized = mkIf (cfg.hypervisor == "auto") {
        configuration = {
          services.virtualboxGuest.enable = mkForce true;
          services.qemuGuest.enable = mkForce false;
        };
      };
    };
    warnings =
      []
      ++ optional (cfg.enableUSBRedirection && !cfg.enableClipboardSharing)
      "USB redirection is enabled but clipboard sharing is disabled. Consider enabling both for better user experience."
      ++ optional (cfg.hypervisor == "auto")
      "Auto-detection of hypervisor may not be optimal. Consider specifying the exact hypervisor type.";
  };
}
