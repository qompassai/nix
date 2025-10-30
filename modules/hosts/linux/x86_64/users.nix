# /qompassai/nix/hosts/linux/x86_64/users.nix
# Qompass AI Nixos x86_64-linux User Config
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  config,
  pkgs,
  username,
  ...
}:
{
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = config.gitUsername;
      extraGroups = [
        "audio"
        "docker"
        "input"
        "libvirtd"
        "lp"
        "networkmanager"
        "render"
        "scanner"
        "video"
        "wheel"
      ];
      shell = pkgs.bash;
      packages = with pkgs; [ bash ];
    };
  };
  users.defaultUserShell = pkgs.bash;
  environment.shells = with pkgs; [
    zsh
    bash
    fish
  ];
  environment.systemPackages = with pkgs; [
    lsd
    fzf
  ];
}
