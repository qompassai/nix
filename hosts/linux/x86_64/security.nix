# security.nix
# Qompass AI NixOS x86_64 Security Config
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ ... }:
{
  security = {
    acme = {
      acceptTerms = true;
      defaults.group = "acme";
    };
    #apparmor.enable = true;
    audit.enable = true;
    pam = {
      enableFscrypt = true;
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
