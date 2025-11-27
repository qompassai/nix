# /qompassai/NixOS/modules/0/hardware.nix
# Qompass AI Nix hardware configuration module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.qompass;
in {
  options.hardware.qompass = {
    enable = mkEnableOption "Enable Qompass AI hardware optimizations";
    enableAudio = mkOption {
      type = types.bool;
      default = true;
      description = "Enable audio optimizations";
    };
    enableBluetooth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Bluetooth support";
    };
    enableUsb = mkOption {
      type = types.bool;
      default = true;
      description = "Enable USB optimizations";
    };
  };
  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          intel-compute-runtime
          level-zero
        ];
      };
      cpu = {
        intel.updateMicrocode = true;
        amd.updateMicrocode = true;
      };
      pulseaudio.enable = mkIf (!cfg.enableAudio) false;
    };
    services.pipewire = mkIf cfg.enableAudio {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 32;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 8192;
        };
      };
    };
    services.blueman.enable = mkIf cfg.enableBluetooth true;
    hardware.bluetooth = mkIf cfg.enableBluetooth {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };
    services.udev.extraRules = mkIf cfg.enableUsb ''
      # USB performance optimizations
      SUBSYSTEM=="usb", ATTR{power/control}="on"
      SUBSYSTEM=="usb", ATTR{power/autosuspend}="-1"
      # GPU device permissions
      KERNEL=="nvidia*", GROUP="video", MODE="0664"
      KERNEL=="card*", GROUP="video", MODE="0664"
      KERNEL=="renderD*", GROUP="render", MODE="0664"
    '';
    services.power-profiles-daemon.enable = false;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        USB_AUTOSUSPEND = 0;
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };
    services.fwupd.enable = true;
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;
    virtualisation = {
      docker.enable = true;
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
  };
}
