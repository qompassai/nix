# /qompassai/nix/hosts/msft/wsl.nix
# Qompass AI Windows Subsystem for Linux (WSL) Config
# Copyright (C) 2025 Qompass AI, All rights reserved
#####################################################
{ pkgs, currentSystemUser, ... }: {
  imports = [];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = currentSystemUser;
    startMenuLaunchers = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  system.stateVersion = "23.05";
}
