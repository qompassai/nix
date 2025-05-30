# /qompassai/nur-packages/modules/boot/hardware-clock.nix
# Qompass AI Nix hardware-clock module
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------------------
{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.local.hardware-clock;
in {
  options.local.hardware-clock = {
    enable = mkEnableOption "Enable hardware clock configuration";
    useLocalTime = mkOption {
      type = types.bool;
      default = true;
      description = "Set hardware clock to local time (useful for Windows dual-boot)";
    };
    timeZone = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "System timezone (e.g., 'America/New_York', 'Europe/London')";
      example = "America/Los_Angeles";
    };
    syncOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Synchronize system time with hardware clock on boot";
    };
    ntpSync = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NTP synchronization";
    };
    ntpServers = mkOption {
      type = types.listOf types.str;
      default = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
      description = "NTP servers to use for time synchronization";
    };
    rtcWakeAlarm = mkOption {
      type = types.bool;
      default = false;
      description = "Enable RTC wake alarm support";
    };
  };
  config = mkIf cfg.enable {
    time = {
      hardwareClockInLocalTime = cfg.useLocalTime;
      timeZone = mkIf (cfg.timeZone != null) cfg.timeZone;
    };
    services.ntp = mkIf cfg.ntpSync {
      enable = true;
      servers = cfg.ntpServers;
    };
    services.timesyncd = mkIf (!cfg.ntpSync && cfg.ntpSync != false) {
      enable = true;
      servers = cfg.ntpServers;
    };
    services.udev.extraRules = mkIf cfg.rtcWakeAlarm ''
      SUBSYSTEM=="rtc", ATTR{wakealarm}=="*", GROUP="audio", MODE="0664"
    '';
    environment.systemPackages = with pkgs;
      [
        hwclock
        ntpdate
      ]
      ++ optionals cfg.rtcWakeAlarm [
        rtcwake
      ];
    systemd.services.hardware-clock-sync = mkIf cfg.syncOnBoot {
      description = "Synchronize system time with hardware clock";
      wantedBy = ["multi-user.target"];
      after = ["systemd-hwdb-update.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/hwclock --hctosys";
        RemainAfterExit = true;
      };
    };
    warnings =
      []
      ++ optional (cfg.useLocalTime && cfg.timeZone == null)
      "Hardware clock set to local time but no timezone specified. Consider setting local.hardware-clock.timeZone."
      ++ optional (cfg.useLocalTime && cfg.ntpSync)
      "Using local time with NTP sync may cause issues in dual-boot setups.";
  };
}
