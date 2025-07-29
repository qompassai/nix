# /qompassai/nix/hosts/common/core/nixos.nix
# Qompass AI Nix Host Common NixOS
# Copyright (C) 2025 Qompass AI, All rights reserved
#################################################### 
{ config, lib, ... }:
{
  environment.enableAllTerminfo = true;
  hardware.enableRedistributableFirmware = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
    # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
    Defaults env_keep+=SSH_AUTH_SOCK
  '';
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 20";
    flake = "/home/user/${config.hostSpec.home}/nix-config";
  };
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "noop"; # TODO(keyboard): should change this to be overload(\, |) to match moonlander
          numlock = "noop"; # numlock state on by default via hyprland config
        };
      };
    };
  };
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/LosAngeles";
}
