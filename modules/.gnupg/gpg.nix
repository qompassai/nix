# ~/.dotfiles/modules/.gnupg/gpg.nix
# ----------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ config, pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    verbose = true;
    pinentryFlavor = "bemenu";
    
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 14400;
    maxCacheTtl = 604800;
    
    extraConfig = ''
      allow-loopback-pinentry
      allow-preset-passphrase
      disable-scdaemon
      enable-extended-key-format
      ignore-cache-for-signing
      no-allow-external-cache
      no-allow-mark-trusted
      scdaemon-program /dev/null
      ssh-fingerprint-digest SHA256
    '';
  };

  home.packages = [ pkgs.pinentry-bemenu ];
  home.file.".gnupg/gpg-agent.conf".source = ./gpg-agent.conf;
}

