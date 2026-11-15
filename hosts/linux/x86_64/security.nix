# /qompassai/nix/hosts/linux/x86_64/security.nix
# Qompass AI NixOS x86_64 Security Config
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{ lib, pkgs, ... }:
{
  security = {
    acme = {
      acceptTerms = true;
      defaults = {
        group = "acme";
        keyType = "ec384";
      };
    };
    apparmor = {
      enable = true;
      enableCache = true;
    };
    audit = {
      backlogLimit = 1024;
      enable = true;
      failureMode = "printk";
    };
    auditd = {
      enable = true;
      plugins = {
        af_unix = {
          path = lib.getExe' pkgs.audit "audisp-af_unix";
          args = [
            "0640"
            "/var/run/audispd_events"
            "string"
          ];
          format = "binary";
        };
        remote = {
          path = lib.getExe' pkgs.audit "audisp-remote";
          settings = { };
        };
        filter = {
          path = lib.getExe' pkgs.audit "audisp-filter";
          args = [
            "allowlist"
            "/etc/audit/audisp-filter.conf"
            (lib.getExe' pkgs.audit "audisp-syslog")
            "LOG_USER"
            "LOG_INFO"
            "interpret"
          ];
          settings = { };
        };
        syslog = {
          path = lib.getExe' pkgs.audit "audisp-syslog";
          args = [ "LOG_INFO" ];
        };
      };
    };
    pam = {
      enableFscrypt = true;
      loginLimits = [
        {
          domain = "nixbld*";
          type = "soft";
          item = "nofile";
          value = "4096";
        }
        {
          domain = "nixbld*";
          type = "hard";
          item = "nofile";
          value = "8192";
        }
      ];
      services = {
        login.fprintAuth = true;
        sudo.fprintAuth = true;
      };
      sshAgentAuth = {
        enable = true;
      };
      p11.enable = true;
      rssh.enable = true;
      services = {
        hyprland = { };
      };
    };
    polkit.enable = true;
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
