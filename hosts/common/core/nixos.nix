# /qompassai/nix/hosts/common/core/nixos.nix
# Qompass AI Nix Host Common NixOS
# Copyright (C) 2025 Qompass AI, All rights reserved
#################################################### 
{ config, lib, ... }:
{
  environment.enableAllTerminfo = true;
  hardware.enableRedistributableFirmware = true;
  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults pwfeedback 
    Defaults timestamp_timeout=120
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
          capslock = "noop";
          numlock = "noop";
        };
      };
    };
  };
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/LosAngeles";
}
