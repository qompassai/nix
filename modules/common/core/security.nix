# security.nix
# Qompass AI Common Security 
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
  baseSecurity = {
    acme = {
      acceptTerms = true;
      defaults = {
        group = "acme";
        keyType = "ec384";
      };
    };
    apparmor.enable = true;
    apparmor.enableCache = true;
    audit.enable = true;
    audit.backlogLimit = 1024;
    audit.failureMode = "printk";
    auditd.enable = true;
    pam.enableFscrypt = true;
    pam.sshAgentAuth.enable = true;
    pam.p11.enable = true;
    pam.rssh.enable = true;
    polkit.enable = true;
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
  securityTable = {
    "linux-x86_64-linux" = {
      audit.failureMode = "panic";
      auditd.plugins.syslog = {
        path = lib.getExe' pkgs.audit "audisp-syslog";
        args = [ "LOG_INFO" ];
      };
      pam.services.login.fprintAuth = true;
      pam.services.sudo.fprintAuth = true;
    };
    "darwin-x86_64-darwin" = {
      pam.enableFscrypt = false;
      apparmor.enable = false;
    };
    "nvidia-aarch64-linux" = {
      pam.services.hyprland = { };
    };
    "vm-x86_64-linux" = {
      sudo.wheelNeedsPassword = true;
    };
  };
  key = "${platform}-${system}";
  uniqueSecurity = if securityTable ? key then securityTable.${key} else {};
  mergedSecurity = baseSecurity // uniqueSecurity;
in
{
  security = mergedSecurity;
}
