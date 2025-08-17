# config.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{ config, pkgs, ... }:

{
  networking.hostName = "aarch64-linux";

  imports = [
    ../common/core/default.nix
  ];

  services.sshd.enable = true;
  services.openssh.enable = true; # for NixOS 24.05+
  users.users.phaedrus = {
    isNormalUser = true;
    home = "/home/phaedrus";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };
}

