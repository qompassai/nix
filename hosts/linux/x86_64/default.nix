# default.nix
# Qompass AI - [Add description here]
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
{
  imports = [
    ./boot.nix
    ./config.nix
    ./environment.nix
    ./hardware.nix
    ./misc.nix
    ./nix.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./security.nix
    ./users.nix
    ./variables.nix
    ./xdg.nix
  ];
}
